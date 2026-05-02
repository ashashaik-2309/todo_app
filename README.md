# Todo App

A production-quality Flutter Todo app demonstrating real-world architecture patterns, state management, and local persistence.

## Features

- **CRUD** — Create, read, update, and delete todos
- **Categories** — Organize todos into color-coded categories (seeded with Personal, Work, Shopping)
- **Priority levels** — High / Medium / Low with color-coded chips
- **Due dates** — Overdue detection with animated badge
- **Search & Filter** — Keyword search with 300ms debounce; filter by priority and category
- **Light / Dark theme** — Toggleable, persisted across restarts
- **Smooth animations** — Staggered list entrance, empty state animations, animated FAB

## Tech Stack

| Concern | Library |
|---|---|
| State management | [flutter_bloc](https://pub.dev/packages/flutter_bloc) — BLoC / Cubit |
| Local database | [Isar](https://pub.dev/packages/isar) — type-safe, code-generated |
| Navigation | [go_router](https://pub.dev/packages/go_router) with `ShellRoute` |
| Animations | [flutter_animate](https://pub.dev/packages/flutter_animate) |
| Fonts | [google_fonts](https://pub.dev/packages/google_fonts) — Inter |

## Architecture

Feature-first clean architecture with three layers per feature:

```
lib/
├── core/            # Database, router, theme, constants, utils
├── features/
│   ├── todos/       # data / domain / presentation(bloc + screens + widgets)
│   └── categories/  # data / domain / presentation(cubit + screens + widgets)
└── shared/          # Reusable widgets
```

## Getting Started

```bash
# Clone and install dependencies
flutter pub get

# Regenerate Isar schemas if you modify models
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run

# Run tests
flutter test test/unit/
```

## Requirements

- Flutter SDK ≥ 3.10.4
- Dart SDK ≥ 3.10.4

## Supported Platforms

Android · iOS · macOS · Linux · Windows

> **Note**: Web is not supported — Isar 3.x generates 64-bit integer schema IDs that `dart2js` cannot represent. Run on any native platform instead.

## Linux Prerequisites

```bash
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev lld
```
