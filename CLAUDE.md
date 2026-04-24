# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project snapshot

Flutter admin app ("diamond_clean") for managing orders, customers, employees, cars, categories, products, cashbox/treasury, and related operations for a cleaning business. Firestore is the primary data source; Firebase Auth handles login; Flutter Web is deployed to Firebase Hosting. UI is Arabic/RTL (Material Design 3).

- Dart SDK: `^3.10.3`, Flutter stable.
- State: `flutter_bloc` / Cubit (no Bloc event classes). States are sealed classes with exhaustive `switch` pattern matching (see `_AuthGate` in `lib/main.dart`).
- Data: `cloud_firestore`, `firebase_auth`, `flutter_secure_storage` (used for local auth caching).
- **No** code generation (`freezed`, `build_runner`) is used — rely on Dart 3 sealed classes, records, and pattern matching instead.
- **No** domain layer, use cases, repositories, or `Either<Failure, Success>`. The 2-layer architecture below is strict.

## Commands

Run from repo root.

```bash
flutter pub get                                  # install deps
flutter run -d chrome                            # dev on web
flutter run                                      # dev on default device
flutter analyze                                  # lint (uses analysis_options.yaml → flutter_lints)
dart format .                                    # format

flutter test                                     # run all tests
flutter test test/features/orders                # run one feature's tests
flutter test test/core/utils/whatsapp_invoice_service_test.dart   # run one file
flutter test --name "substring of test name"     # run a single test by name

flutter build web --release                      # build for hosting
./deploy.sh                                      # build + firebase deploy --only hosting
```

Firebase project is `fir-clean-6ed6c` (see `firebase.json`, `lib/firebase_options.dart`). Hosting serves `build/web` with SPA rewrite to `/index.html`.

## Architecture

### 2-layer feature architecture

Every feature under `lib/features/<feature>/` follows the same shape:

```
<feature>/
  cubit/          business logic, state emission; sealed state class
  data/
    datasources/  *_remote_data_source.dart (abstract) + *_impl.dart (Firestore/Auth)
    models/       DTOs with fromFirestore / toMap
  presentation/
    screens/      route-level widgets
    widgets/      feature-local widgets
  core/           (optional) feature-local pure helpers — see orders/core/
```

Flow is one-way: **UI → Cubit → DataSource → Firebase**, and errors bubble back the same path. UI never imports `cloud_firestore`, `firebase_auth`, or any datasource; only Cubit states cross into UI. Cubit never touches Firestore directly.

Current features: `auth`, `cars`, `cashbox`, `categories`, `customers`, `employees`, `home`, `orders`, `products`, `treasury_report`.

### App wiring

- `lib/main.dart` boots Firebase, provides a single top-level `AuthCubit` via `BlocProvider`, and `_AuthGate` switches between `LoginScreen` and `DashboardShell` using pattern matching on `AuthState`.
- Navigation is **not** centralized via a router. `lib/core/routes/app_router.dart` is intentionally empty — auth routing lives in `_AuthGate`, everything else uses `Navigator.push` / `showDialog` from widgets. Do not introduce `go_router` or a route table unless the user asks.
- Each non-auth feature provides its own `Cubit` scoped where it is used (typically at screen level via `BlocProvider`), not globally.

### Data layer conventions

- Collection names live in `lib/core/constants/firebase_constants.dart` — reference them, don't hardcode strings.
- Datasources expose an abstract interface (`*_remote_data_source.dart`) and a Firestore impl (`*_remote_data_source_impl.dart`). Cubits depend on the interface for testability with `fake_cloud_firestore`.
- Models use `fromFirestore(DocumentSnapshot)` / `fromMap` / `toMap` — not `json_serializable`.
- Streams (`watch*`) are preferred for live collections; one-shot fetches return `Future<...>`.

### Core (shared) layer

`lib/core/` holds anything reused across features. Put shared code here before duplicating.

