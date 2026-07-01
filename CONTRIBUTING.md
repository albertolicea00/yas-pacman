# Contributing Guidelines

Thank you for your interest in contributing to this project! We welcome contributions from developers of all skill levels.

## Development Setup

> **Status**: the code scaffold is rolling out across the suite (yas-brew first).
> The commands below are the standard YAS build flow and will work as soon as
> the scaffold lands in this repository.

### Prerequisites

1. **Toolchain + Qt 6**: `sudo pacman -S --needed base-devel cmake ninja qt6-base qt6-declarative`

The `pacman` CLI itself must also be installed — the app is a GUI wrapper around it.

### Build environment

C++/Qt has no virtualenv; isolation comes from **out-of-source builds**: everything generated lives under `build/` (git-ignored) and the "environment" is pinned by `CMakePresets.json`. To reset the environment completely, delete `build/` and configure again.

```bash
cmake --preset default          # 1. configure — creates build/default
cmake --build --preset default  # 2. compile
ctest --preset default          # 3. run tests
./build/default/yas-pacman
```

### Project structure

- `src/core/` — vendored YAS core (process runner, queue, models, controller). Kept identical across all YAS repos; if you fix a bug here, please mention it so the fix can be replicated suite-wide.
- `src/` — the pacman adapter (command builders + output parsers) and `main.cpp`.
- `qml/core/` — shared design system and app shell (also vendored).
- `qml/` — app entry (`Main.qml`: brand accent + tag).
- `tests/` — QtTest unit tests; adapter parsers are tested against recorded CLI output.

## How to Contribute

1. **Reporting Bugs**: Open an issue using the Bug Report template.
2. **Suggesting Features**: Open an issue using the Feature Request template.
3. **Pull Requests**:
   - Fork the repository.
   - Create a feature branch (`git checkout -b feature/amazing-feature`).
   - Commit your changes (`git commit -m 'feat: add some amazing feature'`).
   - Push to the branch (`git push origin feature/amazing-feature`).
   - Open a Pull Request.

## Code Style

- Write clean, readable, and documented code.
- Follow the visual style and tokens outlined in `DESIGN.md`.
- Keep changes concise and focused.
