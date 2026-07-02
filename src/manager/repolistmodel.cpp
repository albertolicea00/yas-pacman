#include "repolistmodel.h"

RepoListModel::RepoListModel(QObject *parent)
    : QAbstractListModel(parent) {}

int RepoListModel::rowCount(const QModelIndex &parent) const {
    if (parent.isValid()) return 0;
    return m_repositories.count();
}

QVariant RepoListModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid() || index.row() >= m_repositories.count())
        return QVariant();

    const Repository &repo = m_repositories.at(index.row());

    switch (role) {
        case NameRole: return repo.name;
        case PathRole: return repo.path;
        case BranchRole: return repo.branch;
        case StatusRole: return repo.status;
        case CommitCountRole: return repo.commitCount;
        case DescriptionRole: return repo.description;
        default: return QVariant();
    }
}

QHash<int, QByteArray> RepoListModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[NameRole] = "name";
    roles[PathRole] = "path";
    roles[BranchRole] = "branch";
    roles[StatusRole] = "status";
    roles[CommitCountRole] = "commitCount";
    roles[DescriptionRole] = "description";
    return roles;
}

void RepoListModel::setRepositories(const QVector<Repository> &repos) {
    beginResetModel();
    m_repositories = repos;
    endResetModel();
}