- `constants/` — `AppStrings` (Arabic UI copy), `AppDimensions`, `FirebaseConstants`.
- `widgets/` — `CustomButton`, `CustomTextField`, `CustomCard`, `CustomDialog`, `LoadingWidget`, `ErrorWidget`, `EmptyStateWidget`. Exported via `widgets.dart`. Prefer these over building ad-hoc buttons/fields; see `lib/core/UI_SYSTEM.md` for usage.
- `extensions/` — `BuildContext` helpers (`context.textTheme`, `context.colorScheme`, `context.isSmallScreen`, etc.) and widget chaining (`.paddingAll`, `.center`).
- `theme/app_theme.dart` — Material 3 theme. Do not hardcode colors/paddings; use theme + `AppDimensions`.
- `utils/` — cross-feature pure helpers (e.g. `whatsapp_invoice_service.dart`, `cashbox_validator.dart`, `treasury_log_entry_mapper.dart`, `pricing_display_helper.dart`). These are the canonical place for business logic that is shared across cubits.
- `models/treasury_log_entry.dart` — shared domain-ish models used by more than one feature.

### Tests

Mirror the `lib/` tree under `test/` (`test/features/<feature>/...`, `test/core/utils/...`). Firestore is faked with `fake_cloud_firestore`; inject it into the `*RemoteDataSourceImpl` under test. Keep tests deterministic — no real clock/network. Bug fixes must land with a reproducing test (rule 22).

### Things to avoid in this repo

- Don't introduce a repository layer, use cases, or `Either` types (rule 4).
- Don't add `freezed` / `json_serializable` / `build_runner` (rule 16).
- Don't add packages without approval, and never hand-edit `pubspec.lock` (rule 14).
- Don't put Firestore calls in widgets or cubits — only in datasources (rule 23).
- Don't centralize routing; keep the current `_AuthGate` + `Navigator.push` pattern unless asked.
- Don't hardcode strings visible to users — route through `AppStrings` (Arabic/RTL).

---

# Project Global Engineering Rules

## 1) Clean code always
- Keep code clean, readable, and maintainable.
- Prefer clarity over cleverness.

## 2) Small files and functions
- Files and functions must stay small and focused.
- Avoid large classes or overly complex files.

## 3) Comments only when necessary
- Add comments only when the intent is not obvious.
- Do not add redundant or obvious comments.

## 4) Architecture discipline (strict)
- This project uses a 2-layer feature architecture. There is NO domain layer and NO use cases.
- Feature folder structure:
  ```
  feature_name/
    cubit/         ← state management & business logic
    data/          ← data source calls & data models (REST API or Firebase — specified per project)
    presentation/  ← UI only
  ```
- Cubit calls the data layer directly. No repositories, no use cases, no Either types.
- Data layer handles all data source interactions, mapping, and model classes.
- Presentation layer handles rendering, user interaction, and state observation only.
- Do not introduce domain layer, use cases, repositories, or Either<Failure, Success> — ever.
- Do not introduce unnecessary abstractions or overengineering.
- The data source (REST API via Dio, Firebase, etc.) is specified at the start of each session.

## 5) Apply SOLID, DRY, and sound engineering principles
- Apply SOLID, DRY, and other sound engineering principles when beneficial.
- Do not force patterns unnecessarily.

## 6) Root-cause first
- Always identify and fix the root cause, not just symptoms.
- Do not apply superficial fixes.

## 7) Minimal safe changes
- Make the smallest possible change that solves the problem.
- Do not refactor unrelated code unless explicitly requested.

## 8) No breaking changes
- Do not break existing functionality, APIs, flows, or UX unless explicitly instructed.

## 9) Follow repository conventions
- Follow existing architecture, folder structure, naming conventions, and patterns.
- Do not introduce a new style inconsistent with the project.

## 10) Core folder for shared components
- Any reusable logic, utilities, services, constants, extensions, helpers, or shared components used in more than one place must be placed in the core/ folder.
- Avoid duplication across features.

## 11) Performance awareness (Flutter)
- Follow Flutter performance best practices at all times.
- Avoid unnecessary widget rebuilds.
- Prefer const constructors wherever possible.
- Avoid heavy work inside build methods.
- Be careful when using setState:
  - Use setState only for local UI state when necessary.
  - Never use setState for business logic or feature state.
  - Prefer Cubit for managing feature and application state.
  - Avoid triggering unnecessary rebuilds of large widget trees.
- Prefer efficient widget composition and separation to minimize rebuild scope.
- Avoid unnecessary object allocations inside build methods.
- Avoid creating controllers (`TextEditingController`, `AnimationController`), `FocusNode`, or other expensive objects inside `build()`.
- Dispose controllers and focus nodes properly when owned by widgets (use `dispose()` in `StatefulWidget`).

