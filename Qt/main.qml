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

        // 배경 이미지
        Image {
            id: clusterBackground
            anchors.fill: parent
            source: "qrc:/images/cluster-images/cluster_background.png"
            z: 0
        }

        // 속도계 바늘
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

            Rectangle {
                width: 20; height: 20
                anchors.centerIn: parent
                radius: 10
                color: "#2C3E50"
                border.color: "#7F8C8D"
                border.width: 2
                z: 20
            }
        }

        // RPM 게이지 바늘
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

            Rectangle {
                width: 20; height: 20
                anchors.centerIn: parent
                radius: 10
                color: "#2C3E50"
                border.color: "#7F8C8D"
                border.width: 2
                z: 20
            }
        }

        // ADAS 경고 아이콘들
        Image {
            id: frontWarningImage
            source: "qrc:/images/adas_warning_front.png"
            x: 350; y: 160
            width: 100; height: 65
            z: 30
            visible: clusterBackend.frontWarning
            opacity: visible ? 1 : 0
            SequentialAnimation on opacity {
                running: visible
                loops: Animation.Infinite
                NumberAnimation { from: 0.4; to: 1.0; duration: 600 }
                NumberAnimation { from: 1.0; to: 0.4; duration: 800 }
            }
        }
        Image {
            id: leftWarningImage
            source: "qrc:/images/adas_warning_side.png"
            x: 268; y: 260
            width: 90; height: 80
            z: 30
            visible: clusterBackend.leftWarning
            opacity: visible ? 1 : 0
            SequentialAnimation on opacity {
                running: visible
                loops: Animation.Infinite
                NumberAnimation { from: 0.4; to: 1.0; duration: 600 }
                NumberAnimation { from: 1.0; to: 0.4; duration: 800 }
            }
        }
        Image {
            id: rightWarningImage
            source: "qrc:/images/adas_warning_side.png"
            x: 532; y: 260
            width: 90; height: 80
            z: 30
            transform: Scale { xScale: -1 }
            visible: clusterBackend.rightWarning
            opacity: visible ? 1 : 0
            SequentialAnimation on opacity {
                running: visible
                loops: Animation.Infinite
                NumberAnimation { from: 0.4; to: 1.0; duration: 600 }
                NumberAnimation { from: 1.0; to: 0.4; duration: 800 }
            }
        }
        Image {
            id: goAlertImage
            source: "qrc:/images/adas_go_alert.png"
            x: 347; y: 80
            width: 105; height: 100
            z: 30
            visible: clusterBackend.driveWarning
        }

        // 디지털 정보 표시 (속도 및 RPM)
        Text {
            x: 80
            y: 370
            text: clusterBackend.speed + "<span style='font-size: 14pt;'> km/h</span>"
            color: "white"
            font.pixelSize: 28
            font.bold: true
            textFormat: Text.RichText
        }
        Text {
            x: 605
            y: 370
            text: clusterBackend.rpm.toFixed(0) + "<span style='font-size: 14pt;'> rpm</span>"
            color: "white"
            font.pixelSize: 28
            font.bold: true
            textFormat: Text.RichText
        }

        // 연결 상태 오버레이
        Rectangle {
            anchors.fill: parent
            color: "#CC000000"
            visible: !clusterBackend.connected
            z: 50

            Text {
                anchors.centerIn: parent
                text: "CAN 데이터 수신 대기 중..."
                color: "white"
                font.pixelSize: 24
            }
        }
    }
}
