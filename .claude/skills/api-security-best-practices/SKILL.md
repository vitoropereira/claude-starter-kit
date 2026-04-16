---
name: api-security-best-practices
description: "Secure API design patterns for Next.js App Router with Supabase. Authentication, authorization, input validation, rate limiting, and OWASP API Top 10. Adapted for MGM-Web multi-tenant architecture."
---

# API Security Best Practices

Guide for building secure APIs in Next.js App Router with Supabase Auth. Covers authentication, authorization, input validation, and protection against OWASP API Top 10.

## When to Use

- Designing new API endpoints in `src/app/api/`
- Reviewing existing API routes for security gaps
- Implementing RBAC checks for multi-tenant isolation
- Adding input validation with Zod
- Conducting API security reviews

---

## 1. Authentication & Authorization (MGM-Web Pattern)

### Standard Protected Route

```typescript
// src/app/api/example/route.ts
import { NextResponse } from "next/server";
import { getOrgContextFromCookies } from "@/lib/auth/get-org-context";
import { createClient } from "@/lib/supabase/server";

export async function GET(req: Request) {
  // Step 1: Authenticate
  const org = await getOrgContextFromCookies();
  if (!org) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  // Step 2: Authorize (for admin-only actions)
  if (!org.canManageUsers) {
    return NextResponse.json({ error: "Forbidden" }, { status: 403 });
  }

  // Step 3: Query with tenant isolation
  const supabase = await createClient();
  const { data } = await supabase
    .from("groups")
    .select("*")
    .eq("group_owner", org.organizationRootUserId); // CRITICAL

  return NextResponse.json({ data });
}
```

### Auth Decision Tree

| Scenario | Helper |
|----------|--------|
| Dashboard API routes (cookie auth) | `getOrgContextFromCookies()` |
| Routes with Bearer token | `getOrgContext(req)` |
| User without org context (invite flow) | `supabase.auth.getUser()` |
| Server-side admin operations | `createAdminClient()` |

### RBAC Levels

```typescript
interface OrgContext {
  userId: number;                    // User's internal ID
  organizationRootUserId: number;    // Org owner — use for group_owner queries
  levelOrder: number;                // 1=Owner, 2=Admin, 3=Member
  canManageUsers: boolean;           // Owner + Admin
  canCreateGroups: boolean;          // Owner + Admin
  canViewAllGroups: boolean;         // Owner + Admin
}
```

### Anti-Patterns

```typescript
// ❌ BAD: No auth check at all
export async function GET(req: Request) {
  const supabase = await createClient();
  const { data } = await supabase.from("groups").select("*");
  return NextResponse.json({ data }); // Exposes ALL groups!
}

// ❌ BAD: Auth but no tenant isolation
export async function GET(req: Request) {
  const org = await getOrgContextFromCookies();
  if (!org) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });

  const { data } = await supabase.from("groups").select("*");
  // Missing .eq("group_owner", org.organizationRootUserId)!
  return NextResponse.json({ data });
}

// ❌ BAD: Auth but no permission check for admin action
export async function DELETE(req: Request) {
  const org = await getOrgContextFromCookies();
  if (!org) return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  // Missing: if (!org.canManageUsers) return 403
  await supabase.from("groups").delete().eq("id", groupId);
}
```

---

## 2. Input Validation with Zod

### Route with Validation

```typescript
import { z } from "zod";

const AddGroupSchema = z.object({
  inviteCode: z.string()
    .min(1, "Invite code required")
    .max(100, "Invite code too long")
    .regex(/^[a-zA-Z0-9]+$/, "Invalid characters"),
});

export async function POST(req: Request) {
  const org = await getOrgContextFromCookies();
  if (!org) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  // Validate input
  const body = await req.json();
  const parsed = AddGroupSchema.safeParse(body);
  if (!parsed.success) {
    return NextResponse.json(
      { error: "Invalid input", details: parsed.error.flatten() },
      { status: 400 }
    );
  }

  // Use validated data
  const { inviteCode } = parsed.data;
  // ... proceed with safe data
}
```

### Validation Rules

| Data Type | Zod Pattern |
|-----------|-------------|
| IDs (numeric) | `z.number().int().positive()` |
| IDs (string from params) | `z.string().regex(/^\d+$/)` |
| Email | `z.string().email()` |
| Pagination cursor | `z.string().optional()` |
| Search query | `z.string().max(200).optional()` |
| Enum values | `z.enum(["active", "canceled", "trialing"])` |

### Don't Trust Client Input

```typescript
// ❌ BAD: Using raw request body
const { groupId, userId } = await req.json();
await supabase.from("groups").update({ name }).eq("id", groupId);

// ✅ GOOD: Validate + use org context for ownership
const parsed = UpdateGroupSchema.safeParse(await req.json());
if (!parsed.success) return NextResponse.json({ error: "Invalid" }, { status: 400 });

await supabase
  .from("groups")
  .update({ name: parsed.data.name })
  .eq("id", parsed.data.groupId)
  .eq("group_owner", org.organizationRootUserId); // Tenant isolation
```

---

## 3. Error Handling (No Data Leaks)