## 12) State management discipline (Cubit)
- Use Cubit for feature state and business logic coordination.
- UI must never contain business logic.
- UI must only observe state and trigger Cubit actions.
- Cubit calls data layer directly — no intermediate layers.

## 13) Edge cases and error handling
- Properly handle null, empty, loading, and error states.
- Do not allow silent failures.
- Always ensure safe and predictable behavior.
- Use a consistent error handling strategy:
  - Data layer: catch exceptions and throw typed exceptions or return null/empty safely.
  - Cubit: catch errors from data layer and emit error states.
  - Presentation layer: map error states to user-friendly messages and appropriate UI.
- Errors must propagate cleanly: data → cubit → presentation.

## 14) Dependencies rule
- Do not add new packages unless necessary and justified.
- Any package added must be:
  - Latest stable version
  - Well-maintained
  - Production-grade and trusted

## 15) Security awareness
- Always consider security implications.
- Proactively warn about potential security risks.
- Never hardcode secrets, tokens, or credentials.
- Do not log sensitive information.
- Safely validate and handle external and API data.

## 16) Follow modern best practices
- Always follow current (2026) best practices and modern Flutter/Dart standards.
- Prefer native Dart 3+ features over code generation libraries:
  - Use `sealed class` for state unions and exhaustive pattern matching.
  - Use `switch` expressions and pattern matching for control flow.
  - Use records for lightweight data grouping when appropriate.
  - Avoid Freezed or other code generation unless the project explicitly adopts it.
  - Keep the project free from unnecessary build_runner dependencies.

## 17) Team mindset (engineering partner mode)
- Act as a senior engineer partner, not just a task executor.
- Suggest improvements when valuable.
- Think critically about solutions.
- Explain tradeoffs briefly when relevant.

## 18) No assumptions without verification
- Always read and understand relevant code before modifying it.
- Do not assume behavior without verification.
- Ask or clearly state assumptions if something is unclear.

## 19) Avoid duplication
- Reuse existing logic when available.
- Do not duplicate code unnecessarily.

## 20) Dart naming conventions and best practices
- Follow official Dart style guide and conventions:
  - Files: `snake_case.dart`
  - Classes, enums, typedefs: `PascalCase`
  - Variables, functions, parameters: `camelCase`
  - Constants: `camelCase` (not SCREAMING_CAPS)
  - Private members: prefix with `_`
- Feature folder structure: `feature_name/cubit/`, `feature_name/data/`, `feature_name/presentation/`
- Follow Effective Dart guidelines for API design, usage, and documentation.

## 21) Import ordering
- Organize imports in this order, separated by blank lines:
  1. Dart SDK imports (`dart:`)
  2. Flutter SDK imports (`package:flutter/`)
  3. Third-party package imports (`package:`)
  4. Project package imports (`package:project_name/`)
- Use relative imports within the same feature.
- Use package imports across features.
- Never use unused imports.

## 22) Testing discipline
- Write unit tests for cubit and data layer logic.
- Write widget tests for critical UI flows.
- Bug fixes must include a test that reproduces the issue.
- Follow existing test structure and naming conventions.
- Tests must be deterministic — no flaky or timing-dependent tests.
- Keep tests focused: one behavior per test case.

## 23) Separation of concerns enforcement
- Presentation layer must not directly call Firebase or data sources.
- All data operations must go through the data layer, triggered by Cubit.
- Cubits must depend only on the data layer — never call Firebase directly from UI.

## 24) Completion self-review checklist (mandatory)
Before finishing any task, verify:

- The root cause is correctly addressed.
- The solution is safe and minimal.
- No existing functionality is broken.
- Architecture rules are respected.
- No business logic exists in UI.
- No performance regressions introduced.
- No security risks introduced.

Then provide a brief summary of:
- What was changed
- Why it was changed
- Why the solution is safe and correct

## 25) Git and Pull Request output (mandatory after task completion)

After I confirm that the task is complete and approved, you must provide:

Branch name:
- Follow conventional naming format:
  fix/<description>
  feat/<description>
  refactor/<description>
  perf/<description>
  chore/<description>

Commit message:
- Clear, concise, professional
- Follow conventional commit format

Pull Request title:
- Clear and descriptive

Pull Request description:
- Must be in markdown (.md) format
- Keep it concise and straight to the point
- Include: summary and root cause (if bug fix)
