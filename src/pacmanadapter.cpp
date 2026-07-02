#include "pacmanadapter.h"

using yas::CliAction;
using yas::CliCommand;
using yas::Package;

// Pacman adapter. Mutations go through pkexec (polkit). `-Sy` alone is never
// issued anywhere — partial upgrades break Arch systems; the only sync is the
// full `-Syu`. Pin (IgnorePkg) is unsupported in v1: it requires editing
// /etc/pacman.conf via a privileged helper.
namespace {

const QString kPacman = QStringLiteral("pacman");

CliCommand root(QStringList args)
{
    return {QStringLiteral("pkexec"), QStringList{kPacman} + args};
}

// -Ss output: "repo/name version [group] [installed]" + indented description.
QList<Package> parseSearchOutput(const QString &stdOut)
{
    QList<Package> result;
    const QStringList lines = stdOut.split(QLatin1Char('\n'));
    for (const QString &line : lines) {
        if (line.isEmpty())
            continue;
        if (line.startsWith(QLatin1Char(' ')) || line.startsWith(QLatin1Char('\t'))) {
            if (!result.isEmpty() && result.last().description.isEmpty())
                result.last().description = line.trimmed();
            continue;
        }
        const QString head = line.section(QLatin1Char(' '), 0, 0);
        if (!head.contains(QLatin1Char('/')))
            continue;
        Package p;
        p.source = head.section(QLatin1Char('/'), 0, 0);
        p.id = head.section(QLatin1Char('/'), 1, 1);
        p.name = p.id;
        p.version = line.section(QLatin1Char(' '), 1, 1);
        p.kind = p.source == QStringLiteral("aur") ? QStringLiteral("aur")
                                                   : QStringLiteral("repo");
        if (line.contains(QStringLiteral("[installed")))
            p.installedVersion = p.version;
        result.append(p);
    }
    return result;
}

// -Si / -Qi output: "Key             : Value" lines.
QList<Package> parseInfoOutput(const QString &stdOut)
{
    Package p;
    const QStringList lines = stdOut.split(QLatin1Char('\n'));
    for (const QString &line : lines) {
        const qsizetype colon = line.indexOf(QStringLiteral(" : "));
        if (colon <= 0)
            continue;
        const QString key = line.left(colon).trimmed();
        const QString value = line.mid(colon + 3).trimmed();
        if (key == QStringLiteral("Name")) { p.id = value; p.name = value; }
        else if (key == QStringLiteral("Version")) p.version = value;
        else if (key == QStringLiteral("Description")) p.description = value;
        else if (key == QStringLiteral("URL")) p.homepage = value;
        else if (key == QStringLiteral("Repository")) p.source = value;
    }
    if (p.id.isEmpty())
        return {};
    p.kind = p.source == QStringLiteral("aur") ? QStringLiteral("aur")
                                               : QStringLiteral("repo");
    return {p};
}

} // namespace

QString PacmanAdapter::displayName() const { return QStringLiteral("Pacman"); }
QString PacmanAdapter::cliProgram() const { return kPacman; }
QStringList PacmanAdapter::cliSearchPaths() const { return {QStringLiteral("/usr/bin")}; }
QStringList PacmanAdapter::cliVersionArguments() const { return {QStringLiteral("--version")}; }

CliCommand PacmanAdapter::searchCommand(const QString &query) const
{
    return {kPacman, {QStringLiteral("-Ss"), query}};
}

CliCommand PacmanAdapter::infoCommand(const QString &packageId, const QString &) const
{
    return {kPacman, {QStringLiteral("-Si"), packageId}};
}

CliCommand PacmanAdapter::listInstalledCommand() const
{
    return {kPacman, {QStringLiteral("-Q")}};
}

CliCommand PacmanAdapter::listOutdatedCommand() const
{
    return {kPacman, {QStringLiteral("-Qu")}};
}

CliCommand PacmanAdapter::installCommand(const QString &packageId, const QString &) const
{
    return root({QStringLiteral("-S"), QStringLiteral("--noconfirm"), packageId});
}

