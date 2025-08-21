#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>

#include <sys/types.h>
#include <sys/socket.h>
#include <sys/un.h>
#include <sys/ioctl.h>

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

volatile int running = 1;

void signal_handler(int signum) {
    running = 0;
}

int setup_can_socket() {
    int s;
    struct ifreq ifr;
    struct sockaddr_can addr;

    s = socket(PF_CAN, SOCK_RAW, CAN_RAW);
    if (s < 0) return -1;

    strcpy(ifr.ifr_name, CAN_INTERFACE);
    if (ioctl(s, SIOCGIFINDEX, &ifr) < 0) {
        close(s);
        return -1;
    }

    addr.can_family = AF_CAN;
    addr.can_ifindex = ifr.ifr_ifindex;

    if (bind(s, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
        close(s);
        return -1;
    }

    return s;
}

int setup_uds_client_sock() {
    int s;
    struct sockaddr_un server_addr;

    s = socket(AF_UNIX, SOCK_STREAM, 0);
    if (s < 0) return -1;

    server_addr.sun_family = AF_UNIX;
    strcpy(server_addr.sun_path, SERVER_UDS_PATH);

    while (connect(s, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0) {
        if (!running) {
            close(s);
            return -1;
        }
        sleep(1);
    }
    return s;
}

int main() {
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

    while (running) {
        int nbytes = read(can_sock, &frame, sizeof(frame));
        if (nbytes < 0) {
            if (running) continue;
        }
        if (nbytes < sizeof(struct can_frame)) continue;

        switch (frame.can_id & CAN_SFF_MASK) {
            case 0x200:
                current_status.rpm = (frame.data[0] << 8) | frame.data[1];
                current_status.speed = frame.data;
                break;
            case 0x300: current_status.frontWarning = frame.data; break;
            case 0x301: current_status.leftWarning = frame.data; break;
            case 0x302: current_status.rightWarning = frame.data; break;
            case 0x600: current_status.driveWarning = frame.data; break;
        }

        if (memcmp(&current_status, &prev_status, sizeof(ClusterStatus)) != 0) {
            if (write(uds_sock, &current_status, sizeof(current_status)) < 0) {
                running = 0;
            }
            memcpy(&prev_status, &current_status, sizeof(ClusterStatus));
        }
    }

    close(uds_sock);
    close(can_sock);

    return 0;
}
