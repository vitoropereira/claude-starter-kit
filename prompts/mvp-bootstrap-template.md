# MVP Bootstrap Template — Claude Code Prompt

> **How to use:** Copy this prompt, fill in the placeholders marked with `[PLACEHOLDER]`, and paste the entire thing into Claude Code. It will scaffold and build a deployable MVP in a single session.

---

## The Prompt

```
You will develop [PROJECT_NAME], a [ONE_LINE_DESCRIPTION]. The user [CORE_USER_ACTION] and the system [CORE_SYSTEM_RESPONSE].

**Objective**: MEP (Minimum Executable Product) — functional and deployable in 1 session.

**My technical level**: [BEGINNER/INTERMEDIATE/ADVANCED]. [Adjust explanations accordingly.]

**IMPORTANT**: This is a lean MEP. Do NOT implement: [LIST_FEATURES_TO_EXCLUDE]. Only the core.

---

## TECH STACK

- **Framework**: [e.g., Next.js 14 (App Router)]
- **Language**: [e.g., TypeScript]
- **Styling**: [e.g., Tailwind CSS + shadcn/ui]
- **Database**: [e.g., Neon.tech (PostgreSQL serverless)]
- **ORM**: [e.g., Drizzle ORM]
- **Auth**: [e.g., NextAuth.js v5 (Auth.js) with Google Provider]
- **AI** (if applicable): [e.g., Claude API — model claude-sonnet-4-20250514]
- **Deploy**: [e.g., Vercel]

---

## FOLDER STRUCTURE

[Define the folder structure for your project. Example:]

```
project-name/
├── src/
│   ├── app/
│   │   ├── (main)/
│   │   │   ├── dashboard/
│   │   │   │   └── page.tsx
│   │   │   ├── [feature]/
│   │   │   │   └── [slug]/
│   │   │   │       └── page.tsx
│   │   │   └── layout.tsx
│   │   ├── api/
│   │   │   ├── auth/
│   │   │   │   └── [...nextauth]/
│   │   │   │       └── route.ts
│   │   │   └── [feature]/
│   │   │       ├── generate/
│   │   │       │   └── route.ts
│   │   │       └── [id]/
│   │   │           └── route.ts
│   │   ├── globals.css
│   │   ├── layout.tsx
│   │   └── page.tsx
│   ├── components/
│   │   ├── ui/ (shadcn)
│   │   └── [FeatureComponents].tsx
│   ├── db/
│   │   ├── index.ts
│   │   └── schema.ts
│   └── lib/
│       ├── auth.ts
│       ├── ai.ts (if applicable)
│       └── utils.ts
├── drizzle.config.ts (if using Drizzle)
├── .env.local
└── package.json
```

---

## ENVIRONMENT VARIABLES (.env.local)

```env
# Database
DATABASE_URL="postgres://user:pass@host/dbname?sslmode=require"

# Auth
AUTH_SECRET="generate-with-openssl-rand-base64-32"
AUTH_URL="http://localhost:3000"
AUTH_GOOGLE_ID="xxx.apps.googleusercontent.com"
AUTH_GOOGLE_SECRET="xxx"

# AI (if applicable)
ANTHROPIC_API_KEY="sk-ant-xxx"
# or OPENAI_API_KEY="sk-xxx"

# App
NEXT_PUBLIC_APP_URL="http://localhost:3000"
```

---

## DATABASE SCHEMA

[Define your database tables. Example:]

```typescript
// Users table
export const users = pgTable('users', {
  id: uuid('id').primaryKey().defaultRandom(),
  email: varchar('email', { length: 255 }).unique().notNull(),
  name: varchar('name', { length: 255 }),
  image: text('image'),
  usageThisMonth: integer('usage_this_month').default(0).notNull(),
  usageLimit: integer('usage_limit').default(5).notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull(),
  updatedAt: timestamp('updated_at').defaultNow().notNull(),
});

