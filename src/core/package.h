#pragma once

#include <QString>

namespace yas {

// Common package model shared by every YAS store adapter.
struct Package {
    QString id;                // stable identifier used in CLI commands (name/token)
    QString name;              // display name
    QString version;           // latest/available version
    QString installedVersion;  // empty when not installed
    QString description;
    QString homepage;
    QString source;            // tap / bucket / repo / remote the package comes from
    QString kind;              // manager-specific: formula, cask, app, runtime, aur...
    bool pinned = false;

    bool installed() const { return !installedVersion.isEmpty(); }
    bool outdated() const
    {
        return installed() && !version.isEmpty() && version != installedVersion;
    }
};

} // namespace yas
