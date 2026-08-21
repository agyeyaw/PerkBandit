xe# PerkBandit

**Your reward hunter for perks, credits, and hidden benefits.**

---

## Vision

Help people obtain the maximum value from every financial product they own. PerkBandit starts with credit cards and grows into a broader financial benefit platform.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile | Swift + SwiftUI (iOS) |
| AI | Claude API (Anthropic) |
| Backend / Database | Supabase (PostgreSQL) |
| Payments | RevenueCat |
| Analytics | PostHog |
| Error Tracking | Sentry |

---

## Getting Started

### Prerequisites

- Xcode 16 or later
- iOS 17 SDK or later
- An Apple Developer account (for device builds)

### Setup

1. Clone the repository
2. Open `PerkBandit.xcodeproj` in Xcode
3. Select a simulator or connected device
4. Press `Cmd+R` to build and run

No additional environment variables are required to run the initial boilerplate.

---

## Documentation

- [Product Requirements Document](docs/PRD.md) — full PRD including vision, problem statement, feature specs, and acceptance criteria
- [TODO](TODO.md) — phased task list organized by build phase
- [CLAUDE.md](CLAUDE.md) — architectural rules and guidance for AI-assisted development

---

## Build Phases

| Phase | Focus |
|-------|-------|
| **Phase 1** | Manual-First MVP — card catalog, portfolio, recommendations, benefits, AI assistant, ROI, notifications, subscription |
| **Phase 2** | Limited Sync Beta — institution connections, transaction import, automated credit detection, welcome-bonus tracking |
| **Phase 3** | Expanded Automation — more issuers, card-linked offers, household portfolios, annual card review |
| **Phase 4** | Broader Platform — loyalty programs, subscription optimizer, banking benefits, travel rewards |

---

## Core Product Principles

1. Reliability before feature quantity
2. The app remains usable when an account connection fails
3. AI explains; a deterministic rules engine calculates
4. No fabricated financial data
5. No dark patterns — transparent pricing and easy cancellation
6. Every recommendation includes an explanation, data source, and confidence level

---

## License

License TBD.
