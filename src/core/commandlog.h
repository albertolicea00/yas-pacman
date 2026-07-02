#pragma once

#include <QAbstractListModel>
#include <QDateTime>
#include <QVector>

namespace yas {

// Persistent history of every CLI command the app ran ("Command Reminder
// Companion"). Newest first. Stored as JSON under AppDataLocation.
class CommandLog : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
public:
    enum Roles {
        CommandLineRole = Qt::UserRole + 1,
        TimestampRole,
        ExitCodeRole,
        RunningRole,
        SucceededRole,
        DurationMsRole,
    };

    explicit CommandLog(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = {}) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void commandStarted(const QString &commandLine);
    void commandFinished(int exitCode);

    Q_INVOKABLE void clear();

signals:
    void countChanged();

private:
    struct Entry {
        QString commandLine;
        QDateTime startedAt;
        int exitCode = -999; // -999 while running
        qint64 durationMs = 0;
    };

    QString storagePath() const;
    void load();
    void save() const;

    QVector<Entry> m_entries;
    static constexpr int MaxEntries = 500;
};

} // namespace yas
