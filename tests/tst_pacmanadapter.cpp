#include <QTest>

#include "pacmanadapter.h"

class TestPacmanAdapter : public QObject {
    Q_OBJECT
private slots:
    void searchParsesTwoLineEntries()
    {
        PacmanAdapter adapter;
        const auto packages = adapter.parseSearch(QStringLiteral(
            "extra/jq 1.7.1-2\n"
            "    Command-line JSON processor\n"
            "core/curl 8.8.0-1 [installed]\n"
            "    command line tool for transferring data\n"));
        QCOMPARE(packages.size(), 2);
        QCOMPARE(packages.at(0).id, QStringLiteral("jq"));
        QCOMPARE(packages.at(0).source, QStringLiteral("extra"));
        QCOMPARE(packages.at(0).description, QStringLiteral("Command-line JSON processor"));
        QVERIFY(!packages.at(0).installed());
        QVERIFY(packages.at(1).installed());
    }

    void outdatedParsesArrowFormat()
    {
        PacmanAdapter adapter;
        const auto packages = adapter.parseOutdated(QStringLiteral(
            "curl 8.7.1-1 -> 8.8.0-1\n"));
        QCOMPARE(packages.size(), 1);
        QCOMPARE(packages.at(0).installedVersion, QStringLiteral("8.7.1-1"));
        QCOMPARE(packages.at(0).version, QStringLiteral("8.8.0-1"));
        QVERIFY(packages.at(0).outdated());
    }

    void neverIssuesBareSy()
    {
        PacmanAdapter adapter;
        // -Sy alone causes partial upgrades that break Arch — assert every
        // command either avoids -Sy or pairs it with u (-Syu).
        const QList<yas::CliCommand> commands = {
            adapter.installCommand("x", ""), adapter.uninstallCommand("x", ""),
            adapter.upgradeCommand("x", ""), adapter.upgradeAllCommand(),
            adapter.searchCommand("x"), adapter.listOutdatedCommand(),
        };
        for (const auto &cmd : commands)
            QVERIFY(!cmd.arguments.contains(QStringLiteral("-Sy")));
    }

    void mutationsUsePkexec()
    {
        PacmanAdapter adapter;
        QCOMPARE(adapter.installCommand("jq", "").program, QStringLiteral("pkexec"));
        QCOMPARE(adapter.searchCommand("jq").program, QStringLiteral("pacman"));
        QVERIFY(!adapter.pinCommand("jq", "").isValid()); // unsupported in v1
    }
};

QTEST_MAIN(TestPacmanAdapter)
#include "tst_pacmanadapter.moc"
