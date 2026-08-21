# AI Credit Card Assistant — Product Requirements Document

## Brand Direction

The company should be positioned around a broader mission:

> **Help people get the maximum value from every financial product they own.**

The credit card assistant is the first product, not the full identity of the company. Because of that, the brand name should ideally be broad enough to expand into rewards, loyalty programs, subscriptions, travel benefits, banking benefits, insurance perks, and other financial optimization tools.

---

## Brand Name Ideas

### Strongest Options

#### 1. Valora
**Why it works:** Sounds like value, optimization, and financial improvement without being limited to credit cards.

**Possible tagline:**  
*Get more value from every card you own.*

#### 2. Maxfolio
**Why it works:** Combines “maximize” and “portfolio.” It fits users managing several cards and can later expand beyond credit cards.

**Possible tagline:**  
*Maximize every card in your wallet.*

#### 3. Cardwise
**Why it works:** Clear, simple, and immediately communicates smarter credit card decisions.

**Possible tagline:**  
*Use every card more intelligently.*

#### 4. PerkPilot
**Why it works:** Communicates guidance, rewards, benefits, and assistance. It feels more like an assistant than a tracker.

**Possible tagline:**  
*Your copilot for rewards and card benefits.*

#### 5. ValuePilot
**Why it works:** Broad enough to expand into other financial products while still fitting the current app.

**Possible tagline:**  
*Navigate every financial benefit with confidence.*

#### 6. Rewardly
**Why it works:** Friendly and consumer-focused. It clearly suggests rewards without sounding too technical.

**Possible tagline:**  
*Never leave rewards unused.*

#### 7. CardPilot
**Why it works:** Directly communicates an assistant that helps users make decisions.

**Possible tagline:**  
*Know the right card every time.*

#### 8. OptiCard
**Why it works:** Short for card optimization. Very clear product positioning.

**Possible tagline:**  
*Optimize every purchase.*

#### 9. Valence
**Why it works:** A more premium, abstract name tied to strength and value. It could grow into a broader financial brand.

**Possible tagline:**  
*Make every financial product work harder.*

#### 10. BenefitOS
**Why it works:** Positions the product as an operating system for benefits rather than a basic tracker.

**Possible tagline:**  
*The operating system for your financial benefits.*

# 1. Product Vision

## Vision

Help people obtain the maximum value from every financial product they own.

The AI credit card assistant is the company’s first product and entry point. Future products may expand into banking benefits, subscriptions, loyalty programs, insurance benefits, travel rewards, and other areas of personal financial optimization.

## Mission

> **Make financial benefits understandable, actionable, and effortless.**

## Product Positioning

This is not primarily a credit card tracker.

It is an **AI credit card assistant** that tells users what action to take, explains why, and measures the value generated.

## Core Promise

> **Never miss a benefit, waste a reward, or wonder which card to use.**

---

# 2. Problem Statement

People who own several credit cards often struggle to manage them effectively because information is fragmented across issuers.

They commonly:

- Forget monthly and annual credits
- Miss offer and reward expiration dates
- Use the wrong card for purchases
- Fail to complete welcome bonuses
- Pay annual fees for cards that no longer provide enough value
- Do not understand how to redeem points
- Forget rotating reward categories
- Spend time checking multiple issuer apps
- Lose trust in third-party assistants because of inaccurate data and broken synchronization

Existing competitors attempt to solve these issues but receive repeated complaints involving:

- Bank and card sync failures
- Inaccurate recommendations
- Slow performance and crashes
- Excessive manual work
- Generic information
- Poor customer support
- Confusing interfaces
- Aggressive upselling
- Hidden pricing
- Difficult cancellations and refunds
- Security and privacy concerns
- Weak free tiers
- Unsupported cards and issuers

---

# 3. Main Competitor Problems to Solve

## 3.1 Reliability and Synchronization Failures

Competitor users repeatedly report:

- Accounts disconnecting
- Chase, Amex, Capital One, Bilt, Apple Card, and other cards failing to sync
- Repeated login and multifactor authentication requests
- Offers failing to activate
- Benefits and balances becoming outdated
- Cards disappearing
- Slow synchronization
- Apps freezing or crashing
- Paid features failing after purchase