// [Add more tables as needed]
// Define relations between tables
```

---

## AI PROMPT (if applicable)

[Define the system prompt for your AI integration. Example:]

```typescript
export async function generateContent(input: string) {
  const message = await ai.messages.create({
    model: 'model-name',
    max_tokens: 4096,
    messages: [{
      role: 'user',
      content: `You are a [ROLE_DESCRIPTION].

Given the input "${input}", generate [EXPECTED_OUTPUT].

RULES:
1. [Rule 1]
2. [Rule 2]
3. [Rule 3]

Return ONLY valid JSON:
{
  "field1": "string",
  "field2": "string",
  "items": [
    {
      "title": "string",
      "content": "string"
    }
  ]
}`
    }]
  });

  return JSON.parse(content.text);
}
```

---

## CORE COMPONENTS

[List and describe each component. Example:]

### MainInput.tsx
- Large centered input field
- Placeholder: "[Descriptive placeholder text]"
- Submit button with label
- Loading state during processing
- Validation: [min-max characters, required fields, etc.]

### ResultCard.tsx
- Expandable card (click header to toggle)
- Visual hierarchy with title + content sections
- Interactive elements (forms, buttons, etc.)
- Auth-gated actions (show login modal if not authenticated)

### LoadingAnimation.tsx
- Progress text: "[Processing message...]"
- Spinner or indeterminate progress bar
- Expected wait time: [X-Y seconds]

### Navbar.tsx
- Logo on the left
- Navigation links (conditional on auth state)
- Avatar/Login on the right

### ItemCard.tsx
- Card for listing items in dashboard
- Shows: title, metadata, date, status

---

## PAGES

### / (Home)
```
[Navbar]

        [PROJECT NAME]
   [Tagline/subtitle]

  [_____________________________]
        [Primary CTA Button]

  Suggestions: [Tag 1] · [Tag 2] · [Tag 3]
```

### /[feature]/[slug] (Detail Page)
```
[Navbar]

Back link

[TITLE]
by @user · [metadata]

[Content cards/sections]
[Interactive elements]
[Auth-gated features]
```

### /dashboard
```
[Navbar]

My [Items]
[Usage counter] [progress bar]

[+ New Item]

[Item Grid/List]
```

---

## API ROUTES

### POST /api/[feature]/generate
```
Input: { field: string }
Validate: [validation rules]
If authenticated: check usage limits
Process with AI or business logic
Generate unique slug/ID
Save to database
If authenticated: increment usage counter
Return: { slug, data }
```

### GET /api/[feature]/[id]
```
Fetch item by slug or ID
Include related data
If authenticated: include user-specific data
Track views (if not author)
```

### POST /api/[related-data]
```
Require auth
Input: { parentId, content }
Upsert related record
```

### PATCH /api/[feature]/[id]
```
Require auth + ownership
Input: { field: value }
Update record
```

---

## MAIN USER FLOW

1. Visitor lands on "/" → sees primary input
2. Enters data → clicks primary CTA
3. Waits for processing → redirected to detail page
4. Explores content, interacts
5. Tries authenticated action → login modal
6. Authenticates (OAuth)
7. Action completes, item linked to account
8. Accesses /dashboard → sees their items

---

## EXECUTION CHECKLIST

### 1. Initial Setup
```bash
npx create-next-app@latest [project-name] --typescript --tailwind --app --src-dir --import-alias "@/*"
cd [project-name]
npm install [list-core-dependencies]
npm install -D [list-dev-dependencies]
npx shadcn@latest init
npx shadcn@latest add [list-ui-components]
```

### 2. Create files in order:
1. `.env.local` with variables
2. Database config (e.g., `drizzle.config.ts`)
3. Database schema
4. Database connection
5. Push/migrate schema to database
6. Auth configuration
7. Auth API route
8. AI/business logic module (if applicable)
9. Core components
10. Home page
11. Primary API route
12. Detail page
13. Secondary API routes
14. Dashboard page

### 3. Test complete flow
### 4. Deploy

---

## NOTES

- Focus on working, not perfection
- No social features unless specified
- Payments/billing deferred unless specified
- Mobile responsive is important
- Auto-save with debounce where applicable (1s after typing stops)

Start with setup and follow the checklist. Flag any blockers immediately.
```

---

## How to Customize This Template

1. **Replace all `[PLACEHOLDER]` values** with your project specifics
2. **Adjust the tech stack** to match your preferences
3. **Define your database schema** with the actual tables you need
4. **List your components** with specific UI requirements
5. **Map your API routes** with actual endpoints and logic
6. **Describe the user flow** specific to your product

### Quick-Start Examples

**For a SaaS tool:**
```
[PROJECT_NAME] = "InvoiceBot"
[ONE_LINE_DESCRIPTION] = "AI-powered invoice generator for freelancers"
[CORE_USER_ACTION] = "describes a project and client details"
[CORE_SYSTEM_RESPONSE] = "generates a professional invoice PDF"
```

**For a content platform:**
```
[PROJECT_NAME] = "LearnPath"
[ONE_LINE_DESCRIPTION] = "AI-generated learning roadmaps for any topic"
[CORE_USER_ACTION] = "enters a topic they want to learn"
[CORE_SYSTEM_RESPONSE] = "creates a structured learning path with resources"
```

**For a data tool:**
```
[PROJECT_NAME] = "CSVInsight"
[ONE_LINE_DESCRIPTION] = "natural language queries on CSV data"
[CORE_USER_ACTION] = "uploads a CSV and asks questions in plain English"
[CORE_SYSTEM_RESPONSE] = "analyzes the data and returns charts + insights"
```
