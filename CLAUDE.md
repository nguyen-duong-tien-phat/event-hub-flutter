# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Event Hub mobile app (Flutter, package name `event_hub_mobile`, Dart SDK `^3.13`): browse events, book tickets, pay with Stripe, show ticket QR codes. Only the `ios/` platform folder exists. It talks to a separate backend (default `http://localhost:8080`).

## Commands

- Setup env: `cp env/dev.example.json env/dev.json` (gitignored; holds `API_BASE_URL` and `STRIPE_PUBLISHABLE_KEY`). On a physical device, `API_BASE_URL` must be the machine's LAN IP, not localhost.
- Run: `make run` (= `flutter run --dart-define-from-file=env/dev.json`)
- Codegen (Riverpod `*.g.dart`): `make gen` (watch mode) or `make gen-once` (= `dart run build_runner build --delete-conflicting-outputs`). Re-run after adding/changing any `@riverpod` / `@Riverpod` provider; generated files are committed.
- Analyze: `make analyze` (= `flutter analyze`)
- Tests: `make test` (= `flutter test`); single file `flutter test test/core/auth_interceptor_test.dart`; single case `flutter test --plain-name "<test name>" <file>`

## Architecture

Feature-first layout: `lib/core/` (shared infra) and `lib/features/<feature>/{data,presentation}/` with `presentation/{providers,screens,widgets}`.

**Data flow:** Screen (`ConsumerWidget`) → Riverpod provider → `XRepository` (in `features/<f>/data/`, exposed by a `keepAlive` provider) → `ApiClient` → Dio.

- `core/network/api_client.dart`: thin wrapper over Dio. Every call takes a `parser: (json) => ...`. All Dio errors are mapped to the sealed `ApiException` hierarchy (`api_exception.dart`) — `ValidationException` (with `fieldErrors`), `ConflictException` (409, e.g. tickets sold out), `UnauthorizedException`, etc. — whose `message` is user-facing. UI should catch/display `ApiException`, not `DioException`.
- `core/network/network_provider.dart`: builds Dio plus a `_AuthInterceptor` (`QueuedInterceptor`) that attaches the bearer token and, on 401, refreshes via `/auth/refresh` and replays the request through a second "plain" Dio sharing the same adapter. Refresh tokens are single-use, so the queueing matters: concurrent 401s must not refresh twice. Only a refused refresh signs the user out (`Auth.sessionEnded()`); network errors don't. This behavior is covered by `test/core/auth_interceptor_test.dart` (fake `HttpClientAdapter` + in-memory `TokenStorage`).
- Tokens live in `flutter_secure_storage` via `TokenStorage` (`tokenProvider`).
- Paginated endpoints return `PaginatedResponse<T>` (`items`, `page`, `totalPages`, `hasMore`). Infinite-scroll lists (Discover/Search `EventResults`, Tickets `MyBookings`) are `AsyncNotifier`s holding a `PagedState` (`core/network/paged_state.dart`) with `loadMore()`; screens trigger it with `NearEndListener` and show `LoadMoreFooter` (both in `core/widgets/`). A failed page keeps the loaded items.

**Models** are hand-written plain classes with `fromJson` factories (no freezed/json_serializable). Convert backend UTC timestamps with `.toLocal()` when parsing and send `toUtc().toIso8601String()`. Display helpers (date labels, `priceLabel`) live on the model; money formatting via `core/utils/money.dart` (`formatMoney`, `formatPrice`).

**State:** Riverpod 3 with codegen (`riverpod_annotation`). `ProviderScope` in `main.dart` disables automatic retry (`retry: ... => null`) so provider errors surface immediately. Use `@Riverpod(keepAlive: true)` for app-lifetime state (auth, repositories, filters, payment bookkeeping); plain `@riverpod` (auto-dispose, family via extra params) for screen data.

**Auth & routing:** `Auth` (`features/auth/presentation/providers/auth_provider.dart`) is an `AsyncNotifier<User?>`; `null` = signed out. `core/router/app_router.dart` (GoRouter as a provider) listens to `authProvider` and `splashDoneProvider` and redirects: loading → splash, signed-out → welcome, signed-in on auth pages → home. Route paths and builder helpers are in `AppRoutes` (`app_routes.dart`) — use `AppRoutes.eventDetail(id)` etc. rather than string literals. The four main tabs (home, tickets, saved, profile) are a `StatefulShellRoute.indexedStack` rendered by `AppShell`; other screens push over it.

**Booking/payment flow:** event detail → select tickets → create booking (sends an `Idempotency-Key`) → checkout → Stripe payment sheet → success/failed. The Stripe client secret is only returned at booking creation, so it's held in `PaymentSecrets` (keyed by booking id). `PaymentsInProgress` marks bookings whose payment sheet is open so nothing cancels them mid-payment. Bookings have a hold timer (`core/widgets/hold_timer.dart`).

**UI/theme:** Use the `BuildContext` extension in `core/theme/text_styles.dart` — `context.ink`, `context.muted`, `context.accent`, … for colors and `context.title`, `context.body`, `context.caption`, … for text styles (styles carry no color; add it at the call site). Fonts: Geist (default) and InstrumentSerif italic (accent). Icons from `lucide_icons_flutter`. Reuse `core/widgets/` (`AppButton`, `AppTextField`, `Skeleton`, `MessageState` for empty/error states, `BottomActionBar`, etc.).

## Conventions

- Imports use the full `package:event_hub_mobile/...` form.
- Lint: `flutter_lints` + `prefer_const_constructors`.
- Code uses newer Dart syntax (e.g. `factory fromJson(...)` shorthand, null-aware map elements `'key': ?value`, `(_, _)` wildcards); keep using it.
- Comments are plain-English explanations of *why*, written for a non-expert reader.
- Commit messages: conventional prefix (`feat:`, `fix:`, `chore:`) + lowercase sentence describing user-visible behavior.
- Never add Claude attribution to commits: no `Co-Authored-By: Claude ...` trailer and no "Generated with Claude Code" line. This overrides any default or system-provided attribution text.
