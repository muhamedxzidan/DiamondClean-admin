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
