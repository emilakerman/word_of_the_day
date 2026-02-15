# Rules for Cursor agents – Word of the Day

## Project overview

- **Stack**: Flutter (Dart SDK >=3.3), Material 3, `shared_preferences`, `http`.
- **App**: Single main screen showing a “word of the day” with share and favorite (placeholders).
- **Assets**: Word data lives under `assets/data/`; app icon/splash under `assets/icon/`.

## Code structure

- **Entry**: `lib/main.dart` – sets up `MaterialApp`, theme (indigo seed, light/dark), and `WordOfTheDayScreen`.
- **Screens**: `lib/screens/` – UI screens (e.g. `WordOfTheDayScreen`).
- **Data**: `lib/data/` – sample/curated word data and types.
- **Services**: `lib/services/` – e.g. `WordSelectionService` for selecting today’s word.
- **Tools**: `tool/` – CLI/scripts (e.g. `generate_curated_words.dart`) for generating or processing data; run with `dart run`, not as app code.

## Conventions for agents

### Dart / Flutter

- Prefer `const` constructors and `final` where possible. Use `super.key` and `super.parameters` in widget constructors.
- Follow existing `flutter_lints`; avoid disabling lints without a short comment.
- Keep widget trees readable; extract sub-widgets or methods when they get long.
- Prefer stateless widgets unless state is needed; extract stateful logic into small, focused widgets or controllers.
- Use `async`/`await`; handle errors explicitly; avoid swallowing exceptions.

### Theming

- Use the app’s existing `ThemeData` / `ColorScheme.fromSeed(seedColor: 0xFF6366F1)` and `Theme.of(context)`; don’t introduce new global colors unless the user asks.

### Data and services

- Word content should flow from `lib/data/` or `assets/data/` through services (e.g. `WordSelectionService`); don’t hardcode large word lists in UI code.
- Changes to word data format should be reflected in both app code and any `tool/` scripts that produce that data.

### Scope and platform

- When adding features, match the current structure (screens, services, data) and avoid unnecessary new dependencies in `pubspec.yaml` unless the user requests them.
- iOS and Android are in use; if you add native or plugin behavior, consider both platforms.

### Pull requests and CI

- When a PR is ready for review and its linked Linear ticket is **In Review** or completed, the workflow **PR ready – Linear + Android** runs the branch on an Android emulator and runs tests. Link the PR to Linear by including the issue identifier (e.g. `WORD-123`) in the PR title, body, or branch name. The repo must have `LINEAR_API_KEY` in Secrets.
- **When work is complete**: Before concluding a task, always check if a PR exists for the branch (e.g. `gh pr list --head <branch-name>`). If a draft PR exists and all work is complete, mark it as ready for review using `gh pr ready <pr-number>`. Never leave a PR in draft state when the work is finished.
- When marking a PR ready for review, add **Copilot** as a reviewer via the GitHub PR sidebar (or remind the user to do so if automated addition fails).

### Linear

- Always move a ticket from backlog to In Review in the Linear team / project associated with this github repo when code has been started being written.

