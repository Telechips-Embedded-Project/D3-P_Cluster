/*
import QtQuick 2.6
import QtQuick.Controls 1.4

ApplicationWindow {
    id: root
    visible: true
    visibility: "FullScreen"
    flags: Qt.FramelessWindowHint

    width: 1600
    height: 960
    title: "Digital Cluster"

    Rectangle {
        anchors.fill: parent
        color: "black"

        // 1. 계기판 배경 이미지 (모든 UI의 기준)
        Image {
            id: clusterBackground
            anchors.fill: parent
            source: "qrc:/images/cluster-images/cluster_background.png"
            z: 0
        }

        // ========================================================================
        // ★★★ 2. 투명 앵커 포인트 정의 (가장 중요한 부분) ★★★
        // 아래 x, y 좌표를 당신의 배경 이미지에 맞게 *단 한 번만* 수정하면 됩니다.
        // ========================================================================

        // 속도계의 중심점을 위한 투명 앵커
        Item {
            id: speedGaugeAnchorPoint
            // 예시: 배경 이미지 속 속도계의 정중앙 x, y 좌표
            x: 260
            y: 500
        }

        // RPM 게이지의 중심점을 위한 투명 앵커
        Item {
            id: rpmGaugeAnchorPoint
            // 예시: 배경 이미지 속 RPM 게이지의 정중앙 x, y 좌표
            x: 1430
            y: 510
        }

        // ADAS 자동차 그래픽을 위한 투명 앵커
        Item {
            id: adasAnchorPoint
            // 예시: 배경 이미지 속 중앙 정보창의 정중앙 x, y 좌표
            x: 800
            y: 580
            // 정보창의 대략적인 크기
            width: 300; height: 250
        }


        // =======================================================
        // 3. 속도계 바늘 (앵커 포인트 기준 배치)
        // =======================================================
        Item {
            anchors.centerIn: speedGaugeAnchorPoint
            width: 350; height: 350

            Rectangle {
                id: speedNeedle
                x: 171; y: 35
                width: 8; height: 140
                color: "#E74C3C"
                radius: 4

                transformOrigin: Item.Bottom
                transform: Rotation {
                    origin.x: speedNeedle.width / 2
                    origin.y: speedNeedle.height
                    angle: clusterBackend.connected ? (-135 + (clusterBackend.speed / 260) * 270) : -135
                    Behavior on angle { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                }
                z: 10
            }

            Rectangle {
                width: 30; height: 30
                anchors.centerIn: parent
                radius: 15
                color: "#2C3E50"
                border.color: "#7F8C8D"
                border.width: 2
                z: 20
            }
        }

        // =======================================================
        // 4. RPM 게이지 바늘 (앵커 포인트 기준 배치)
        // =======================================================
        Item {
            anchors.centerIn: rpmGaugeAnchorPoint
            width: 350; height: 350

            Rectangle {
                id: rpmNeedle
                x: 171; y: 35
                width: 8; height: 140
                color: "#F1C40F"
                radius: 4

                transformOrigin: Item.Bottom
                transform: Rotation {
                    origin.x: rpmNeedle.width / 2
                    origin.y: rpmNeedle.height
                    angle: clusterBackend.connected ? (-135 + (clusterBackend.rpm / 8.0) * 270) : -135
                    Behavior on angle { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                }
                z: 10
            }

            Rectangle {
                width: 30; height: 30
                anchors.centerIn: parent
                radius: 15
                color: "#2C3E50"
                border.color: "#7F8C8D"
                border.width: 2
                z: 20
            }
        }

        // =================================================================
        // 5. ADAS 시각화 영역 (앵커 포인트 기준 배치)
        // =================================================================
        Item {
            id: adasView
            anchors.centerIn: adasAnchorPoint
            width: adasAnchorPoint.width; height: adasAnchorPoint.height
            z: 30

            Image {
                id: myCar
                anchors.centerIn: parent
                source: "qrc:/images/adas_car_top.png"
                width: 80; height: 160
                fillMode: Image.PreserveAspectFit
            }

            Image {
                source: "qrc:/images/adas_warning_front.png"
                anchors { bottom: myCar.top; horizontalCenter: myCar.horizontalCenter; bottomMargin: 5 }
                width: 120; height: 60
                visible: clusterBackend.frontWarning; opacity: 0
                SequentialAnimation on opacity { running: visible; loops: Animation.Infinite; NumberAnimation { from: 0.4; to: 1.0; duration: 600; } NumberAnimation { from: 1.0; to: 0.4; duration: 800; } }
            }
            Image {
                source: "qrc:/images/adas_warning_side.png"
                anchors { right: myCar.left; verticalCenter: myCar.verticalCenter; rightMargin: 5 }
                width: 70; height: 70
                visible: clusterBackend.leftWarning; opacity: 0
                SequentialAnimation on opacity { running: visible; loops: Animation.Infinite; NumberAnimation { from: 0.4; to: 1.0; duration: 600; } NumberAnimation { from: 1.0; to: 0.4; duration: 800; } }
            }
            Image {
                source: "qrc:/images/adas_warning_side.png"
                anchors { left: myCar.right; verticalCenter: myCar.verticalCenter; leftMargin: 5 }
                width: 70; height: 70
                transform: Scale { xScale: -1 }
                visible: clusterBackend.rightWarning; opacity: 0
                SequentialAnimation on opacity { running: visible; loops: Animation.Infinite; NumberAnimation { from: 0.4; to: 1.0; duration: 600; } NumberAnimation { from: 1.0; to: 0.4; duration: 800; } }
            }
            Image {
                source: "qrc:/images/adas_go_alert.png"
                anchors { bottom: myCar.top; horizontalCenter: myCar.horizontalCenter; bottomMargin: 10 }
                width: 60; height: 60
                visible: clusterBackend.driveWarning
            }
        }

        // =======================================================
        // 6. 디지털 정보 표시 (하단)
        // =======================================================
        Row {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 20
            spacing: 80

            Text { text: clusterBackend.speed + "<span style='font-size: 20pt;'> km/h</span>"; color: "white"; font.pixelSize: 48; font.bold: true; textFormat: Text.RichText }
            Text { text: clusterBackend.rpm.toFixed(1) + "<span style='font-size: 20pt;'> x1000 rpm</span>"; color: "white"; font.pixelSize: 48; font.bold: true; textFormat: Text.RichText }
        }

        // =======================================================
        // 7. 연결 상태 오버레이
        // =======================================================
        Rectangle {
            anchors.fill: parent; color: "#CC000000"
            visible: !clusterBackend.connected
            z: 50
            Text { anchors.centerIn: parent; text: "CAN 데이터 수신 대기 중..."; color: "white"; font.pixelSize: 24 }
        }
    }
}
*/

