# PerkPilot — Build Tasks

## Phase 1: Manual-First MVP

### Card Catalog
- [ ] Define `CardProduct` data model (issuer, name, annual fee, reward rules, benefits)
- [ ] Build static card catalog with top 20–30 US cards
- [ ] Card search and filter UI
- [ ] Card detail view (rates, benefits, protections)

### Manual Portfolio
- [ ] `UserCard` model (open date, renewal date, connection status)
- [ ] Add card flow (select from catalog or enter manually)
- [ ] Portfolio list view with card status indicators
- [ ] Card detail / edit view
- [ ] Delete / remove card

### Recommendation Engine
- [ ] Deterministic rules engine architecture (no AI-generated financial data)
- [ ] Merchant category mapping
- [ ] Base reward rate lookup
- [ ] Spending cap logic
- [ ] Rotating category support
- [ ] Offer overlay
- [ ] Point valuation table
- [ ] Best-card output: card + estimated value + explanation + confidence + data freshness
- [ ] Recommendation UI (search by merchant, category, or amount)
- [ ] Comparison view (ranked alternatives)
- [ ] Unit tests for all reward rules

### Benefits Calendar
- [ ] `Benefit` model (name, value, frequency, expiration rule, redemption instructions)
- [ ] `UserBenefitStatus` model (used/remaining/verification method)
- [ ] Benefits dashboard sections: Use this week / Expiring this month / Available / Used / Needs confirmation
- [ ] Manual benefit mark-as-used
- [ ] Redemption instructions detail view
- [ ] Calendar view of upcoming expirations

### AI Assistant (Pilot)
- [ ] Claude API integration (structured tool calling)
- [ ] Pilot chat UI
- [ ] Daily briefing on home screen
- [ ] Context injection: user's portfolio, benefits, recommendations
- [ ] Guardrails: AI must reference rules engine output, not invent figures
- [ ] Source + timestamp display on every AI response
- [ ] Clarification prompts for ambiguous queries
- [ ] Limited free-tier question quota

### ROI Tracking
- [ ] Value tracking data model
- [ ] Dashboard metrics: rewards earned, credits recovered, offers used, expiration losses avoided
- [ ] Net portfolio value (total estimated annual value minus annual fees)
- [ ] Subscription cost vs. value generated display
- [ ] Monthly and lifetime totals

### Notifications
- [ ] Notification types: benefit expiring, offer expiring, annual fee approaching, welcome-bonus deadline, category activation required, subscription renewal
- [ ] Per-category notification settings (user can disable each type)
- [ ] Promotional notifications require separate opt-in
- [ ] Every alert includes a deep-link action
- [ ] No duplicate alerts

### Transparent Subscription Flow
- [ ] Pricing screen shown before account creation
- [ ] Free tier and premium tier clearly described
- [ ] Monthly and annual plan options (RevenueCat)
- [ ] Renewal reminders
- [ ] One-step cancellation
- [ ] Restore purchase functionality
- [ ] Subscription status always visible in settings

---

## Phase 2: Limited Sync Beta

- [ ] Select initial set of supported institutions (Chase, Amex, Capital One)
- [ ] Connection health center UI (status, last sync, stale data warnings, retry, manual fallback)
- [ ] Transaction import pipeline
- [ ] Automated credit detection from transactions
- [ ] Welcome-bonus progress tracking (automated)
- [ ] Stale-data safeguards (timestamps, warnings, no silent display of outdated info)
- [ ] Proactive outage notifications
- [ ] Integration status page

---

## Phase 3: Expanded Automation

- [ ] Additional issuer integrations (Citi, Discover, Bilt, Apple Card, etc.)
- [ ] Card-linked offer tracking and activation
- [ ] Household portfolio sharing
- [ ] Redemption assistant (point transfer partners, optimal redemption paths)
- [ ] Annual card review flow
- [ ] Keep / downgrade / cancel analysis with data-backed recommendation

---

## Phase 4: Broader Financial Value Platform

- [ ] Loyalty program assistant (airline miles, hotel points)
- [ ] Subscription benefit optimizer
- [ ] Banking benefit assistant
- [ ] Travel rewards planner
- [ ] Employer benefit optimizer
- [ ] Insurance benefit assistant

---

## Cross-Cutting Concerns (all phases)

- [ ] Accessibility: VoiceOver support, Dynamic Type, sufficient contrast, non-color labels
- [ ] In-app support ticket creation and history
- [ ] Human escalation for billing and account issues
- [ ] Diagnostics automatically attached to tickets
- [ ] Self-service account deletion
- [ ] Privacy policy and data usage disclosures
- [ ] Sentry error tracking integration
- [ ] PostHog analytics (activation, engagement, reliability metrics)
