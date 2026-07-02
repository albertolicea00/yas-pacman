#include "commandlog.h"

#include <QDir>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QSaveFile>
#include <QStandardPaths>

namespace yas {

CommandLog::CommandLog(QObject *parent)
    : QAbstractListModel(parent)
{
    load();
}

int CommandLog::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : int(m_entries.size());
}

QVariant CommandLog::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_entries.size())
        return {};
    const Entry &e = m_entries.at(index.row());
    switch (role) {
    case CommandLineRole: return e.commandLine;
    case TimestampRole: return e.startedAt;
    case ExitCodeRole: return e.exitCode;
    case RunningRole: return e.exitCode == -999;
    case SucceededRole: return e.exitCode == 0;
    case DurationMsRole: return e.durationMs;
    }
    return {};
}

QHash<int, QByteArray> CommandLog::roleNames() const
{
    return {
        {CommandLineRole, "commandLine"},
        {TimestampRole, "timestamp"},
        {ExitCodeRole, "exitCode"},
        {RunningRole, "running"},
        {SucceededRole, "succeeded"},
        {DurationMsRole, "durationMs"},
    };
}

void CommandLog::commandStarted(const QString &commandLine)
{
    beginInsertRows({}, 0, 0);
    m_entries.prepend({commandLine, QDateTime::currentDateTime()});
    endInsertRows();
    if (m_entries.size() > MaxEntries) {
        beginRemoveRows({}, int(m_entries.size()) - 1, int(m_entries.size()) - 1);
        m_entries.removeLast();
        endRemoveRows();
    }
    emit countChanged();
}

void CommandLog::commandFinished(int exitCode)
{
    if (m_entries.isEmpty())
        return;
    Entry &e = m_entries.first();
    e.exitCode = exitCode;
    e.durationMs = e.startedAt.msecsTo(QDateTime::currentDateTime());
    emit dataChanged(index(0), index(0));
    save();
}

void CommandLog::clear()
{
    beginResetModel();
    m_entries.clear();
    endResetModel();
    emit countChanged();
    save();
}

QString CommandLog::storagePath() const
{
    const QString dir =
        QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(dir);
    return dir + QStringLiteral("/command-history.json");
}

void CommandLog::load()
{
    QFile file(storagePath());
    if (!file.open(QIODevice::ReadOnly))
        return;
    const QJsonArray array = QJsonDocument::fromJson(file.readAll()).array();
    beginResetModel();
    m_entries.clear();
    for (const auto &value : array) {
        const QJsonObject obj = value.toObject();
        Entry e;
        e.commandLine = obj.value(QStringLiteral("command")).toString();
        e.startedAt = QDateTime::fromString(
            obj.value(QStringLiteral("startedAt")).toString(), Qt::ISODate);
        e.exitCode = obj.value(QStringLiteral("exitCode")).toInt(-1);
        e.durationMs = qint64(obj.value(QStringLiteral("durationMs")).toDouble());
        m_entries.append(e);
    }
    endResetModel();
    emit countChanged();
}

void CommandLog::save() const
{
    QJsonArray array;
    for (const Entry &e : m_entries) {
        if (e.exitCode == -999)
            continue; // never persist in-flight commands
        array.append(QJsonObject{
            {QStringLiteral("command"), e.commandLine},
            {QStringLiteral("startedAt"), e.startedAt.toString(Qt::ISODate)},
            {QStringLiteral("exitCode"), e.exitCode},
            {QStringLiteral("durationMs"), double(e.durationMs)},
        });
    }
    QSaveFile file(storagePath());
    if (!file.open(QIODevice::WriteOnly))
        return;
    file.write(QJsonDocument(array).toJson(QJsonDocument::Compact));
    file.commit();
}

} // namespace yas