/*
import QtQuick 2.6
import QtQuick.Controls 1.4

ApplicationWindow {
    id: root
    visible: true
    visibility: "FullScreen"
    flags: Qt.FramelessWindowHint

    width: 800
    height: 480
    title: "Digital Cluster"

    Rectangle {
        anchors.fill: parent
        color: "black"

        // 1. 계기판 배경 이미지
        Image {
            id: clusterBackground
            anchors.fill: parent
            source: "qrc:/images/cluster-images/cluster_background.png"
            z: 0
        }

        // =======================================================
        // 3. 속도계 바늘 (중심 좌표 기준 배치)
        // =======================================================
        Item {
            // ★★★ 1. 속도계 중심 좌표 지정 ★★★
            // 아래 centerX, centerY 값을 수정하여 속도계의 중심을 변경하세요.
            property real centerX: 180
            property real centerY: 260

            // 아래 코드는 건드리지 않아도 됩니다.
            width: 350; height: 350
            x: centerX - (width / 2)
            y: centerY - (height / 2)

            Rectangle {
                id: speedNeedle
                x: 171; y: 35
                width: 5; height: 100
                color: "white"
                radius: 4

                transformOrigin: Item.Bottom
                transform: Rotation {
                    origin.x: speedNeedle.width / 2
                    origin.y: speedNeedle.height
                    angle: clusterBackend.connected ? (-135 + (clusterBackend.speed / 260) * 270) : -135
                    Behavior on angle { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                }
                z: 10
            }

            Rectangle { // 중심 축
                width: 20; height: 20
                anchors.centerIn: parent
                radius: 15
                color: "#2C3E50"
                border.color: "#7F8C8D"
                border.width: 2
                z: 20
            }
        }

        // =======================================================
        // 4. RPM 게이지 바늘 (중심 좌표 기준 배치)
        // =======================================================
        Item {
            // ★★★ 2. RPM 게이지 중심 좌표 지정 ★★★
            // 아래 centerX, centerY 값을 수정하여 RPM 게이지의 중심을 변경하세요.
            property real centerX: 700
            property real centerY: 250

            // 아래 코드는 건드리지 않아도 됩니다.
            width: 350; height: 350
            x: centerX - (width / 2)
            y: centerY - (height / 2)

            Rectangle {
                id: rpmNeedle
                x: 171; y: 35
                width: 6; height: 120
                color: "white"
                radius: 4

                transformOrigin: Item.Bottom
                transform: Rotation {
                    origin.x: rpmNeedle.width / 2
                    origin.y: rpmNeedle.height
                    angle: clusterBackend.connected ? (-135 + (clusterBackend.rpm / 8.0) * 270) : -135
                    Behavior on angle { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                }
                z: 10
            }

            Rectangle { // 중심 축
                width: 30; height: 30
                anchors.centerIn: parent
                radius: 15
                color: "#2C3E50"
                border.color: "#7F8C8D"
                border.width: 2
                z: 20
            }
        }

        // =================================================================
        // 5. ADAS 시각화 (중앙 자동차)
        // =================================================================

        Item {
            // ★★★ 3. ADAS 중앙 자동차 표시 영역 중심 좌표 지정 ★★★
            property real centerX: 800
            property real centerY: 580

            // 아래 코드는 건드리지 않아도 됩니다.
            width: 300; height: 250
            x: centerX - (width / 2)
            y: centerY - (height / 2)
            z: 29

            Image {
                id: myCar
                anchors.centerIn: parent
                source: "qrc:/images/adas_car_top.png"
                width: 80; height: 160
                fillMode: Image.PreserveAspectFit
            }
        }

        // =================================================================
        // 5-1. ADAS 경고 아이콘 (개별 좌표 지정)
        // =================================================================
        // ★★★ 4. ADAS 경고 아이콘 개별 좌표 지정 ★★★
        // 아래 각 Image의 x, y 값을 수정하여 원하는 위치에 아이콘을 배치하세요.
        // =================================================================
        Image {
            id: frontWarningImage
            source: "qrc:/images/adas_warning_front.png"
            x: 600
            y: 250
            width: 120; height: 60
            z: 30
            visible: clusterBackend.frontWarning; opacity: 0
            SequentialAnimation on opacity { running: visible; loops: Animation.Infinite; NumberAnimation { from: 0.4; to: 1.0; duration: 600; } NumberAnimation { from: 1.0; to: 0.4; duration: 800; } }
        }
        Image {
            id: leftWarningImage
            source: "qrc:/images/adas_warning_side.png"
            x: 625
            y: 250
            width: 70; height: 70
            z: 30
            visible: clusterBackend.leftWarning; opacity: 0
            SequentialAnimation on opacity { running: visible; loops: Animation.Infinite; NumberAnimation { from: 0.4; to: 1.0; duration: 600; } NumberAnimation { from: 1.0; to: 0.4; duration: 800; } }
        }
        Image {
            id: rightWarningImage
            source: "qrc:/images/adas_warning_side.png"
            x: 600
            y: 250
            width: 70; height: 70
            z: 30
            transform: Scale { xScale: -1 } // 오른쪽을 보도록 좌우 반전
            visible: clusterBackend.rightWarning; opacity: 0
            SequentialAnimation on opacity { running: visible; loops: Animation.Infinite; NumberAnimation { from: 0.4; to: 1.0; duration: 600; } NumberAnimation { from: 1.0; to: 0.4; duration: 800; } }
        }
        Image {
            id: goAlertImage
            source: "qrc:/images/adas_go_alert.png"
            x: 600
            y: 250
            width: 60; height: 60
            z: 30
            visible: clusterBackend.driveWarning
        }

        // =======================================================
        // 6. 디지털 정보 표시 (하단)
        // =======================================================
        Row {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 20
            spacing: 80

            Text { text: clusterBackend.speed + "<span style='font-size: 20pt;'> km/h</span>"; color: "white"; font.pixelSize: 48; font.bold: true; textFormat: Text.RichText }
            Text { text: clusterBackend.rpm.toFixed(1) + "<span style='font-size: 20pt;'> x1000 rpm</span>"; color: "white"; font.pixelSize: 48; font.bold: true; textFormat: Text.RichText }
        }

        // =======================================================
        // 7. 연결 상태 오버레이
        // =======================================================
        Rectangle {
            anchors.fill: parent; color: "#CC000000"
            visible: !clusterBackend.connected
            z: 50
            Text { anchors.centerIn: parent; text: "CAN 데이터 수신 대기 중..."; color: "white"; font.pixelSize: 24 }
        }
    }
}
*/

