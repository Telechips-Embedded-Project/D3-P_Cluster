#pragma once
#include <QObject>
#include <QLocalServer>
#include <QLocalSocket>
#include <stdint.h>

struct ClusterStatus {
    int speed;
    int rpm;

    int frontWarning;   // 근접 경고
    int leftWarning;
    int rightWarning;

    int driveWarning;   // 재출발 경고

};

class ClusterBackend : public QObject {
    Q_OBJECT
    Q_PROPERTY(int speed READ speed NOTIFY speedChanged)
    Q_PROPERTY(int rpm READ rpm NOTIFY rpmChanged)

    Q_PROPERTY(bool frontWarning READ frontWarning NOTIFY frontWarningChanged)
    Q_PROPERTY(bool leftWarning READ leftWarning NOTIFY leftWarningChanged)
    Q_PROPERTY(bool rightWarning READ rightWarning NOTIFY rightWarningChanged)
    Q_PROPERTY(bool driveWarning READ driveWarning NOTIFY driveWarningChanged)

    Q_PROPERTY(bool connected READ connected NOTIFY connectedChanged)

public:
    explicit ClusterBackend(QObject *parent = nullptr);

    int speed() const { return m_speed; }
    int rpm() const { return m_rpm; }

    bool frontWarning() const { return m_frontWarning; }
    bool leftWarning() const { return m_leftWarning; }
    bool rightWarning() const { return m_rightWarning; }
    bool driveWarning() const { return m_driveWarning; }

    bool connected() const { return m_connected; }

signals:
    void speedChanged();
    void rpmChanged();
    void frontWarningChanged();
    void leftWarningChanged();
    void rightWarningChanged();
    void driveWarningChanged();
    void connectedChanged();

private slots:
    void onNewConnection();
    void onReadyRead();

private:
    QLocalServer m_server;
    QLocalSocket *m_client = nullptr;
    int m_speed = 0;
    int m_rpm = 0;
    bool m_frontWarning = false;
    bool m_leftWarning = false;
    bool m_rightWarning = false;
    bool m_driveWarning = false;
    bool m_connected = false;
};
