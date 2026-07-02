#include "repositorymanager.h"
#include <QDir>
#include <QProcess>
#include <QDateTime>

RepositoryManager::RepositoryManager(QObject *parent)
    : QObject(parent) {}

QVector<Repository> RepositoryManager::repositories() const {
    return m_repositories;
}

void RepositoryManager::loadRepositories(const QString &basePath) {
    m_repositories.clear();

    QDir dir(basePath);
    dir.setFilter(QDir::Dirs | QDir::NoDotAndDotDot);

    for (const QString &dirName : dir.entryList()) {
        if (!dirName.startsWith("yas-")) continue;

        QString repoPath = dir.filePath(dirName);
        if (!QDir(repoPath + "/.git").exists()) continue;

        Repository repo;
        repo.name = dirName;
        repo.path = repoPath;
        repo.branch = "main";
        repo.status = "clean";
        repo.commitCount = 0;
        repo.lastUpdated = QDateTime::currentDateTime();
        repo.description = "Repository: " + dirName;

        m_repositories.append(repo);
    }
}

void RepositoryManager::pushRepository(const Repository &repo) {
    QProcess process;
    process.setWorkingDirectory(repo.path);
    process.start("git", {"push"});
    process.waitForFinished();
}

void RepositoryManager::pullRepository(const Repository &repo) {
    QProcess process;
    process.setWorkingDirectory(repo.path);
    process.start("git", {"pull"});
    process.waitForFinished();
}

Repository RepositoryManager::getRepository(const QString &name) const {
    for (const auto &repo : m_repositories) {
        if (repo.name == name) return repo;
    }
    return Repository();
}