/*
import QtQuick 2.6
import QtQuick.Controls 1.4

ApplicationWindow {
    id: root
    visible: true
    visibility: "FullScreen"
    flags: Qt.FramelessWindowHint

    width: 800
    height: 480
    title: "Digital Cluster"

    Rectangle {
        anchors.fill: parent
        color: "black"

        // 1. 계기판 배경 이미지
        Image {
            id: clusterBackground
            anchors.fill: parent
            source: "qrc:/images/cluster-images/cluster_background.png"
            z: 0
        }

        // =======================================================
        // 3. 속도계 바늘 (중심 좌표 기준 배치)
        // =======================================================
        Item {
            // ★★★ 1. 속도계 중심 좌표 지정 (800x480 맞춤) ★★★
            property real centerX: 145
            property real centerY: 250

            // ★★★ 컨테이너 크기 수정 ★★★
            width: 300; height: 300
            x: centerX - (width / 2)
            y: centerY - (height / 2)

            Rectangle {
                id: speedNeedle
                // ★★★ 바늘 위치/크기 수정 ★★★
                x: 147.5 // (컨테이너 너비/2) - (바늘 너비/2) = 150 - 2.5
                y: 50    // (컨테이너 높이/2) - (바늘 높이) = 150 - 100
                width: 4; height: 90
                color: "white"
                radius: 2

                transformOrigin: Item.Bottom
                transform: Rotation {
                    origin.x: speedNeedle.width / 2
                    origin.y: speedNeedle.height
                    angle: clusterBackend.connected ? (-135 + (clusterBackend.speed / 260) * 270) : -135
                    Behavior on angle { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                }
                z: 10
            }

            Rectangle { // 중심 축
                // ★★★ 중심원 크기 수정 ★★★
                width: 15; height: 15
                anchors.centerIn: parent
                radius: 12.5
                color: "#2C3E50"
                border.color: "#7F8C8D"
                border.width: 2
                z: 20
            }
        }

        // =======================================================
        // 4. RPM 게이지 바늘 (중심 좌표 기준 배치)
        // =======================================================
        Item {
            // ★★★ 2. RPM 게이지 중심 좌표 지정 (800x480 맞춤) ★★★
            property real centerX: 690 // 800 - 190 = 610 (좌우 대칭)
            property real centerY: 250

            // ★★★ 컨테이너 크기 수정 ★★★
            width: 300; height: 300
            x: centerX - (width / 2)
            y: centerY - (height / 2)

            Rectangle {
                id: rpmNeedle
                // ★★★ 바늘 위치/크기 수정 ★★★
                x: 147.5 // (컨테이너 너비/2) - (바늘 너비/2) = 150 - 2.5
                y: 50    // (컨테이너 높이/2) - (바늘 높이) = 150 - 100
                width: 5; height: 100
                color: "white"
                radius: 2.5

                transformOrigin: Item.Bottom
                transform: Rotation {
                    origin.x: rpmNeedle.width / 2
                    origin.y: rpmNeedle.height
                    angle: clusterBackend.connected ? (-135 + (clusterBackend.rpm / 8.0) * 270) : -135
                    Behavior on angle { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                }
                z: 10
            }

            Rectangle { // 중심 축
                // ★★★ 중심원 크기 수정 ★★★
                width: 25; height: 25
                anchors.centerIn: parent
                radius: 12.5
                color: "#2C3E50"
                border.color: "#7F8C8D"
                border.width: 2
                z: 20
            }
        }

        // =================================================================
        // 5-1. ADAS 경고 아이콘 (개별 좌표 지정)
        // =================================================================
        // ★★★ 4. ADAS 경고 아이콘 위치/크기 재배치 (800x480 맞춤) ★★★
        Image {
            id: frontWarningImage
            source: "qrc:/images/adas_warning_front.png"
            x: 360 // 화면 중앙
            y: 180
            width: 140; height: 60 // 크기 축소
            z: 30
            visible: clusterBackend.frontWarning; opacity: 0
            SequentialAnimation on opacity { running: visible; loops: Animation.Infinite; NumberAnimation { from: 0.4; to: 1.0; duration: 600; } NumberAnimation { from: 1.0; to: 0.4; duration: 800; } }
        }
        Image {
            id: leftWarningImage
            source: "qrc:/images/adas_warning_side.png"
            x: 320 // 중앙 좌측
            y: 240
            width: 75; height: 75 // 크기 축소
            z: 30
            visible: clusterBackend.leftWarning; opacity: 0
            SequentialAnimation on opacity { running: visible; loops: Animation.Infinite; NumberAnimation { from: 0.4; to: 1.0; duration: 600; } NumberAnimation { from: 1.0; to: 0.4; duration: 800; } }
        }
        Image {
            id: rightWarningImage
            source: "qrc:/images/adas_warning_side.png"
            x: 430 // 중앙 우측
            y: 240
            width: 75; height: 75 // 크기 축소
            z: 30
            transform: Scale { xScale: -1 }
            visible: clusterBackend.rightWarning; opacity: 0
            SequentialAnimation on opacity { running: visible; loops: Animation.Infinite; NumberAnimation { from: 0.4; to: 1.0; duration: 600; } NumberAnimation { from: 1.0; to: 0.4; duration: 800; } }
        }
        Image {
            id: goAlertImage
            source: "qrc:/images/adas_go_alert.png"
            x: 375 // 화면 상단 중앙
            y: 120
            width: 75; height: 75 // 크기 축소
            z: 30
            visible: clusterBackend.driveWarning
        }

        // =======================================================
        // 6. 디지털 정보 표시 (하단)
        // =======================================================
        Row {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 20
            spacing: 80

            // ★★★ 폰트 크기 수정 (800x480 맞춤) ★★★
            Text { text: clusterBackend.speed + "<span style='font-size: 14pt;'> km/h</span>"; color: "white"; font.pixelSize: 28; font.bold: true; textFormat: Text.RichText }
            Text { text: clusterBackend.rpm.toFixed(1) + "<span style='font-size: 14pt;'> x1000 rpm</span>"; color: "white"; font.pixelSize: 28; font.bold: true; textFormat: Text.RichText }
        }

        // =======================================================
        // 7. 연결 상태 오버레이
        // =======================================================
        Rectangle {
            anchors.fill: parent; color: "#CC000000"
            visible: !clusterBackend.connected
            z: 50
            Text { anchors.centerIn: parent; text: "CAN 데이터 수신 대기 중..."; color: "white"; font.pixelSize: 24 }
        }
    }
}
*/

