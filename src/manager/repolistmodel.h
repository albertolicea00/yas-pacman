#pragma once

#include "repository.h"
#include <QAbstractListModel>
#include <QVector>

class RepoListModel : public QAbstractListModel {
    Q_OBJECT

public:
    enum Role {
        NameRole = Qt::UserRole + 1,
        PathRole,
        BranchRole,
        StatusRole,
        CommitCountRole,
        DescriptionRole
    };
    Q_ENUM(Role)

    explicit RepoListModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

    void setRepositories(const QVector<Repository> &repos);

private:
    QVector<Repository> m_repositories;
};