```typescript
// ❌ BAD: Exposes database structure
catch (error) {
  return NextResponse.json({ error: error.message }, { status: 500 });
  // "duplicate key value violates unique constraint "users_email_key""
}

// ✅ GOOD: Generic error + server-side logging
catch (error) {
  console.error("[API] Group creation error:", error);
  return NextResponse.json(
    { error: "Failed to create group" },
    { status: 500 }
  );
}
```

### Error Response Standards

| Status | When | Response |
|--------|------|----------|
| 400 | Invalid input | `{ error: "Invalid input", details: zodErrors }` |
| 401 | Not authenticated | `{ error: "Unauthorized" }` |
| 403 | Not authorized (wrong role) | `{ error: "Forbidden" }` |
| 404 | Resource not found (or not owned) | `{ error: "Not found" }` |
| 500 | Server error | `{ error: "Internal server error" }` (never expose details) |

---

## 4. Rate Limiting

### Next.js Middleware Approach

```typescript
// src/middleware.ts
import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";

const rateLimit = new Map<string, { count: number; resetAt: number }>();

function isRateLimited(ip: string, limit: number, windowMs: number): boolean {
  const now = Date.now();
  const entry = rateLimit.get(ip);

  if (!entry || now > entry.resetAt) {
    rateLimit.set(ip, { count: 1, resetAt: now + windowMs });
    return false;
  }

  entry.count++;
  return entry.count > limit;
}

export function middleware(request: NextRequest) {
  if (request.nextUrl.pathname.startsWith("/api/auth")) {
    const ip = request.headers.get("x-forwarded-for") || "unknown";
    if (isRateLimited(ip, 10, 15 * 60 * 1000)) { // 10 req / 15 min
      return NextResponse.json(
        { error: "Too many requests" },
        { status: 429, headers: { "Retry-After": "900" } }
      );
    }
  }
}
```

### Vercel-Level Protection

For production, use Vercel's built-in DDoS protection and configure:
- Rate limiting in `vercel.json`
- Edge middleware for IP-based throttling
- Supabase has built-in rate limiting for auth endpoints

---

## 5. Security Headers

### Next.js Config

```typescript
// next.config.ts
const securityHeaders = [
  { key: "X-Content-Type-Options", value: "nosniff" },
  { key: "X-Frame-Options", value: "DENY" },
  { key: "X-XSS-Protection", value: "1; mode=block" },
  { key: "Referrer-Policy", value: "strict-origin-when-cross-origin" },
  { key: "Permissions-Policy", value: "camera=(), microphone=(), geolocation=()" },
];

module.exports = {
  async headers() {
    return [{ source: "/(.*)", headers: securityHeaders }];
  },
};
```

---

## OWASP API Security Top 10

| # | Vulnerability | MGM-Web Risk | Mitigation |
|---|--------------|-------------|------------|
| 1 | **Broken Object Level Authorization** | Missing `group_owner` filter | Always filter by `org.organizationRootUserId` |
| 2 | **Broken Authentication** | Supabase session bypass | Use `getOrgContextFromCookies()` consistently |
| 3 | **Broken Object Property Level Authorization** | Returning sensitive fields | Use `.select()` to pick only needed columns |
| 4 | **Unrestricted Resource Consumption** | Large group lists, analytics queries | Pagination with `nextCursor`, limit params |
| 5 | **Broken Function Level Authorization** | Member accessing admin functions | Check `org.canManageUsers` / `org.canCreateGroups` |
| 6 | **Unrestricted Access to Sensitive Business Flows** | Group add abuse | Rate limit `/api/groups/add` |
| 7 | **SSRF** | AI agent fetching external URLs | Validate URLs in AI pipeline |
| 8 | **Security Misconfiguration** | Missing CORS, headers | Security headers in `next.config.ts` |
| 9 | **Improper Inventory Management** | Undocumented API routes | Keep route structure documented in CLAUDE.md |
| 10 | **Unsafe Consumption of APIs** | MGM Backend API | Validate responses from `mgmApi` calls |

---

## Security Checklist for New API Routes

### Authentication & Authorization
- [ ] Uses `getOrgContextFromCookies()` or appropriate auth helper
- [ ] Returns 401 when no org context
- [ ] Checks permission level for admin actions (`canManageUsers`, `canCreateGroups`)
- [ ] Filters data by `org.organizationRootUserId` (tenant isolation)

### Input Validation
- [ ] Request body validated with Zod schema
- [ ] URL params validated (numeric IDs, enums)
- [ ] Query params validated (search, pagination, filters)
- [ ] No raw user input in database queries

### Error Handling
- [ ] Generic error messages to client (no stack traces)
- [ ] Detailed error logged server-side
- [ ] Proper HTTP status codes (400/401/403/404/500)

### Data Protection
- [ ] Only necessary fields in `.select()` (no password hashes, internal IDs)
- [ ] No `supabase_auth_id` or `auth_id` exposed to client
- [ ] Pagination implemented for list endpoints

---

## Related Skills

- `idor-testing` — IDOR vulnerability testing with MGM-specific examples
- `security-best-practices` — Next.js + React security spec
- `security-threat-model` — Repository-grounded threat modeling
- `broken-authentication` — Auth bypass testing
- `top-web-vulnerabilities` — OWASP-aligned vulnerability reference
