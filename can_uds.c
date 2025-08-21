/* 
 * 기능 테스트 매크로 선언 (glibc 확장 기능 사용)
 * 반드시 다른 모든 #include 보다 먼저 와야 합니다.
 */
#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <signal.h> // ★ 시그널 처리를 위해 추가

// 시스템 타입 및 소켓 관련 헤더
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <sys/ioctl.h>

// 네트워크 및 인터페이스 관련 헤더
#include <net/if.h>
#include <linux/can.h>
#include <linux/can/raw.h>

#define CAN_INTERFACE "can0"
#define SERVER_UDS_PATH "/tmp/can_qt_server"

typedef struct {
    int speed;
    int rpm;
    int frontWarning;
    int leftWarning;
    int rightWarning;
    int driveWarning;
} ClusterStatus;

// ★ Ctrl+C 입력을 처리하기 위한 전역 플래그
// volatile 키워드는 컴파일러 최적화를 방지하여, 시그널 핸들러에서 변경된 값을 메인 루프가 즉시 알 수 있게 합니다.
volatile int running = 1;

// ★ 시그널 핸들러 함수
// Ctrl+C (SIGINT)가 입력되면 이 함수가 호출됩니다.
void signal_handler(int signum) {
    printf("\nCaught signal %d. Shutting down...\n", signum);
    running = 0; // 메인 루프를 종료하도록 플래그를 변경
}

int setup_can_socket() {
    int s;
    struct ifreq ifr;
    struct sockaddr_can addr;
    
    s = socket(PF_CAN, SOCK_RAW, CAN_RAW);
    if (s < 0) {
        perror("CAN socket");
        return -1;
    }

    strcpy(ifr.ifr_name, CAN_INTERFACE);
    if (ioctl(s, SIOCGIFINDEX, &ifr) < 0) {
        perror("ioctl SIOCGIFINDEX");
        close(s);
        return -1;
    }
    
    addr.can_family = AF_CAN;
    addr.can_ifindex = ifr.ifr_ifindex;
    
    if (bind(s, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
        perror("CAN bind");
        close(s);
        return -1;
    }
    printf("CAN socket %s setup complete.\n", CAN_INTERFACE);
    return s;
}

int setup_uds_client_sock() {
    int s;
    struct sockaddr_un server_addr;

    s = socket(AF_UNIX, SOCK_STREAM, 0);
    if (s < 0) {
        perror("UDS socket");
        return -1;
    }

    server_addr.sun_family = AF_UNIX;
    strcpy(server_addr.sun_path, SERVER_UDS_PATH);

    printf("Connecting to UDS server at %s...\n", SERVER_UDS_PATH);
    while (connect(s, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0) {
        if (!running) { // 연결 시도 중에 종료 신호가 오면 중단
            close(s);
            return -1;
        }
        perror("UDS connect failed, retrying in 1 second...");
        sleep(1);
    }
    printf("UDS server connected.\n");
    return s;
}

int main() {
    // ★ SIGINT (Ctrl+C)에 대한 시그널 핸들러 등록
    signal(SIGINT, signal_handler);

    int can_sock = setup_can_socket();
    if (can_sock < 0) return 1;

    int uds_sock = setup_uds_client_sock();
    if (uds_sock < 0) {
        close(can_sock);
        return 1;
    }

    struct can_frame frame;
    ClusterStatus current_status = {0};
    ClusterStatus prev_status = {0};
    
    write(uds_sock, &current_status, sizeof(current_status));
    memcpy(&prev_status, &current_status, sizeof(ClusterStatus));

    printf("Starting CAN data monitoring...\n");
    
    // ★ 메인 루프: running 플래그가 1인 동안에만 실행
    while (running) {
        int nbytes = read(can_sock, &frame, sizeof(frame));
        if (nbytes < 0) {
            // read()는 시그널에 의해 중단될 수 있으므로, 루프를 계속 돌도록 처리
            if (running) perror("CAN read");
            continue;
        }

        if (nbytes < sizeof(struct can_frame)) continue;

        // ★ 기능 추가: 수신된 CAN 데이터 모니터링
        printf("[CAN RECV] ID: 0x%03X DLC: %d Data: ", frame.can_id & CAN_SFF_MASK, frame.can_dlc);
        for (int i = 0; i < frame.can_dlc; i++) {
            printf("%02X ", frame.data[i]);
        }
        printf("\n");

        switch (frame.can_id & CAN_SFF_MASK) {
            case 0x200:
                current_status.rpm = (frame.data[0] << 8) | frame.data[1];
                current_status.speed = frame.data[2];
                break;
            case 0x300: current_status.frontWarning = frame.data[0]; break;
            case 0x301: current_status.leftWarning = frame.data[0]; break;
            case 0x302: current_status.rightWarning = frame.data[0]; break;
            case 0x600: current_status.driveWarning = frame.data[0]; break;
        }

        if (memcmp(&current_status, &prev_status, sizeof(ClusterStatus)) != 0) {
            // ★ 기능 추가: UDS로 전송되는 데이터 모니터링
            printf("  └─ [UDS SENT] Speed:%3d, RPM:%d, F:%d, L:%d, R:%d, D:%d\n",
                   current_status.speed, current_status.rpm, current_status.frontWarning,
                   current_status.leftWarning, current_status.rightWarning, current_status.driveWarning);
            
            if (write(uds_sock, &current_status, sizeof(current_status)) < 0) {
                perror("UDS write failed");
                running = 0; // 쓰기 실패 시 루프 종료
            }
            memcpy(&prev_status, &current_status, sizeof(ClusterStatus));
        }
    }

    // ★ 기능 추가: 프로그램 종료 전 소켓 정리
    printf("Closing sockets...\n");
    close(uds_sock);
    close(can_sock);
    printf("Cleanup complete. Exiting.\n");

    return 0;
}