### Product Response

The app should follow this rule:

> **A broken connection must never make the entire app useless.**

Requirements:

- Separate connection status for every account
- Automatic retries
- Clear last-updated timestamps
- Manual fallback tracking
- Partial functionality when one issuer is unavailable
- Plain-language error explanations
- Integration status page
- Proactive outage notifications
- No silent display of stale information

---

## 3.2 Poor Customer Support

Competitor users report:

- Emails receiving no response
- Refund requests being ignored
- Being redirected to unhelpful chatbots
- No clear human support option
- Generic responses without resolution
- Repeating the same troubleshooting steps
- No ownership of ongoing connection issues

### Product Response

Support should be part of the product.

Requirements:

- In-app support tickets
- Ticket status and history
- Human escalation for billing, security, and account access
- Diagnostics automatically attached to tickets
- Published response-time targets
- Resolution notifications
- Automatic outage detection before asking the user to troubleshoot

---

## 3.3 Poor Value for Price

Competitor users often question paying $70 to $168 per year for information they believe is:

- Already available from issuers
- Too generic
- Inaccurate
- Hidden behind paywalls
- Not valuable enough to recover the subscription cost
- Dependent on unreliable integrations

### Product Response

The product should continuously prove its value.

The dashboard should show:

- Additional rewards earned
- Credits saved before expiration
- Offers successfully used
- Annual fees offset
- Money saved through better card selection
- Value generated this month
- Lifetime value generated
- Subscription cost compared with value generated

Example:

> **Your assistant generated $184.60 in additional value this year.**

---

## 3.4 Billing, Refund, and Cancellation Problems

Competitor complaints include:

- Unexpected annual charges
- Being charged after cancellation
- Trials converting without warning
- Subscriptions not appearing in Apple’s subscription manager
- Confusing cancellation flows
- Paid memberships not being recognized
- Refund requests being ignored
- Pricing hidden until late in onboarding

### Product Response

Billing philosophy:

> **A customer should never be surprised by a charge.**

Requirements:

- Pricing displayed before account creation
- No bank connection required to view pricing
- Renewal reminders
- One-step cancellation
- Immediate cancellation confirmation
- Visible subscription status
- Restore-purchase functionality
- Reasonable accidental-purchase refund policy
- Monthly and annual options
- No dark patterns

---

## 3.5 Inaccurate Recommendations and Data

Competitor users report:

- Lower-reward cards recommended over better cards
- The same card recommended for almost every purchase
- Incorrect cashback rates
- Temporary offers ignored
- Merchant categories classified incorrectly
- Benefits tracked inaccurately
- No user preference customization
- No explanation behind recommendations

### Product Response

AI should explain decisions, but a deterministic rules engine should calculate them.

The recommendation system should account for:

- Base earning rates
- Merchant categories
- Temporary issuer offers
- Rotating categories
- Spending caps
- Welcome-bonus progress
- Monthly and annual credits
- Point valuations
- Transfer partner value
- User card preferences
- Credit utilization preferences
- Card renewal timing
- Whether benefits have already been used

Every recommendation should explain:

- Which card to use
- Why it is best
- Estimated reward value
- Relevant credits
- Comparison with alternatives
- Confidence level
- Data freshness

---

## 3.6 Generic Information Instead of Actionable Guidance

Competitors often tell users what a card does rather than what the user should do next.

### Product Response

The app should answer:

- Which card should I use?
- Which benefits are about to expire?
- Is this annual fee worth paying?
- Should I cancel or downgrade this card?
- How should I redeem my points?
- Which offer applies to this purchase?
- What should I do this week?
- How much value did I leave unused last month?

---

## 3.7 Confusing Navigation and Cluttered Interfaces

Competitor complaints include:

- Important features being hard to find
- Overloaded dashboards
- Too many upgrade prompts
- Difficult setup
- Lost onboarding progress
- Poor redemption instructions
- Too much setup before showing value

### Product Response

The home screen should prioritize:

1. Best action today
2. Benefits requiring attention
3. Best card for a purchase
4. Value generated
5. Portfolio health

---

## 3.8 Excessive Manual Work

Competitor users still have to:

