# Ecosystem role — Petrimonium Academy

Status as of 2026-08-31: **audited, partially split.** This is the furthest along
of the three repos — see "What's actually been done" below.

## The three repos

| Repo | Job | Money |
|---|---|---|
| **`petrimonium-academy`** (this repo) | Financial education: courses, lessons, quizzes, Financial Lab simulators, full gamification (XP, streaks, levels, badges, leaderboards) | Simulated only — never real |
| [`petrimonium-wallet`](../../Petrimonium-Wallet) | Real investment management, trust-forward, behavior-based gamification only | Real |
| [`petrimonium-backend`](../../Petrimonium-Backend) | Shared Spring Boot / PostgreSQL backend for both apps | N/A (data layer) |

All three share one identity/account graph and one Pet entity via the backend,
but own no feature code with each other.

## Where this actually came from

None of the three repos started from a blank scaffold. All three (plus this
one) are forks of [`Invest-Game-V2`](../../Invest-Game-V2) — a single, mature,
actively-developed combined app ("Invest Game", package `petrimonium`) that
already does everything: education, simulated portfolio tracking, real
portfolio tracking, gamification, an AI mentor, and a Pet, as one product.
Code comments in this repo cite `Invest-Game-V2/docs/` directly (e.g.
`ACADEMY_ENGINE.md §7`, `DECISION-014`) — that sibling repo's `docs/` is the
actual design history behind most of what's here, not something copied into
this repo. `Invest-Game-V2` is still under independent active development
(many commits after this fork) — the 3-repo split is not yet the primary
line of work.

## What's actually been done here (this repo)

- **Audit** (§0 of the original prompt): confirmed this is the pre-split
  combined app, not a fresh Academy scaffold. Real-money code
  (`features/portfolio`, `features/investment`, `features/asset_details`,
  the `DashboardScreen` Wallet/Proventos tabs) is still present — kept
  in place per an explicit decision to build Academy-specific pieces
  alongside it rather than delete anything yet.
- **Nav shell mapping** proposed and confirmed conceptually: Home/Path,
  Learn, Practice, Community, Profile/Pet — not yet executed as an actual
  `features/` restructure (the Financial Lab hasn't been moved out of
  `features/academy` into its own `features/practice`, and there's no
  Community/leaderboard feature yet).
- **`AcademyPetBehavior`** — the old monolithic `PetMessageCatalog` (one file
  reacting to every event for the whole combined app) is now split behind a
  `PetBehavior` contract: `lib/features/pet/domain/behavior/pet_behavior.dart`.
  `CorePetBehavior` owns identity/XP/level/evolution reactions (shared
  regardless of app); `AcademyPetBehavior`
  (`lib/features/academy/domain/services/academy_pet_behavior.dart`) owns
  lessons/quizzes/labs; `PortfolioPetBehavior`
  (`lib/features/portfolio/domain/services/portfolio_pet_behavior.dart`) owns
  real-portfolio reactions and is what should move to the Wallet repo once
  extraction happens. All three are independently unit-tested.
- **Wallet bridge CTA** — `WalletBridgeCta` +  `WalletDeepLink` (proposed
  `petrimonium://wallet/portfolio?highlight=<concept>` scheme), wired into
  every Financial Lab simulator's completion screen. Today it's an in-app
  tab switch (Wallet's screens still live in this repo); the shape is ready
  to swap to a real external launch once Wallet is a separate installed app.
- **Cross-repo contract proposals** written up in
  [`CROSS_REPO_CONTRACTS.md`](CROSS_REPO_CONTRACTS.md) — JWT `app_context`
  claim, the deep-link scheme above, and a Pet state schema starting point.
  None of these are confirmed by the Wallet or Backend repos yet.

## Update, 2026-08-31 — Stage 3: simulated wallet built, real Carteira tab retired

The Wallet/Academy split plan's Stage 3 landed: this app's "Carteira" tab no
longer shows real holdings. New `lib/features/simulated_wallet/` feature
(entities, datasource, repository, `SimulatedWalletController`,
`SimulatedWalletScreen`, `PlaceSimulatedOrderScreen`) talks only to the
backend's `simulated_portfolio` context (`/api/v1/simulated-portfolios/*`,
Petrimonium-Backend `docs/BACKEND_MODULE_PLAN.md` §11) — never imports from
`features/portfolio`/`features/investment`, and every screen carries a
persistent, non-dismissible `SimulationDisclaimerBanner`.

`DashboardScreen._buildWalletContent()` now renders `SimulatedWalletScreen`
instead of the old real-portfolio `PortfolioScreen`. `PortfolioScreen`/
`InvestmentConfigurationScreen`/`PortfolioController`'s real-holdings path
are **not deleted yet** (per the split plan's "remove real integrations
only after the simulated flow works" ordering) — `PortfolioScreen` is
simply no longer reachable from the dashboard. `PortfolioController` itself
is still alive and still used, because it also owns the real,
legitimate-for-Academy gamification orchestration (achievements/missions/
XP fetch, `_evaluateGamification()`) — that call was fixed in the same pass
to run independently of the (now always-failing, since real_portfolio is
Wallet-only) holdings fetch it used to be sequenced after; before this fix,
a failed holdings fetch silently skipped XP/achievements/missions loading
too. Two backend endpoints were added for this (Academy-reachable ticker
search + quote preview, since `/api/investments/search`/`quote` are
Wallet-only) — see the backend repo's own docs.

Known remaining staleness, out of scope for this pass: `HomeScreen` still
shows a real-portfolio "not connected"/error card sourced from
`PortfolioController.error` (now permanently non-null for Academy, since
that fetch always 403s) and a companion holdings-count greeting that's
always 0. Both are cosmetic leftovers of the not-yet-deleted real-portfolio
path, not functional breakage — flagged for the eventual cleanup pass
(Stage 7) once `PortfolioScreen`/`InvestmentConfigurationScreen`/
`features/investment` are confirmed dead and removed.

## What hasn't been done

- The actual `features/` folder restructure (Financial Lab → `features/practice`,
  Community tab scaffold, `DashboardScreen` rebuilt to the 5 confirmed tabs).
- No shared package (`design_system`/`core_auth`/`core_networking`/`pet_engine`)
  exists — duplicate-but-contract-matched was the explicit decision for now.
- No deep-linking plugin (`url_launcher`) wired to a real external launch —
  intentionally deferred until Wallet exists as a separate installed app.
- Real-portfolio code (`features/portfolio`, `features/investment`) still
  exists in this repo, just unreachable from the dashboard — not removed yet.
