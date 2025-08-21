#include "ClusterBackend.h"
#include <QFile>
#include <cmath>
#include <QTimer>

ClusterBackend::ClusterBackend(QObject *parent)
    : QObject(parent)
{
    // 기존 UDS 서버 설정 및 시작
    QFile::remove("/tmp/can_qt_server");

    connect(&m_server, &QLocalServer::newConnection,
            this, &ClusterBackend::onNewConnection);

    if (!m_server.listen("/tmp/can_qt_server")) {
        qWarning() << "Server listen failed:" << m_server.errorString();
    }
}

// 클라이언트가 새로 연결되었을 때 호출
void ClusterBackend::onNewConnection()
{
    m_client = m_server.nextPendingConnection();
    if (!m_client) return;

    m_connected = true;
    emit connectedChanged();

    connect(m_client, &QLocalSocket::readyRead,
            this, &ClusterBackend::onReadyRead);

    // 클라이언트 연결 해제시 처리
    connect(m_client, &QLocalSocket::disconnected, this, [this]() {
        m_connected = false;
        emit connectedChanged();
        m_client->deleteLater();
        m_client = nullptr;
    });
}

// 클라이언트로부터 데이터 수신시 호출
void ClusterBackend::onReadyRead() {
    if (!m_client) return;

    while (m_client->bytesAvailable() >= static_cast<qint64>(sizeof(ClusterStatus))) {
        ClusterStatus s;

        // 안전하게 데이터 읽기
        if (m_client->read(reinterpret_cast<char*>(&s), sizeof(s)) < static_cast<qint64>(sizeof(s))) {
            return;
        }

        if (m_speed != s.speed) {
            m_speed = s.speed;
            emit speedChanged();
        }

        double newRpm = static_cast<double>(s.rpm);
        if (m_rpm != newRpm) {
            m_rpm = newRpm;
            emit rpmChanged();
        }

        if (m_frontWarning != static_cast<bool>(s.frontWarning)) {
            m_frontWarning = static_cast<bool>(s.frontWarning);
            emit frontWarningChanged();
        }
        if (m_leftWarning != static_cast<bool>(s.leftWarning)) {
            m_leftWarning = static_cast<bool>(s.leftWarning);
            emit leftWarningChanged();
        }
        if (m_rightWarning != static_cast<bool>(s.rightWarning)) {
            m_rightWarning = static_cast<bool>(s.rightWarning);
            emit rightWarningChanged();
        }
        if (m_driveWarning != static_cast<bool>(s.driveWarning)) {
            m_driveWarning = static_cast<bool>(s.driveWarning);
            emit driveWarningChanged();
        }
    }
}
