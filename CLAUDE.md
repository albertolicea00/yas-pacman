# CLAUDE.md — YAS Pacman

## What
Native GUI wrapper for **Pacman** (`pacman`). Part of YAS suite.
Status: **scaffolded & unit-tested** — vendored core + adapter + QML shell compile, 3/3 QtTest suites pass (verified cross-compiling on macOS). Pending: build + QA on the real target platform.

## Stack
- C++20 + Qt 6.7+ (Qt Quick / QML), CMake ≥ 3.24, GCC/Clang
- Native windowing via Qt QPA plugins: **wayland** with **xcb** (X11) fallback.
- CLI execution: `QProcess` wrapping `pacman`. Never bundle it.
- Architecture: **vendored core copy** (identical across suite, NO shared library by design) + `pacman` adapter. Master template: `../yas-core/` local folder (not published). Core fixes must be replicated across repos.

## Target platform
Arch Linux and derivatives (Manjaro, EndeavourOS). x64.

## pacman specifics
- **Mutating ops require root** (`-S`, `-R`, `-Syu`). Use **polkit** (`pkexec`) per operation; GUI stays unprivileged. Ship polkit policy.
- Key commands: `pacman -Ss` (search), `-Si`/`-Qi` (info), `-Q` (list local), `-S --noconfirm` (install), `-Rns` (remove+deps+config), `-Syu` (full upgrade), `-Sy` alone is **forbidden** (partial upgrade breaks systems — never expose it), `-Qdt` (orphans), `-Sc/-Scc` (cache clean), `-Qu` (updates).
- Pin/hold = `IgnorePkg` in `/etc/pacman.conf` — editing it needs root; handle via pkexec helper.
- db lock `/var/lib/pacman/db.lck`: detect, queue, never auto-delete.
- Output is plain text but stable; `--print-format` helps. Consider libalpm (official C lib) later; v1 wraps CLI per suite convention.
- Repo packages only — AUR is yas-yay's job. Keep scope separation.

## Design (see DESIGN.md)
- UI shell: **Teams-style** — icon rail | list panel | detail pane (no in-app title header). Light/dark mode persisted via `YasManager` context property (`src/core/thememanager.*`, QSettings), toggle at rail bottom. Both palettes live in `qml/core/Theme.qml` (`Theme.dark`).
- Dark theme. Base `#222629`, accent **Orange `#FF5722`**, highlight `#FF57221A`, text `#F8F8F2` / `#ACADAD`.
- App tag: **PACMAN**. Fonts: Outfit/Inter (UI), Fira Code or JetBrains Mono (CLI output).

## Conventions
- Conventional Commits (no co-author attribution), feature branches, PRs per CONTRIBUTING.md. Never push to origin without explicit ask.
- Planned layout (mirrors yas-brew, the reference scaffold): `src/core/` (vendored), `src/pacmanadapter.*`, `src/main.cpp`, `qml/core/` (vendored) + `qml/Main.qml`, `tests/`, `assets/fonts/`, `icons/` (exists), CMakeLists.txt + CMakePresets.json.
- Packaging: PKGBUILD → AUR (dogfooding) + AppImage.

## Key files
README.md · DESIGN.md · CONTRIBUTING.md · EULA.md · SECURITY.md · icons/
