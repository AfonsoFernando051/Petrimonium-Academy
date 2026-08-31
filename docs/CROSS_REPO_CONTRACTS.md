# Cross-repo contracts — proposal

Status: **proposal, not yet confirmed** across `petrimonium-wallet` or
`petrimonium-backend`. Nothing in this repo depends on the backend actually
issuing/accepting these shapes yet — where that matters, it's called out
below. Written from `petrimonium-academy` per the "duplicate-but-contract-
matched" decision (see repo audit): no shared package exists yet, so each
app repo carries its own local implementation and this document is the
thing that keeps them honest with each other until a real `pet_engine` /
`core_auth` package is justified.

## 1. JWT `app_context` claim

Per the brief §1.7: a user can move between Academy and Wallet seamlessly,
so both apps' token contract and API conventions must match, and the JWT
should identify which app issued the session.

**Proposal:** add a top-level `app_context` claim to the JWT issued by the
backend `identity` module:

```json
{
  "sub": "...",
  "app_context": "academy",  // or "wallet"
  ...
}
```

- Not currently read or written anywhere in this repo — `ApiClient` stores
  an opaque bearer token (`lib/core/network/api_client.dart`) and never
  decodes it. Adding this claim is a backend change; this repo's job is to
  request tokens with the right `app_context` at login/refresh once the
  backend defines the parameter, not to invent the claim's presence today.
- Nothing here assumes a specific claim name is final — propose it to
  confirm before either app repo starts trusting the value for
  app-specific logic (e.g. deciding to reject a Wallet-issued session inside
  Academy or vice versa).

## 2. Academy → Wallet deep-link scheme

Per the brief §1.6. Implemented as a pure URI builder in this repo —
`lib/core/navigation/wallet_deep_link.dart` (`WalletDeepLink`) — **not
wired to a real OS-level launch yet**, since:

- This repo has no deep-linking infrastructure (confirmed absent in the
  repo audit).
- Wallet is not yet a separate installed app — its screens
  (`features/portfolio`, `features/investment`, `features/asset_details`)
  still live in this repo per the "leave in place, build alongside"
  decision, so every current caller (`WalletBridgeCta`, wired into the
  Financial Lab completion footer) uses an **in-app tab switch** as its
  fallback, not a real external link.

**Proposed scheme:**

```
petrimonium://wallet/portfolio?highlight=<concept>
```

- `highlight` is a stable, backend-agnostic concept id. Today's only
  producer is `LabSimulatorId.sourceId` (`compound_interest`, `inflation`,
  `fixed_income`, `diversification`, `portfolio`) from the Financial Lab —
  chosen because those five simulators are the closest existing match to
  the brief's named examples ("diversification, compounding, risk, etc.").
  A future caller could also pass a `Lesson.portfolioConcepts` indicator id
  (`pe`, `dy`, `roe`, ...) — the existing, working
  `PortfolioLearningBridge`/`AppliedConcept` mechanism on
  `AssetDetailsScreen` already uses that vocabulary for a similar "you just
  learned X — here's how it looks on your real asset" moment, just as
  in-app navigation rather than a link. Wallet's own deep-link handler
  should accept either vocabulary without needing to know which produced a
  given value.
- No query params beyond `highlight` are proposed yet — add more only when
  a concrete need exists, not speculatively.

**Graceful degradation** (confirmed working today via `WalletBridgeCta`,
`lib/features/academy/presentation/widgets/wallet_bridge_cta.dart`): a
`null` destination renders as a disabled "Coming soon in Wallet" state,
never a broken/no-op tap target. Once Wallet exists as a separate app, the
missing piece is only the actual `url_launcher`-based external launch +
store-link fallback when the scheme fails to resolve — the CTA/graceful-
degradation shape itself doesn't need to change.

## 3. Pet state schema

Per the brief §1.4: Pet entity/state (species, name, level, mood, history)
is owned by the backend `pet` module and synced via a shared `pet_engine`
contract.

**What exists today, as prior art for the eventual schema:** `PetProfile`
(`lib/features/pet/domain/entities/pet_profile.dart`) — specie, name, xp,
evolution stage, equipped/unlocked accessories, last-active timestamp — is
this repo's current client-side shape, synced today via `MascotRepository`
against the existing backend `gamification`/`pet` endpoints
(`GamificationRemoteDataSource`, `PetRemoteDataSource`). This is a
reasonable starting point for the shared schema, not a finished proposal —
it was authored for Academy's own needs and has never been reviewed against
what Wallet would need from the same Pet.

**What's already isolated, ready to key off whatever schema is agreed:**
the Pet *reaction* layer (`PetBehavior` contract, `lib/features/pet/domain/
behavior/pet_behavior.dart`) is split from Pet *state* — `CorePetBehavior`
reacts only to state changes (XP/level/evolution) that both apps will
receive identically once the schema is shared; `AcademyPetBehavior` and
`PortfolioPetBehavior` (Wallet's future implementation) never touch state
directly. Confirming the schema doesn't require touching the reaction
layer again.

**Not proposed here:** the actual wire format (REST payload shape,
websocket vs. polling, etc.) — that's a backend-repo decision this doc
defers to, once `petrimonium-backend` is in scope for this conversation.

## 4. Packaging status (for context, not new)

`design_system`, `core_auth`, `core_networking`, `pet_engine` are
duplicate-but-contract-matched per the repo audit decision — local code in
each app repo, kept honest by documents like this one rather than a shared
package. Revisit if drift between Academy's and Wallet's local copies
becomes a real, recurring problem — not preemptively.