CliCommand PacmanAdapter::uninstallCommand(const QString &packageId, const QString &) const
{
    return root({QStringLiteral("-Rns"), QStringLiteral("--noconfirm"), packageId});
}

CliCommand PacmanAdapter::upgradeCommand(const QString &packageId, const QString &) const
{
    // No safe single-package upgrade on Arch (would be a partial upgrade);
    // reinstalling the repo version is the closest equivalent.
    return root({QStringLiteral("-S"), QStringLiteral("--noconfirm"), packageId});
}

CliCommand PacmanAdapter::upgradeAllCommand() const
{
    return root({QStringLiteral("-Syu"), QStringLiteral("--noconfirm")});
}

CliCommand PacmanAdapter::pinCommand(const QString &, const QString &) const
{
    return {}; // IgnorePkg editing needs a privileged helper — v2
}

CliCommand PacmanAdapter::unpinCommand(const QString &, const QString &) const
{
    return {};
}

QList<Package> PacmanAdapter::parseSearch(const QString &stdOut) const
{
    return parseSearchOutput(stdOut);
}

QList<Package> PacmanAdapter::parseInfo(const QString &stdOut) const
{
    return parseInfoOutput(stdOut);
}

QList<Package> PacmanAdapter::parseInstalled(const QString &stdOut) const
{
    // -Q output: "name version"
    QList<Package> result;
    const QStringList lines = stdOut.split(QLatin1Char('\n'), Qt::SkipEmptyParts);
    for (const QString &line : lines) {
        const QStringList tokens = line.split(QLatin1Char(' '), Qt::SkipEmptyParts);
        if (tokens.size() < 2)
            continue;
        Package p;
        p.id = tokens.value(0);
        p.name = tokens.value(0);
        p.installedVersion = tokens.value(1);
        p.version = tokens.value(1);
        p.kind = QStringLiteral("repo");
        result.append(p);
    }
    return result;
}

QList<Package> PacmanAdapter::parseOutdated(const QString &stdOut) const
{
    // -Qu output: "name old-version -> new-version"
    QList<Package> result;
    const QStringList lines = stdOut.split(QLatin1Char('\n'), Qt::SkipEmptyParts);
    for (const QString &line : lines) {
        const QStringList tokens = line.split(QLatin1Char(' '), Qt::SkipEmptyParts);
        if (tokens.size() < 4 || tokens.value(2) != QStringLiteral("->"))
            continue;
        Package p;
        p.id = tokens.value(0);
        p.name = tokens.value(0);
        p.installedVersion = tokens.value(1);
        p.version = tokens.value(3);
        result.append(p);
    }
    return result;
}

QList<CliAction> PacmanAdapter::actionCatalog() const
{
    return {
        {QStringLiteral("full-upgrade"), tr("Full system upgrade"),
         tr("Sync databases and upgrade every package (-Syu)"),
         root({QStringLiteral("-Syu"), QStringLiteral("--noconfirm")}), false, true, true},
        {QStringLiteral("orphans"), tr("List orphans"),
         tr("Packages installed as dependencies that nothing requires anymore"),
         {kPacman, {QStringLiteral("-Qdt")}}, false, false, false},
        {QStringLiteral("cache-clean"), tr("Clean package cache"),
         tr("Remove cached packages that are no longer installed"),
         root({QStringLiteral("-Sc"), QStringLiteral("--noconfirm")}), false, true, false},
        {QStringLiteral("files"), tr("List package files"),
         tr("Show every file a package installed"),
         {kPacman, {QStringLiteral("-Ql")}}, true, false, false},
        {QStringLiteral("verify"), tr("Verify package"),
         tr("Check that a package's files are present and unmodified"),
         {kPacman, {QStringLiteral("-Qkk")}}, true, false, false},
        {QStringLiteral("local-info"), tr("Installed package details"),
         tr("Full metadata of an installed package (-Qi)"),
         {kPacman, {QStringLiteral("-Qi")}}, true, false, false},
    };
}