- Manually mark credits as used
- Reconnect accounts
- Re-enter authentication
- Add merchant offers manually
- Update bonus progress
- Verify balances
- Check issuer apps for correct information

### Product Response

Principle:

> **When the app can determine something reliably, the user should not have to enter it.**

Each data point should be labeled as:

- Verified automatically
- Estimated
- Manually entered
- Needs confirmation

---

# 4. Target Users

## Primary User

A US credit card holder who:

- Owns 3 to 10 cards
- Wants to maximize cashback, points, and benefits
- Does not want to maintain spreadsheets
- Understands basic rewards but is not an expert
- Frequently forgets credits, offers, or categories
- Values convenience and trustworthy recommendations

## Secondary Users

- Beginners with 1 to 2 cards
- Points and travel enthusiasts
- Couples managing cards together
- Users completing welcome bonuses
- People deciding whether to keep annual-fee cards

---

# 5. Jobs to Be Done

- When I am about to make a purchase, help me choose the card that produces the most value.
- When I own several cards, show me which benefits require attention.
- When I pay annual fees, show me whether each card produces more value than it costs.
- When I earn points, explain the best ways to redeem them.
- When an account stops syncing, explain what happened and keep the rest of the app usable.
- When I pay for the service, show me how much value it generated.

---

# 6. Product Principles

1. Reliability before feature quantity
2. Graceful degradation
3. Explain every recommendation
4. Show data freshness
5. Prove financial value
6. Respect user control
7. Useful without bank linking
8. No dark patterns
9. AI communicates; rules calculate
10. Every important screen should recommend a next action

---



# 7. MVP Scope

## 7.1 Onboarding

Users select goals:

- Earn more cashback
- Maximize travel rewards
- Track benefits
- Complete welcome bonuses
- Decide which cards to keep

Users can:

- Explore a demo portfolio
- Add cards manually
- Connect accounts later

Requirements:

- Save progress automatically
- No bank credentials required to preview the product
- Show pricing before account creation
- Allow skipping optional steps

---

## 7.2 Card Portfolio

Each card should display:

- Card name and issuer
- Annual fee
- Renewal date
- Reward categories
- Current offers
- Monthly and annual credits
- Welcome-bonus progress
- Points or cashback balance
- Last successful update
- Connection status
- Estimated annual value
- Keep, downgrade, or cancel analysis

Status labels:

- Connected
- Needs attention
- Temporarily unavailable
- Manually managed
- Data may be outdated

---

## 7.3 Best-Card Recommendation Engine

Users can search by:

- Merchant
- Spending category
- Purchase description
- Location
- Website
- Purchase amount

Output:

- Recommended card
- Expected points or cashback
- Estimated dollar value
- Relevant credits or protections
- Comparison with alternatives
- Explanation of assumptions
- Data freshness
- Confidence level

Important requirement:

The recommendation must be generated by a deterministic rules engine. AI may interpret natural language and explain the output, but it must not invent rates or benefits.

---

## 7.4 Benefits and Credits Dashboard

Sections:

- Use this week
- Expiring this month
- Available anytime
- Already used
- Possibly used — confirmation required

Each benefit should include:

- Benefit name
- Card
- Available amount
- Used amount
- Remaining amount
- Expiration date
- Redemption instructions
- Eligible merchants
- Verification status
- Data source

---

## 7.5 AI Assistant

Example questions:

- What card should I use at Costco?
- Which benefits expire this month?
- Am I getting enough value from my Amex Platinum?
- How should I redeem 80,000 Chase points?
- Which card should I use for a $1,200 hotel stay?
- Why did you recommend this card?
- What should I do this week?
- Should I cancel or downgrade this card?

AI requirements:

- Use verified data
- Clearly identify estimates
- Never fabricate rates or benefits
- Show sources and last-updated dates
- Ask for clarification when needed
- Explain tradeoffs

---

## 7.6 Value and ROI Dashboard

Metrics:

- Additional rewards earned
- Benefits recovered
- Offers used
- Expiration losses avoided
- Estimated value generated
- Annual fees
- Net portfolio value
- Subscription cost
- Net value after subscription

Only count value that can reasonably be attributed to the app.

---

## 7.7 Notifications

Notification types:

