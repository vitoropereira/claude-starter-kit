---
name: IDOR Vulnerability Testing
description: This skill should be used when the user asks to "test for insecure direct object references," "find IDOR vulnerabilities," "exploit broken access control," "enumerate user IDs or object references," or "bypass authorization to access other users' data." Generic methodology for multi-tenant architectures.
metadata:
  author: zebbern (adapted for generic use)
  version: "2.0"
---

# IDOR Vulnerability Testing

## Purpose

Systematic methodologies for identifying Insecure Direct Object Reference (IDOR) vulnerabilities. Designed for multi-tenant architectures where tenant isolation is the primary security boundary.

## Multi-Tenant IDOR Risk Areas

### Critical: Tenant Data Isolation

Multi-tenant applications use a tenant identifier (e.g., `tenant_id`, `org_id`, `owner_id`) to isolate data. If any API route forgets this filter, **all data from all tenants is exposed**.

#### High-Risk Endpoints to Test

```
# Tenant-scoped data -- MUST filter by tenant identifier
GET  /api/resources
GET  /api/resources/[id]
GET  /api/resources/[id]/details

# Analytics -- MUST verify resource belongs to tenant
GET  /api/analytics/overview
GET  /api/analytics/reports/*

# Team members -- cross-tenant access risk
GET  /api/team/members
POST /api/team/invite

# Data exports -- tenant data exposure
GET  /api/exports
GET  /api/reports
```

#### Correct Pattern

```typescript
// SECURE: Always filter by tenant context
export async function GET(req: Request) {
  const tenant = await getTenantFromSession();
  if (!tenant) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  const { data } = await db
    .from("resources")
    .select("*")
    .eq("tenant_id", tenant.id); // CRITICAL filter

  return NextResponse.json({ data });
}
```

#### Vulnerable Pattern (What to look for)

```typescript
// VULNERABLE: No tenant filter -- exposes ALL tenants' data
export async function GET(req: Request) {
  const { searchParams } = new URL(req.url);
  const resourceId = searchParams.get("resourceId");

  const { data } = await db
    .from("resources")
    .select("*")
    .eq("id", resourceId); // Missing tenant_id check!

  return NextResponse.json({ data });
}
```

### Critical: RBAC Level Bypass

Many applications have multiple permission levels (e.g., Owner, Admin, Member).

```typescript
// Test: Can a Member access admin-only endpoints?
// Endpoint that should check permissions
POST /api/team/invite
DELETE /api/resources

// VULNERABLE: Only checks auth, not permission level
if (!tenant) return 401;
// Missing: if (!tenant.canManageUsers) return 403;
```

### Medium: Resource Detail Access

```
# Test: Can Tenant A access Tenant B's resource details?
GET /api/resources/[id] -- where [id] belongs to different tenant

# Secure check:
const { data: resource } = await db
  .from("resources")
  .select("*")
  .eq("id", resourceId)
  .eq("tenant_id", tenant.id) // Must have this
  .single();
```

### Medium: User ID Enumeration

Applications using auto-incrementing numeric IDs for users have predictable IDs:

```
# Sequential IDs are guessable
/api/team/members?userId=1
/api/team/members?userId=2
/api/team/members?userId=3
```

## General IDOR Testing Methodology

### 1. IDOR Types

**Direct Reference to Database Objects:**
```
GET /api/resources/123  ->  GET /api/resources/124  (another tenant's resource)
```

**Direct Reference to Static Files:**
```
/static/receipt/205.pdf  ->  /static/receipt/200.pdf
```

### 2. Detection Techniques

#### URL Parameter Manipulation
```
# Step 1: Capture authenticated request (Tenant A)
GET /api/resources/100 HTTP/1.1
Cookie: session=tenantA_session

# Step 2: Change resource ID to Tenant B's resource
GET /api/resources/200 HTTP/1.1
Cookie: session=tenantA_session

# VULNERABLE if: Returns Tenant B's data with Tenant A's session
```

#### Request Body Manipulation
```json
// Original (own resource)
POST /api/resources/add
{"tenant_id": 10, "invite_code": "abc123"}

// Modified (target another tenant)
{"tenant_id": 20, "invite_code": "abc123"}
```

#### HTTP Method Switching
```
GET /api/team/members/5  -> 403 Forbidden
PUT /api/team/members/5  -> 200 OK (Vulnerable!)
DELETE /api/team/members/5  -> 200 OK (Vulnerable!)
```

### 3. Common IDOR Locations

| Location | Examples |
|----------|----------|
| URL path params | `/api/resources/[id]`, `/api/alerts/[id]` |
| Query params | `?resourceId=123`, `?userId=456` |
| Request body | `{"tenant_id": 10}`, `{"user_id": 5}` |
| Database filters | Missing `.eq("tenant_id", tenant.id)` |

### 4. Testing Checklist

| Test | Method | IDOR Indicator |
|------|--------|----------------|
| Increment resource ID | Change `id=5` to `id=6` | Returns different tenant's resource |
| Change tenant_id | Modify body `tenant_id` field | Assigns resource to wrong tenant |
| Cross-tenant member access | Use member ID from different tenant | Returns cross-tenant data |
| Permission bypass | Member accessing admin endpoint | Action succeeds without check |
| Enumerate user IDs | Test IDs 1-100 | Find valid users from other tenants |

### 5. Response Analysis

| Status | Interpretation |
|--------|----------------|
| 200 OK | Potential IDOR -- verify data ownership |
| 403 Forbidden | Access control working |
| 404 Not Found | Could be secure (empty result) or missing resource |
| 401 Unauthorized | Auth check working |
| 500 Error | Possible input validation gap |

## Remediation Patterns

### Always Filter by Tenant Context

```typescript
// Every query MUST include tenant filter
const { data } = await db
  .from("resources")
  .select("*")
  .eq("tenant_id", tenant.id);
```

### Check Permissions for Admin Actions

```typescript
// Check RBAC level before destructive actions
if (!tenant.canManageUsers) {
  return NextResponse.json({ error: "Forbidden" }, { status: 403 });
}
```

### Verify Resource Ownership Before Detail Access

```typescript
// Verify resource belongs to tenant before returning details
const { data: resource } = await db
  .from("resources")
  .select("*")
  .eq("id", resourceId)
  .eq("tenant_id", tenant.id)
  .single();

if (!resource) {
  return NextResponse.json({ error: "Not found" }, { status: 404 });
}
```

### Use Indirect References Where Possible

```typescript
// Instead of exposing numeric IDs in URLs
// Use tenant-scoped queries that don't need external IDs
const { data } = await db
  .from("subscriptions")
  .select("*")
  .eq("user_id", tenant.userId) // Always use session user
  .single();
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| All requests return 403 | Try method switching (GET->POST->PUT), parameter pollution |
| App uses UUIDs | Check response bodies for leaked UUIDs, JS files for hardcoded values |
| Rate limited | Add delays, target specific high-value IDs, test during off-peak |
| Can't verify impact | Create unique data in victim account, compare response lengths |
| RLS blocks everything | Test with admin client to see if RLS is the protection vs app code |

## Related Skills

- `security-best-practices` -- Language/framework security review
- `top-web-vulnerabilities` -- Comprehensive vulnerability reference
- `xss-html-injection` -- Client-side injection testing