/*
import QtQuick 2.6
import QtQuick.Controls 1.4

ApplicationWindow {
    id: root
    visible: true
    visibility: "FullScreen"
    flags: Qt.FramelessWindowHint

    width: 800
    height: 480
    title: "Digital Cluster"

    Rectangle {
        anchors.fill: parent
        color: "black"

        // 1. 계기판 배경 이미지
        Image {
            id: clusterBackground
            anchors.fill: parent
            source: "qrc:/images/cluster-images/cluster_background.png"
            z: 0
        }

        // =======================================================
        // 3. 속도계 바늘 (기준 스타일)
        // =======================================================
        Item {
            property real centerX: 135
            property real centerY: 250
            width: 300; height: 300
            x: centerX - (width / 2)
            y: centerY - (height / 2)

            Rectangle {
                id: speedNeedle
                x: 147.5
                y: 50
                width: 5; height: 100
                color: "white"
                radius: 2.5

                transformOrigin: Item.Bottom
                transform: Rotation {
                    origin.x: speedNeedle.width / 2
                    origin.y: speedNeedle.height
                    angle: clusterBackend.connected ? (-135 + (clusterBackend.speed / 260) * 270) : -135
                    Behavior on angle { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                }
                z: 10
            }
            Rectangle { // 중심 축
                            // ★★★ 중심원 크기 수정 ★★★
                            width: 20; height: 20
                            anchors.centerIn: parent
                            radius: 10
                            color: "#2C3E50"
                            border.color: "#7F8C8D"
                            border.width: 2
                            z: 20
                        }
        }

        // =======================================================
        // 4. RPM 게이지 바늘 (속도계와 동일하게 수정됨)
        // =======================================================
        Item {
            property real centerX: 665
            property real centerY: 255
            width: 300; height: 300
            x: centerX - (width / 2)
            y: centerY - (height / 2)

            Rectangle {
                id: rpmNeedle
                // ★★★ 속도계와 동일하게 위치 및 스타일 수정 ★★★
                x: 147.5
                y: 50
                width: 5; height: 100
                color: "white"
                radius: 2.5

                transformOrigin: Item.Bottom
                transform: Rotation {
                    origin.x: rpmNeedle.width / 2
                    origin.y: rpmNeedle.height
                    angle: clusterBackend.connected ? (-135 + (clusterBackend.rpm / 8.0) * 270) : -135
                    Behavior on angle { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
                }
                z: 10
            }
            Rectangle { // 중심 축
                // ★★★ 속도계와 동일하게 크기 수정 ★★★
                width: 20; height: 20
                anchors.centerIn: parent
                radius: 10
                color: "#2C3E50"
                border.color: "#7F8C8D"
                border.width: 2
                z: 20
            }
        }

        // ... (ADAS 아이콘 및 하단부는 이전과 동일)
        // =================================================================
        // 5-1. ADAS 경고 아이콘
        // =================================================================
        Image {
            id: frontWarningImage
            source: "qrc:/images/adas_warning_front.png"
            x: 350
            y: 160
            width: 100; height: 65
            z: 30
            visible: clusterBackend.frontWarning; opacity: 0
            SequentialAnimation on opacity { running: visible; loops: Animation.Infinite; NumberAnimation { from: 0.4; to: 1.0; duration: 600; } NumberAnimation { from: 1.0; to: 0.4; duration: 800; } }
        }
        Image {
            id: leftWarningImage
            source: "qrc:/images/adas_warning_side.png"
            x: 268
            y: 260
            width: 90; height: 80
            z: 30
            visible: clusterBackend.leftWarning; opacity: 0
            SequentialAnimation on opacity { running: visible; loops: Animation.Infinite; NumberAnimation { from: 0.4; to: 1.0; duration: 600; } NumberAnimation { from: 1.0; to: 0.4; duration: 800; } }
        }
        Image {
            id: rightWarningImage
            source: "qrc:/images/adas_warning_side.png"
            x: 532
            y: 260
            width: 90; height: 80
            z: 30
            transform: Scale { xScale: -1 }
            visible: clusterBackend.rightWarning; opacity: 0
            SequentialAnimation on opacity { running: visible; loops: Animation.Infinite; NumberAnimation { from: 0.4; to: 1.0; duration: 600; } NumberAnimation { from: 1.0; to: 0.4; duration: 800; } }
        }
        Image {
            id: goAlertImage
            source: "qrc:/images/adas_go_alert.png"
            x: 347
            y: 80
            width: 105; height: 100
            z: 30
            visible: clusterBackend.driveWarning
        }

        // =======================================================
        // 6. 디지털 정보 표시 (하단)
        // =======================================================
        Row {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 20
            spacing: 80
            Text { text: clusterBackend.speed + "<span style='font-size: 14pt;'> km/h</span>"; color: "white"; font.pixelSize: 28; font.bold: true; textFormat: Text.RichText }
            Text { text: clusterBackend.rpm.toFixed(1) + "<span style='font-size: 14pt;'> x1000 rpm</span>"; color: "white"; font.pixelSize: 28; font.bold: true; textFormat: Text.RichText }
        }


        Text {
                    x: 80 // 속도 텍스트 x 좌표
                    y: 370 // 속도 텍스트 y 좌표

                    text: clusterBackend.speed + "<span style='font-size: 14pt;'> km/h</span>"
                    color: "white"; font.pixelSize: 28; font.bold: true; textFormat: Text.RichText
                }

                Text {
                    x: 590 // RPM 텍스트 x 좌표
                    y: 370 // RPM 텍스트 y 좌표

                    text: clusterBackend.rpm.toFixed(1) + "<span style='font-size: 14pt;'> rpm</span>"
                    color: "white"; font.pixelSize: 28; font.bold: true; textFormat: Text.RichText
                }

        // =======================================================
        // 7. 연결 상태 오버레이
        // =======================================================
        Rectangle {
            anchors.fill: parent; color: "#CC000000"
            visible: !clusterBackend.connected
            z: 50
            Text { anchors.centerIn: parent; text: "CAN 데이터 수신 대기 중..."; color: "white"; font.pixelSize: 24 }
        }
    }
}
*/