- Benefit expiring
- Offer expiring
- Annual fee approaching
- Welcome-bonus deadline
- Category activation required
- Account connection needs attention
- Subscription renewal
- New high-value action
- Payment due-date reminder when verified

Requirements:

- Users can disable each category
- Disabled settings must be respected
- Promotional notifications require separate consent
- Avoid duplicate alerts
- Every alert should include an action

---

## 7.8 Connection Health Center

For each issuer, display:

- Current status
- Last successful sync
- Data that remains current
- Data that may be stale
- Error explanation
- Retry option
- Manual fallback
- Known outage status

The app must remain usable if one connection fails.

---

## 7.9 Support Center

Features:

- In-app ticket creation
- Ticket history
- Automatic diagnostic attachment
- Human escalation
- Known issue status
- Expected response time
- Resolution notifications

---

# 8. Monetization

## Free Tier

- Manual card portfolio
- Basic best-card recommendations
- Reward category information
- Basic benefit calendar
- Annual fee reminders
- Manual benefit tracking
- Limited AI questions
- Basic portfolio value estimate

## Premium Tier

- Automatic account synchronization
- Transaction-based benefit detection
- Card-linked offer tracking
- Unlimited AI assistant
- Welcome-bonus automation
- Advanced redemption strategies
- Detailed ROI dashboard
- Household sharing
- Advanced annual-fee analysis
- Priority support

Pricing principles:

- Show prices before signup
- Offer monthly and annual plans
- Send renewal reminders
- Make cancellation easy
- Allow return to free tier
- Do not require financial data before users can evaluate the app

---

# 9. Out of Scope for Initial Release

- Credit card applications
- Credit score repair
- Automatic cancellation of cards
- Automatic point transfers
- Automated financial transactions
- Every loyalty program
- Full travel booking
- Investment, loan, or insurance recommendations

---

# 10. Technical Architecture

## Mobile App

- React Native
- Expo
- TypeScript
- Expo Router
- TanStack Query
- Zustand

## Backend

- TypeScript
- NestJS
- PostgreSQL
- Supabase
- Redis
- BullMQ or similar job queue

## AI Layer

- Claude API
- Structured tool calling
- Retrieval from verified card data
- No direct AI generation of financial rules

## Recommendation Engine

Standalone rules service containing:

- Card rules
- Reward categories
- Spending caps
- Offers
- Benefit eligibility
- Point valuations
- Merchant mappings
- User preferences

## Financial Connectivity

Use recognized aggregators or issuer-supported OAuth where available.

Evaluate providers based on:

- Issuer coverage
- Freshness
- Reliability
- OAuth support
- Cost
- Security
- Access to balances and transactions

Do not store raw banking passwords directly.

## Additional Services

- RevenueCat
- Sentry
- PostHog
- Expo Notifications or OneSignal
- Feature flags
- Integration status page

---

# 11. Core Data Model

## User

- ID
- Email
- Authentication provider
- Preferences
- Subscription status
- Notification settings
- Point valuations
- Created date

## CardProduct

- Issuer
- Card name
- Network
- Annual fee
- Reward rules
- Benefits
- Protections
- Foreign transaction fee
- Source
- Last verified date

## UserCard

- User ID
- Card product ID
- Open date
- Renewal date
- Credit limit, optional
- Current balance, optional
- User preference rank
- Connection ID
- Sync status

## Benefit

- Card product ID
- Name
- Value
- Frequency
- Eligibility rules
- Expiration rule
- Redemption instructions

## UserBenefitStatus

- User card ID
- Benefit ID
- Period
- Amount used
- Amount remaining
- Verification method
- Last updated

## Offer

- Issuer
- Merchant
- Eligibility
- Reward
- Start date
- Expiration date
- Activation requirement
- Source
- Last verified

## Recommendation

- User
- Merchant or category
- Purchase amount
- Recommended card
- Alternatives
- Expected value
- Explanation factors
- Confidence
- Data timestamp

## Connection

- Provider
- Institution
- Status
- Last successful sync
- Last attempt
- Error category
- Data freshness

---

# 12. Nonfunctional Requirements

## Reliability

- The app remains usable when an integration fails
- No failed account blocks the dashboard
- Critical screens can load cached data

