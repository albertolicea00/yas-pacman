#include "packagelistmodel.h"

namespace yas {

PackageListModel::PackageListModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

int PackageListModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : count();
}

QVariant PackageListModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_visible.size())
        return {};
    const Package &p = m_all.at(m_visible.at(index.row()));
    switch (role) {
    case IdRole: return p.id;
    case NameRole: return p.name;
    case VersionRole: return p.version;
    case InstalledVersionRole: return p.installedVersion;
    case DescriptionRole: return p.description;
    case HomepageRole: return p.homepage;
    case SourceRole: return p.source;
    case KindRole: return p.kind;
    case PinnedRole: return p.pinned;
    case InstalledRole: return p.installed();
    case OutdatedRole: return p.outdated();
    }
    return {};
}

QHash<int, QByteArray> PackageListModel::roleNames() const
{
    return {
        {IdRole, "packageId"},
        {NameRole, "name"},
        {VersionRole, "version"},
        {InstalledVersionRole, "installedVersion"},
        {DescriptionRole, "description"},
        {HomepageRole, "homepage"},
        {SourceRole, "source"},
        {KindRole, "kind"},
        {PinnedRole, "pinned"},
        {InstalledRole, "installed"},
        {OutdatedRole, "outdated"},
    };
}

void PackageListModel::setPackages(QList<Package> packages)
{
    beginResetModel();
    m_all = std::move(packages);
    rebuild();
    endResetModel();
    emit countChanged();
}

void PackageListModel::setFilter(const QString &filter)
{
    if (m_filter == filter)
        return;
    m_filter = filter;
    beginResetModel();
    rebuild();
    endResetModel();
    emit filterChanged();
    emit countChanged();
}

void PackageListModel::setKindFilter(const QString &kind)
{
    if (m_kindFilter == kind)
        return;
    m_kindFilter = kind;
    beginResetModel();
    rebuild();
    endResetModel();
    emit filterChanged();
    emit countChanged();
}

QVariantMap PackageListModel::get(int row) const
{
    if (row < 0 || row >= m_visible.size())
        return {};
    return toMap(m_all.at(m_visible.at(row)));
}

QVariantMap PackageListModel::toMap(const Package &p)
{
    return {
        {QStringLiteral("packageId"), p.id},
        {QStringLiteral("name"), p.name},
        {QStringLiteral("version"), p.version},
        {QStringLiteral("installedVersion"), p.installedVersion},
        {QStringLiteral("description"), p.description},
        {QStringLiteral("homepage"), p.homepage},
        {QStringLiteral("source"), p.source},
        {QStringLiteral("kind"), p.kind},
        {QStringLiteral("pinned"), p.pinned},
        {QStringLiteral("installed"), p.installed()},
        {QStringLiteral("outdated"), p.outdated()},
    };
}

int PackageListModel::pinnedCount() const
{
    int count = 0;
    for (const Package &p : m_all) {
        if (p.pinned)
            ++count;
    }
    return count;
}

QVariantList PackageListModel::kindSummary() const
{
    QMap<QString, int> counts; // QMap keeps a stable (sorted) order
    for (const Package &p : m_all)
        counts[p.kind]++;
    QVariantList list;
    for (auto it = counts.constBegin(); it != counts.constEnd(); ++it) {
        list.append(QVariantMap{
            {QStringLiteral("kind"), it.key()},
            {QStringLiteral("count"), it.value()},
        });
    }
    return list;
}

void PackageListModel::rebuild()
{
    m_visible.clear();
    m_visible.reserve(m_all.size());
    const QString needle = m_filter.trimmed();
    for (int i = 0; i < m_all.size(); ++i) {
        if (!m_kindFilter.isEmpty() && m_all.at(i).kind != m_kindFilter)
            continue;
        if (needle.isEmpty()
            || m_all.at(i).name.contains(needle, Qt::CaseInsensitive)
            || m_all.at(i).description.contains(needle, Qt::CaseInsensitive)) {
            m_visible.append(i);
        }
    }
}

} // namespace yas
