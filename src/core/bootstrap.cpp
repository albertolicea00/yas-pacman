#include "bootstrap.h"

#include <QDir>
#include <QFontDatabase>

namespace yas {

void loadBundledFonts()
{
    const QDir dir(QStringLiteral(":/yas/fonts"));
    const auto entries = dir.entryList({QStringLiteral("*.ttf"), QStringLiteral("*.otf")});
    for (const QString &file : entries)
        QFontDatabase::addApplicationFont(dir.filePath(file));
}

} // namespace yas
