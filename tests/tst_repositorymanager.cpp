#include <QTest>
#include "repositorymanager.h"

class TestRepositoryManager : public QObject {
    Q_OBJECT

private slots:
    void testLoadRepositories();
    void testGetRepository();
};

void TestRepositoryManager::testLoadRepositories() {
    RepositoryManager manager;
    manager.loadRepositories("/Users/albertolicea00/Develop/yas-stores");

    const auto &repos = manager.repositories();
    QVERIFY(!repos.isEmpty());
    QVERIFY(repos.count() >= 1);
}

void TestRepositoryManager::testGetRepository() {
    RepositoryManager manager;
    manager.loadRepositories("/Users/albertolicea00/Develop/yas-stores");

    Repository repo = manager.getRepository("yas-core");
    QCOMPARE(repo.name, QString("yas-core"));
}

QTEST_MAIN(TestRepositoryManager)
#include "tst_repositorymanager.moc"
