# D3-P Cluster
텔레칩스 **TOPST D3-P** 보드에서 동작하는 디지털 클러스터(계기판) 애플리케이션입니다.  
안전·주행과 직결된 정보를 클러스터에 집중시킴으로써 운전자 시선 분산을 최소화할 수 있습니다.


<p align="center">
  <img src="https://github.com/user-attachments/assets/fff91f3e-7a6f-4fc6-917a-8af64f7f48fd" width="45%"/>
  <img src="https://github.com/user-attachments/assets/f67edefb-fff7-4459-9209-e7dbed98b102" width="45%"/>
</p>

## 주요 기능
- 속도/ RPM : 기본 계기 정보 표시
- 앞 차량 출발 알림 및 전방 접근 경고 표시
- CAN(SocketCAN) 또는 TCP를 통한 상태 수신 및 화면 갱신

## 디렉터리 구조
```
Qt/
├── cluster-0810.pro        # Qt 프로젝트 파일
├── ClusterBackend.cpp/.h   # 백엔드 코드
├── main.cpp                # 메인 C++ 코드
├── main.qml                # 메인 QML UI
│
├── cluster-images/         # 클러스터 이미지 리소스
├── ui/                     # UI 관련 리소스
├── resources.qrc           # 리소스 정의
├── qml.qrc                 # QML 리소스 정의
│
└── Makefile                # 빌드 규칙

can_uds/                    # can 수신, uds client
```
## 데이터 입력
```
typedef struct {
   int speed;
   int rpm;
   int driveWarning;
   int frontWarning;
   int leftWarning;
   int rightWarning;
} ClusterStatus;
```
