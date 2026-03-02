# SaaS Launch Readiness Audit — Claude Code Prompt

> **How to use:** Paste this entire prompt into Claude Code at the root of your SaaS project.
> It will analyze the codebase, cross-reference with issues, and generate a comprehensive `LAUNCH_READINESS.md` report.

---

## The Prompt

```
You are a technical audit specialist for SaaS products. Your mission is to perform a complete analysis of this project, map all implemented and missing features, cross-reference with existing issues, and generate a comprehensive launch readiness report.

## PHASE 1: Complete System Mapping

### 1.1 — Project Structure Analysis
Before anything else, perform a complete mapping:

- Project structure (files, folders, configs)
- Package dependencies and versions
- Environment variables needed (.env.example)
- Database schemas and migrations
- Application routes (pages and API endpoints)
- External service integrations

### 1.2 — Feature Inventory
For EACH feature category below, check the code to determine if it is implemented, partially implemented, or absent. Search routes, components, API endpoints, models/schemas, and migrations:

**CORE FUNCTIONALITY:**
- [ ] Primary data input/ingestion mechanism
- [ ] Core data processing/transformation logic
- [ ] Main output/results display
- [ ] Data storage and retrieval
- [ ] Core API endpoints functional
- [ ] Error handling for core flows

**AUTHENTICATION & ACCOUNTS:**
- [ ] User registration (email/password)
- [ ] Login/Logout
- [ ] OAuth providers (Google, GitHub, etc.)
- [ ] Password recovery
- [ ] Email verification
- [ ] User profile management
- [ ] Account deletion (GDPR/privacy compliance)

**MONETIZATION:**
- [ ] Plans/tiers defined (Free, Pro, Business, etc.)
- [ ] Payment gateway integration (Stripe, etc.)
- [ ] Subscription management
- [ ] Usage limits per plan
- [ ] Pricing page
- [ ] Trial/free-tier period
- [ ] Webhook handlers for payment events

**LANDING PAGE & MARKETING:**
- [ ] Hero section with clear value proposition
- [ ] Features/benefits section
- [ ] Product demo or preview
- [ ] Pricing section
- [ ] FAQ section
- [ ] Testimonials/social proof
- [ ] Sign-up CTA
- [ ] SEO basics (meta tags, sitemap, robots.txt)
- [ ] Analytics integration (GA, PostHog, etc.)

**COMPLIANCE & LEGAL:**
- [ ] Terms of Service
- [ ] Privacy Policy
- [ ] Cookie consent banner
- [ ] Data processing consent
- [ ] Data export option
- [ ] Data deletion option

**INFRASTRUCTURE:**
- [ ] Deploy configured (Vercel, AWS, etc.)
- [ ] Domain with active SSL
- [ ] CI/CD pipeline
- [ ] Automated tests
- [ ] Error monitoring (Sentry, etc.)
- [ ] Structured logging
- [ ] Rate limiting
- [ ] Database backups
- [ ] CDN configured

**USER EXPERIENCE:**
- [ ] Guided onboarding
- [ ] Visual feedback during processing
- [ ] Empty states with CTAs
- [ ] Loading states
- [ ] Friendly error handling
- [ ] Mobile responsiveness
- [ ] Dark mode (if applicable)
- [ ] Accessibility basics

---

## PHASE 2: Issue Cross-Reference

### 2.1 — Existing Issues
List all existing issues in the repository using:
```bash
gh issue list --state all --limit 200 --json number,title,state,labels,body,assignees,milestone,createdAt,closedAt
```

### 2.2 — For Each Existing Issue
Analyze the codebase and classify:
- IMPLEMENTED — functional code found (indicate file)
- PARTIAL — code exists but incomplete or buggy (indicate what's missing)
- NOT IMPLEMENTED — no related code found
- OBSOLETE — no longer relevant to current scope

---

## PHASE 3: Gap Analysis & New Issues

Based on Phase 1 analysis, create issues for everything missing that is needed for launch.

### Priority Levels:

**P0 — LAUNCH BLOCKERS (cannot launch without these):**
- Core functionality working end-to-end
- Authentication complete (signup, login, password reset)
- Landing page functional with CTA
- Terms of Service and Privacy Policy
- Stable deploy with SSL
- Minimum onboarding flow

**P1 — IMPORTANT (ship within 2 weeks post-MVP):**
- Plans and payments (at least 1 free + 1 paid plan)
- Basic SEO
- Usage analytics
- Rate limiting and basic security
- Transactional emails

**P2 — NICE TO HAVE (v1.1+):**
- Advanced features and integrations
- API for third-party developers
- Multi-user workspaces
- Advanced analytics and reporting
- Scheduled reports or automations

### Issue Creation Format:
```bash
gh issue create --title "TITLE" --body "BODY" --label "LABEL"
```

Suggested labels: `P0-blocker`, `P1-important`, `P2-nice-to-have`, `bug`, `feature`, `enhancement`, `infra`, `docs`, `design`

---

## PHASE 4: Differentiating Features

Assess which features could differentiate this product in the market:

1. What unique capabilities does this product have or could quickly add?
2. What pain points do competitors fail to address?
3. Which features have the highest value-to-effort ratio?

For each differentiating feature:
- Check if anything exists in the code
- Estimate complexity (S/M/L)
- Mark if it should be in MVP or deferred

---

## PHASE 5: Generate Output

Create `LAUNCH_READINESS.md` at the project root with:

### Section 1: Executive Summary
- Overall completeness estimate (%)
- Estimated viable launch date
- Key risks

### Section 2: Feature Map
Table with ALL analyzed features:

| Feature | Status | Evidence (file) | Priority | Effort |
|---|---|---|---|---|
| User Registration | DONE/PARTIAL/MISSING | `/src/...` | P0/P1/P2 | S/M/L |
| ... | ... | ... | ... | ... |

### Section 3: Issues (existing + created)
Table with all issues:

| # | Title | Status | Priority | Implemented? |
|---|---|---|---|---|
| 1 | ... | open/closed | P0/P1/P2 | DONE/PARTIAL/MISSING |

### Section 4: Launch Roadmap
Suggested implementation order for fastest launch:
1. Sprint 1 (week 1-2): [P0 tasks]
2. Sprint 2 (week 3-4): [remaining P0 + critical P1]
3. Sprint 3 (week 5-6): [P1 + polish]
4. Backlog v1.1: [P2]

### Section 5: Pre-Launch Checklist
- [ ] All env vars configured in production
- [ ] Database migrations applied in production
- [ ] SSL active and working
- [ ] Terms of Service and Privacy Policy published
- [ ] Analytics configured (GA/PostHog)
- [ ] Error monitoring active (Sentry or equivalent)
- [ ] Full flow tested (signup -> core action -> result)
- [ ] Mobile tested
- [ ] Backups configured
- [ ] Rate limiting active
- [ ] Transactional emails working (welcome, password reset)
- [ ] DNS and domain pointing correctly
- [ ] Open Graph tags for social sharing
- [ ] sitemap.xml and robots.txt

### Section 6: Stack & Dependencies
List all external dependencies and their costs:
- API services: estimated cost per usage
- Hosting: monthly cost
- Database: monthly cost
- Transactional email: monthly cost
- Payment gateway: fees
- Domain: annual cost
- **Estimated total monthly operating cost**

---

## Execution Rules

1. **Do not assume** — verify each item directly in the code
2. **If something is ambiguous**, mark as "requires manual verification"
3. **Prioritize launch speed** over perfection
4. **MVP mindset** — what is the minimum viable to ship with acceptable quality?
5. **If no issues exist**, create all necessary ones based on the analysis
6. **If issues exist**, cross-reference with code analysis and update status
7. **Document EVERYTHING** in LAUNCH_READINESS.md
8. **When creating issues**, use clear descriptions with acceptance criteria
9. **Estimate effort** as: S (few hours), M (1-2 days), L (3-5 days), XL (1+ week)
10. **Consider your target market** — date formats, currency, language, payment methods

Start the analysis now. Read the entire project first, then generate the report.
```

---

## Variations

### For early-stage projects (idea/code only)
Append to the prompt:
```
ADDITIONAL CONTEXT: This project is early-stage with no users yet. Focus on identifying the minimum set of features someone would pay to use.
```

### For projects with users but no revenue
Append to the prompt:
```
ADDITIONAL CONTEXT: This project already has active users but charges nothing. Focus on monetization strategies that won't alienate the current base — such as introducing a premium plan without removing existing features (freemium model).
```

### For projects already generating revenue
Append to the prompt:
```
ADDITIONAL CONTEXT: This project already generates [$X/month]. Focus on growth levers — increasing average ticket, reducing churn, improving trial conversion, and scaling acquisition.
```
