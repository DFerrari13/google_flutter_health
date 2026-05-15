```markdown
# google_flutter_health — Claude Code Instructions

## What this project is
Flutter package wrapping the Google Health API.
Architecture mirrors Fitbitter (see FITBITTER_ANALYSIS.md).
Spiritual successor to Fitbitter for the post-Fitbit-migration world.

## Always read first
1. SPEC.md — all decisions and patterns
2. FITBITTER_ANALYSIS.md — Fitbitter architecture to mirror
3. https://developers.google.com/health/reference/rest — live API docs

## Architecture rules
- One data type = Model + Manager + APIURLBuilder + Tests (all four, always)
- Abstract bases: GoogleHealthDataManager, GoogleHealthAPIURL
- fetch() returns ({List<T> data, GoogleHealthCredentials credentials})
- fetch() handles token refresh automatically via isExpired + 60s buffer
- Credentials are never stored by the library — returned to the developer

## Code style
- Dart 3 sound null safety: required + non-nullable by default
- Nullable (T?) only where the Google Health API marks a field as optional
- Manual fromJson/toJson — no json_serializable, no freezed, no build_runner for models
- sealed + final classes for exceptions
- factory constructors for URL builders: day(), dateRange(), intraday()

## Quality gates — run before every commit
- dart analyze --fatal-infos
- dart test
- dart format --set-exit-if-changed lib test

## Git workflow
- Branch per data type: feat/steps, feat/heart-rate, feat/sleep, etc.
- Commit only after all four artefacts are complete and tests pass
- Commit message: "feat(steps): add GoogleHealthStepsData, manager, URL builder, tests"

## Build order — do not skip ahead
P0: steps → heart-rate → sleep → profile
P1 (after all P0 green): distance → calories → active-zone-minutes → resting-heart-rate
P2 (after all P1 green): oxygen-saturation → hrv → weight → exercise

## Auth
- Use googleapis_auth only — no google_sign_in, no open-source OAuth libs
- access_type=offline required in auth request to get a refresh token
- Token URL: https://oauth2.googleapis.com/token
- Scope prefix: https://www.googleapis.com/auth/googlehealth.{scope}
- Access tokens last 1 hour — always check isExpired with 60s buffer

## Never
- Store credentials in the library
- Add web platform support
- Use google_sign_in
- Implement P1/P2 before P0 is complete and tested
- Guess API response shapes — always read the reference docs first
```
