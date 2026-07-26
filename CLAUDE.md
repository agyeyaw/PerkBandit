# PerkPilot — Claude Code Guide

## Project Overview

PerkPilot is an AI-powered credit card assistant iOS app. Its mission is to help people get maximum value from every financial product they own — starting with credit cards.

The app includes an intelligent AI companion named **Pilot** that guides users toward better financial decisions through natural language interaction, daily briefings, and proactive benefit reminders.

## Tech Stack

- **Language**: Swift
- **UI Framework**: SwiftUI
- **IDE**: Xcode
- **AI Layer**: Claude API (Anthropic) — interprets user requests, explains recommendations
- **Backend**: Supabase (PostgreSQL, Auth, Realtime)
- **Payments**: RevenueCat
- **Analytics**: PostHog
- **Error Tracking**: Sentry

## Key Principles (from PRD)

1. **Reliability first** — the app must remain usable when an account connection fails
2. **Graceful degradation** — partial functionality when one issuer is unavailable
3. **AI communicates; rules calculate** — the deterministic rules engine produces all financial recommendations; Claude explains them
4. **No fabricated financial data** — AI must never invent rates, benefits, or offers
5. **No dark patterns** — transparent pricing, one-step cancellation, no surprise charges
6. **Explain every recommendation** — show which card, why, estimated value, data freshness, confidence level
7. **Prove financial value** — dashboard always shows value generated vs. subscription cost
8. **Useful without bank linking** — full value available through manual card entry

## Folder Structure

```
PerkPilot/
├── PerkPilot.xcodeproj/          # Xcode project file
├── PerkPilot/                    # Main app source
│   ├── PerkPilotApp.swift        # App entry point
│   ├── ContentView.swift         # Root view
│   ├── Models/                   # Data models (Card, Benefit, Offer, Recommendation)
│   ├── Views/                    # SwiftUI views organized by feature
│   │   ├── Onboarding/
│   │   ├── Portfolio/
│   │   ├── Recommendations/
│   │   ├── Benefits/
│   │   ├── Pilot/                # AI assistant chat UI
│   │   └── ROI/
│   ├── Services/                 # Network, Supabase, Claude API
│   ├── Engine/                   # Deterministic recommendation engine
│   └── Utilities/
├── docs/
│   └── PRD.md
├── CLAUDE.md
├── README.md
└── TODO.md
```

## Build & Run Instructions

1. Open `PerkPilot.xcodeproj` in Xcode
2. Select a simulator (iPhone 15 Pro or later recommended) or your device
3. Press `Cmd+R` to build and run
4. No environment variables are required for the initial boilerplate

## Architectural Rules

- **Rules engine calculates; AI explains.** All reward rates, benefit values, and card recommendations must come from a deterministic, testable rules engine. Claude may interpret natural language queries and explain the output, but must never generate financial figures.
- **No silent stale data.** Every data point shown to the user must display its source and last-verified timestamp.
- **Manual fallback always available.** Users must be able to add cards and track benefits manually without any bank connection.
- **Connection failures are isolated.** A broken issuer connection must never make the entire app unusable.
- **Separate concerns.** UI layers never call the recommendation engine directly — go through a service layer.

## Important Files

| File | Purpose |
|------|---------|
| `PerkPilot/PerkPilotApp.swift` | App entry point (`@main`) |
| `PerkPilot/ContentView.swift` | Root SwiftUI view |
| `docs/PRD.md` | Full product requirements document |
| `TODO.md` | Phased implementation task list |
