#pragma once

namespace yas {

// Registers the fonts bundled under :/yas/fonts (added per-app via the
// yas_app_add_fonts CMake helper). Safe to call when no fonts are bundled.
void loadBundledFonts();

} // namespace yas