import QtQuick 2.6
import QtQuick.Controls 1.4

ApplicationWindow {
    id: root
    visible: true
    visibility: "FullScreen"
    flags: Qt.FramelessWindowHint

    width: 800
    height: 480
    title: "Digital Cluster"

    Rectangle {
        anchors.fill: parent
        color: "black"

        // 1. 계기판 배경 이미지
        Image {
            id: clusterBackground
            anchors.fill: parent
            source: "qrc:/images/cluster-images/cluster_background.png"
            z: 0
        }

        // =======================================================
        // 3. 속도계 바늘 (기준 스타일)
        // =======================================================
        Item {
            property real centerX: 135
            property real centerY: 250
            width: 300; height: 300
            x: centerX - (width / 2)
            y: centerY - (height / 2)

            Rectangle {
                id: speedNeedle
                x: 147.5
                y: 50
                width: 5; height: 100
                color: "white"
                radius: 2.5

                transformOrigin: Item.Bottom
                transform: Rotation {
                    origin.x: speedNeedle.width / 2
                    origin.y: speedNeedle.height
                    angle: clusterBackend.connected ? (-135 + (clusterBackend.speed / 260) * 270) : -135
                    Behavior on angle { NumberAnimation { duration: 400; easing.type: Easing.OutQuad } }
                }
                z: 10
            }
            Rectangle { // 중심 축
                width: 20; height: 20
                anchors.centerIn: parent
                radius: 10
                color: "#2C3E50"
                border.color: "#7F8C8D"
                border.width: 2
                z: 20
            }
        }

        // =======================================================
        // 4. RPM 게이지 바늘 (실시간 값 반영되도록 수정됨)
        // =======================================================
        Item {
            property real centerX: 665
            property real centerY: 255
            width: 300; height: 300
            x: centerX - (width / 2)
            y: centerY - (height / 2)

            Rectangle {
                id: rpmNeedle
                x: 147.5
                y: 50
                width: 5; height: 100
                color: "white"
                radius: 2.5

                transformOrigin: Item.Bottom
                transform: Rotation {
                    origin.x: rpmNeedle.width / 2
                    origin.y: rpmNeedle.height

                    angle: clusterBackend.connected ? (-135 + (clusterBackend.rpm / 8000.0) * 291) : -135
                    Behavior on angle { NumberAnimation { duration: 400; easing.type: Easing.InOutQuad } }
                }
                z: 10
            }
            Rectangle { // 중심 축
                width: 20; height: 20
                anchors.centerIn: parent
                radius: 10
                color: "#2C3E50"
                border.color: "#7F8C8D"
                border.width: 2
                z: 20
            }
        }

        // =================================================================
        // 5-1. ADAS 경고 아이콘
        // =================================================================
        Image {
            id: frontWarningImage
            source: "qrc:/images/adas_warning_front.png"
            x: 350
            y: 160
            width: 100; height: 65
            z: 30
            visible: clusterBackend.frontWarning; opacity: 0
            SequentialAnimation on opacity { running: visible; loops: Animation.Infinite; NumberAnimation { from: 0.4; to: 1.0; duration: 600; } NumberAnimation { from: 1.0; to: 0.4; duration: 800; } }
        }
        Image {
            id: leftWarningImage
            source: "qrc:/images/adas_warning_side.png"
            x: 268
            y: 260
            width: 90; height: 80
            z: 30
            visible: clusterBackend.leftWarning; opacity: 0
            SequentialAnimation on opacity { running: visible; loops: Animation.Infinite; NumberAnimation { from: 0.4; to: 1.0; duration: 600; } NumberAnimation { from: 1.0; to: 0.4; duration: 800; } }
        }
        Image {
            id: rightWarningImage
            source: "qrc:/images/adas_warning_side.png"
            x: 532
            y: 260
            width: 90; height: 80
            z: 30
            transform: Scale { xScale: -1 }
            visible: clusterBackend.rightWarning; opacity: 0
            SequentialAnimation on opacity { running: visible; loops: Animation.Infinite; NumberAnimation { from: 0.4; to: 1.0; duration: 600; } NumberAnimation { from: 1.0; to: 0.4; duration: 800; } }
        }
        Image {
            id: goAlertImage
            source: "qrc:/images/adas_go_alert.png"
            x: 347
            y: 80
            width: 105; height: 100
            z: 30
            visible: clusterBackend.driveWarning
        }

        // =======================================================
        // 6. 디지털 정보 표시 (하단)
        // =======================================================
        Text {
            x: 80 // 속도 텍스트 x 좌표
            y: 370 // 속도 텍스트 y 좌표

            text: clusterBackend.speed + "<span style='font-size: 14pt;'> km/h</span>"
            color: "white"; font.pixelSize: 28; font.bold: true; textFormat: Text.RichText
        }

        Text {
            x: 605 // RPM 텍스트 x 좌표
            y: 370 // RPM 텍스트 y 좌표

            text: clusterBackend.rpm.toFixed(0) + "<span style='font-size: 14pt;'> rpm</span>"
            color: "white"; font.pixelSize: 28; font.bold: true; textFormat: Text.RichText
        }

        // =======================================================
        // 7. 연결 상태 오버레이
        // =======================================================
        Rectangle {
            anchors.fill: parent; color: "#CC000000"
            visible: !clusterBackend.connected
            z: 50
            Text { anchors.centerIn: parent; text: "CAN 데이터 수신 대기 중..."; color: "white"; font.pixelSize: 24 }
        }
    }
}