## Accuracy

- Reward logic has automated tests
- Card data updates require source verification
- Recommendations are reproducible
- Users can report incorrect data

## Performance

- Dashboard target load: under 2 seconds with cached data
- Standard recommendation lookup: under 1 second
- AI responses begin streaming quickly
- Card setup progress is preserved

## Security

- Encryption in transit and at rest
- OAuth preferred
- Least-privilege access
- Row-level data isolation
- Audit logs
- Self-service account deletion
- Clear privacy policy
- No sale of personal financial data

## Accessibility

- Screen reader support
- Dynamic text sizing
- Sufficient contrast
- Labels beyond color
- Accessible errors and controls

---

# 13. Success Metrics

## North Star Metric

> **Verified incremental financial value generated per active user.**

## Activation Metrics

- Users adding at least 2 cards
- Users receiving a useful recommendation in first session
- Time to first value
- Users completing onboarding without bank connection

## Engagement Metrics

- Weekly active users
- Recommendations requested
- Benefits claimed
- Expiring benefits saved
- AI assistant usage
- Notification-to-action conversion

## Reliability Metrics

- Successful sync rate by issuer
- Median sync duration
- Reconnection rate
- Crash-free session rate
- Recommendation correction rate
- Stale data incidents

## Business Metrics

- Free-to-premium conversion
- Renewal rate
- Refund rate
- Churn reasons
- Value generated versus subscription cost
- Support tickets per 1,000 users

---

# 14. MVP Acceptance Criteria

The MVP is ready for beta when:

1. A user can add at least 3 cards manually
2. The system recommends the best card for common categories
3. Every recommendation includes an explanation and timestamp
4. Users can track monthly and annual benefits
5. Users receive expiration reminders
6. Users can see estimated value generated
7. The dashboard works when integrations fail
8. Notification settings are respected
9. Users can cancel and delete accounts without support
10. Recommendation logic passes automated tests
11. No critical crash blocks onboarding or card addition
12. Support tickets can be created and tracked

---

# 15. Build Phases

## Phase 1: Manual-First MVP

Build:

- Card catalog
- Manual portfolio
- Recommendation engine
- Benefits calendar
- AI assistant
- ROI tracking
- Notifications
- Transparent subscription flow

## Phase 2: Limited Sync Beta

Add:

- Small set of supported institutions
- Connection health center
- Transaction import
- Automated credit detection
- Welcome-bonus tracking
- Stale-data safeguards

## Phase 3: Expanded Automation

Add:

- More issuers
- Card-linked offers
- Household portfolios
- Redemption assistant
- Annual card review
- Keep, downgrade, or cancel analysis

## Phase 4: Broader Financial Value Platform

Potential future products:

- Loyalty program assistant
- Subscription benefit optimizer
- Banking benefit assistant
- Travel rewards planner
- Employer benefit optimizer
- Insurance benefit assistant

---

# 16. Initial Prompt for Claude

```text
You are acting as the senior product engineer for an AI credit card assistant.

The product is not merely a credit card tracker. Its mission is to help people obtain the maximum value from every credit card they own. The credit card assistant is the first product of a broader financial value company.

Read the attached PRD completely before producing code.

Prioritize the following principles in every implementation decision:

1. Reliability before feature quantity.
2. The app must remain usable when an account connection fails.
3. Users must receive meaningful value without linking a bank account.
4. Financial calculations must come from a deterministic and testable rules engine, not from an AI model.
5. AI should interpret requests and explain verified calculations.
6. Every recommendation must show why it was made.
7. Every financial value must show its source, freshness, and verification status.
8. Pricing, cancellation, renewal, and refunds must be transparent.
9. Do not use dark patterns.
10. The interface should tell users what action to take next rather than overwhelm them with information.

Do not attempt to build the entire application in one response.

Begin by producing:

1. A proposed monorepo folder structure.
2. The initial PostgreSQL schema.
3. TypeScript interfaces for cards, reward rules, benefits, offers, and recommendations.
4. The architecture of the deterministic recommendation engine.
5. A milestone-based implementation plan for the manual-first MVP.
6. Risks, assumptions, and unresolved questions.

Do not generate UI code until the data model and recommendation engine design are approved.
```
