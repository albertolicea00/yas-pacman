#pragma once

#include <QString>
#include <QDateTime>

struct Repository {
    QString name;
    QString path;
    QString branch;
    QString status; // "clean", "dirty"
    int commitCount = 0;
    QDateTime lastUpdated;
    QString description;
};
