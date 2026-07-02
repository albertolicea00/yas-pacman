#include <QSignalSpy>
#include <QTest>

#include "clicommand.h"
#include "processrunner.h"

using yas::CliCommand;
using yas::ProcessRunner;

class TestProcessRunner : public QObject {
    Q_OBJECT
private slots:
    void runsCommandAndStreamsOutput()
    {
        ProcessRunner runner;
        QSignalSpy lines(&runner, &ProcessRunner::outputLine);
        QSignalSpy finished(&runner, &ProcessRunner::finished);

        runner.start(CliCommand{QStringLiteral("sh"),
                                {QStringLiteral("-c"), QStringLiteral("echo one; echo two")}});
        QVERIFY(finished.wait(5000));

        QCOMPARE(finished.first().at(0).toInt(), 0);
        QCOMPARE(lines.count(), 2);
        QCOMPARE(lines.at(0).at(0).toString(), QStringLiteral("one"));
        QCOMPARE(lines.at(1).at(0).toString(), QStringLiteral("two"));
    }

    void reportsMissingExecutable()
    {
        ProcessRunner runner;
        QSignalSpy failed(&runner, &ProcessRunner::failedToStart);
        runner.start(CliCommand{QStringLiteral("definitely-not-a-real-binary-xyz"), {}});
        QCOMPARE(failed.count(), 1);
    }

    void nonZeroExitCodePropagates()
    {
        ProcessRunner runner;
        QSignalSpy finished(&runner, &ProcessRunner::finished);
        runner.start(CliCommand{QStringLiteral("sh"),
                                {QStringLiteral("-c"), QStringLiteral("exit 3")}});
        QVERIFY(finished.wait(5000));
        QCOMPARE(finished.first().at(0).toInt(), 3);
    }
};

QTEST_MAIN(TestProcessRunner)
#include "tst_processrunner.moc"
