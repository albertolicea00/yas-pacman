#pragma once

#include "repository.h"
#include <QObject>
#include <QVector>

class RepositoryManager : public QObject {
    Q_OBJECT

public:
    explicit RepositoryManager(QObject *parent = nullptr);

    QVector<Repository> repositories() const;
    void loadRepositories(const QString &basePath);
    void pushRepository(const Repository &repo);
    void pullRepository(const Repository &repo);
    Repository getRepository(const QString &name) const;

private:
    QVector<Repository> m_repositories;
};
