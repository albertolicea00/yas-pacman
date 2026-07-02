#include <QTest>

#include "packagelistmodel.h"

using yas::Package;
using yas::PackageListModel;

class TestPackageListModel : public QObject {
    Q_OBJECT
private slots:
    void filterMatchesNameAndDescription()
    {
        PackageListModel model;
        model.setPackages({
            {"git", "git", "2.45", "2.45", "Version control", "", "", "formula", false},
            {"wget", "wget", "1.24", "", "Internet file retriever", "", "", "formula", false},
            {"jq", "jq", "1.7", "1.7", "JSON processor", "", "", "formula", true},
        });
        QCOMPARE(model.count(), 3);

        model.setFilter("json");
        QCOMPARE(model.count(), 1);
        QCOMPARE(model.get(0).value("packageId").toString(), QStringLiteral("jq"));

        model.setFilter("wget");
        QCOMPARE(model.count(), 1);

        model.setFilter("");
        QCOMPARE(model.count(), 3);
    }

    void derivedRolesComputed()
    {
        PackageListModel model;
        model.setPackages({
            {"a", "a", "2.0", "1.0", "", "", "", "", false}, // outdated
            {"b", "b", "1.0", "", "", "", "", "", false},    // not installed
        });
        QCOMPARE(model.get(0).value("installed").toBool(), true);
        QCOMPARE(model.get(0).value("outdated").toBool(), true);
        QCOMPARE(model.get(1).value("installed").toBool(), false);
        QCOMPARE(model.get(1).value("outdated").toBool(), false);
    }
};

QTEST_MAIN(TestPackageListModel)
#include "tst_packagelistmodel.moc"
