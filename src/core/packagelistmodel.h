#pragma once

#include <QAbstractListModel>
#include <QList>
#include <QVector>

#include "package.h"

namespace yas {

// List model over Package with a client-side text filter (name + description).
class PackageListModel : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(QString filter READ filter WRITE setFilter NOTIFY filterChanged)
public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        NameRole,
        VersionRole,
        InstalledVersionRole,
        DescriptionRole,
        HomepageRole,
        SourceRole,
        KindRole,
        PinnedRole,
        InstalledRole,
        OutdatedRole,
    };

    explicit PackageListModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = {}) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void setPackages(QList<Package> packages);
    const QList<Package> &packages() const { return m_all; }

    int count() const { return int(m_visible.size()); }
    QString filter() const { return m_filter; }
    void setFilter(const QString &filter);

    Q_INVOKABLE QVariantMap get(int row) const;

    static QVariantMap toMap(const Package &package);

signals:
    void countChanged();
    void filterChanged();

private:
    void rebuild();

    QList<Package> m_all;
    QVector<int> m_visible;
    QString m_filter;
};

} // namespace yas
