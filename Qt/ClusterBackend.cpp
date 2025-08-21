#include "ClusterBackend.h"
#include <QDebug>
#include <QFile>

// ★ 수정: UI 테스트 코드의 fmod 함수를 사용하기 위해 <cmath> 헤더 추가
#include <cmath> 

// ★ 수정: UI 테스트를 위해 <QTimer> 헤더 추가
#include <QTimer>

ClusterBackend::ClusterBackend(QObject *parent)
    : QObject(parent)
{
    // 기존 UDS 서버 리스닝 코드는 잠시 주석 처리합니다.
#if 01
    QFile::remove("/tmp/can_qt_server");

    connect(&m_server, &QLocalServer::newConnection,
            this, &ClusterBackend::onNewConnection);

    if (!m_server.listen("/tmp/can_qt_server")) {
        qWarning() << "Server listen failed:" << m_server.errorString();
    } else {
        qDebug() << "QLocalServer listening on /tmp/can_qt_server";
    }
#endif

    // ==========================================================
    // ===== UI 테스트를 위한 타이머 코드 (이 부분을 추가) =====
    // ==========================================================
#if 0
    QTimer *testTimer = new QTimer(this);
    
    connect(testTimer, &QTimer::timeout, this, [this]() {
        int newSpeed = (m_speed + 2) % 260;
        if (m_speed != newSpeed) {
            m_speed = newSpeed;
            emit speedChanged();
        }
        
        // fmod 함수를 사용하여 double 타입의 RPM 값 순환
        double newRpm = fmod(m_rpm + 0.1, 8.0);
        if (m_rpm != newRpm) {
            m_rpm = newRpm;
            emit rpmChanged();
        }

        // 모든 경고 플래그를 강제로 true로 설정
        if (!m_frontWarning) { m_frontWarning = true; emit frontWarningChanged(); }
        if (!m_leftWarning)  { m_leftWarning = true;  emit leftWarningChanged(); }
        if (!m_rightWarning) { m_rightWarning = true; emit rightWarningChanged(); }
        if (!m_driveWarning) { m_driveWarning = true; emit driveWarningChanged(); }

        if (!m_connected) { m_connected = true; emit connectedChanged(); }
    });
    
    testTimer->start(100);
    qDebug() << "===== UI TEST MODE ACTIVATED =====";
#endif
}

void ClusterBackend::onNewConnection()
{
    m_client = m_server.nextPendingConnection();
    if (!m_client) return;

    m_connected = true;
    emit connectedChanged();
    connect(m_client, &QLocalSocket::readyRead, this, &ClusterBackend::onReadyRead);
    
    // 클라이언트 연결이 끊겼을 때 처리
    connect(m_client, &QLocalSocket::disconnected, this, [this](){
        m_connected = false;
        emit connectedChanged();
        m_client->deleteLater();
        m_client = nullptr;
    });
}

void ClusterBackend::onReadyRead() {
    if (!m_client) return;

    while (m_client->bytesAvailable() >= static_cast<qint64>(sizeof(ClusterStatus))) {
        ClusterStatus s;
        
        // ★ 수정: signed/unsigned 비교 경고를 해결하기 위해 형 변환(casting) 추가
        if (m_client->read(reinterpret_cast<char*>(&s), sizeof(s)) < static_cast<qint64>(sizeof(s))) {
            return;
        }

        if (m_speed != s.speed) { m_speed = s.speed; emit speedChanged(); }
        
        // RPM은 double 타입으로 처리
        double newRpm = static_cast<double>(s.rpm);
        if (m_rpm != newRpm) { m_rpm = newRpm; emit rpmChanged(); }

        if (m_frontWarning != static_cast<bool>(s.frontWarning)) {
            m_frontWarning = static_cast<bool>(s.frontWarning); emit frontWarningChanged();
        }
        if (m_leftWarning != static_cast<bool>(s.leftWarning)) {
            m_leftWarning = static_cast<bool>(s.leftWarning); emit leftWarningChanged();
        }
        if (m_rightWarning != static_cast<bool>(s.rightWarning)) {
            m_rightWarning = static_cast<bool>(s.rightWarning); emit rightWarningChanged();
        }
        if (m_driveWarning != static_cast<bool>(s.driveWarning)) {
            m_driveWarning = static_cast<bool>(s.driveWarning); emit driveWarningChanged();
        }
    }
}
