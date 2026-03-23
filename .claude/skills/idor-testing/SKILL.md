---
name: IDOR Vulnerability Testing
description: This skill should be used when the user asks to "test for insecure direct object references," "find IDOR vulnerabilities," "exploit broken access control," "enumerate user IDs or object references," or "bypass authorization to access other users' data." Adapted for MGM-Web multi-tenant architecture.
metadata:
  author: zebbern (adapted for MGM-Web)
  version: "2.0"
---

# IDOR Vulnerability Testing

## Purpose

Systematic methodologies for identifying Insecure Direct Object Reference (IDOR) vulnerabilities. Adapted for MGM-Web's multi-tenant architecture where `group_owner` isolation is the primary security boundary.

## MGM-Web IDOR Risk Areas

### Critical: Multi-Tenant Group Isolation

MGM-Web uses `group_owner = org.organizationRootUserId` to isolate tenant data. If any API route forgets this filter, **all groups from all tenants are exposed**.

#### High-Risk Endpoints to Test

```
# Group data — MUST filter by group_owner
GET  /api/groups
GET  /api/groups/[id]
GET  /api/groups/[id]/hot-topics

# Analytics — MUST verify group belongs to org
GET  /api/analytics/overview
GET  /api/analytics/blocks/*

# Members — cross-org access risk
GET  /api/team/members
POST /api/team/invite

# Summaries — group data exposure
GET  /api/summaries

# Alerts — cross-org alert access
GET  /api/alerts
GET  /api/alerts/triggers
```

#### Correct Pattern (MGM-Web)

```typescript
// ✅ SECURE: Always filter by org context
export async function GET(req: Request) {
  const org = await getOrgContextFromCookies();
  if (!org) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  const supabase = await createClient();
  const { data } = await supabase
    .from("groups")
    .select("*")
    .eq("group_owner", org.organizationRootUserId); // CRITICAL filter

  return NextResponse.json({ data });
}
```

#### Vulnerable Pattern (What to look for)

```typescript
// ❌ VULNERABLE: No org filter — exposes ALL tenants' data
export async function GET(req: Request) {
  const { searchParams } = new URL(req.url);
  const groupId = searchParams.get("groupId");

  const supabase = await createClient();
  const { data } = await supabase
    .from("groups")
    .select("*")
    .eq("id", groupId); // Missing group_owner check!

  return NextResponse.json({ data });
}
```

### Critical: RBAC Level Bypass

MGM has 3 permission levels: Owner (1), Admin (2), Member (3).

```typescript
// Test: Can a Member access admin-only endpoints?
// Endpoint that should check canManageUsers
POST /api/team/invite
DELETE /api/groups

// ❌ VULNERABLE: Only checks auth, not permission level
if (!org) return 401;
// Missing: if (!org.canManageUsers) return 403;
```

### Medium: Group Detail Access

```
# Test: Can Org A access Org B's group details?
GET /api/groups/[id] — where [id] belongs to different org

# Secure check:
const { data: group } = await supabase
  .from("groups")
  .select("*")
  .eq("id", groupId)
  .eq("group_owner", org.organizationRootUserId) // Must have this
  .single();
```

### Medium: User ID Enumeration

MGM uses auto-incrementing numeric IDs for users (`users.id`). These are predictable:

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
GET /api/groups/123  →  GET /api/groups/124  (another org's group)
```

**Direct Reference to Static Files:**
```
/static/receipt/205.pdf  →  /static/receipt/200.pdf
```

### 2. Detection Techniques

#### URL Parameter Manipulation
```
# Step 1: Capture authenticated request (Org A)
GET /api/groups/100 HTTP/1.1
Cookie: sb-access-token=orgA_session

# Step 2: Change group ID to Org B's group
GET /api/groups/200 HTTP/1.1
Cookie: sb-access-token=orgA_session

# VULNERABLE if: Returns Org B's group data with Org A's session
```

#### Request Body Manipulation
```json
// Original (own group)
POST /api/groups/add
{"group_owner": 10, "invite_code": "abc123"}

// Modified (target another org)
{"group_owner": 20, "invite_code": "abc123"}
```

#### HTTP Method Switching
```
GET /api/team/members/5  → 403 Forbidden
PUT /api/team/members/5  → 200 OK (Vulnerable!)
DELETE /api/team/members/5  → 200 OK (Vulnerable!)
```

### 3. Common IDOR Locations

| Location | MGM-Web Examples |
|----------|------------------|
| URL path params | `/api/groups/[id]`, `/api/alerts/[id]` |
| Query params | `?groupId=123`, `?userId=456` |
| Request body | `{"group_owner": 10}`, `{"user_id": 5}` |
| Supabase filters | Missing `.eq("group_owner", org.organizationRootUserId)` |

### 4. Testing Checklist

| Test | Method | IDOR Indicator |
|------|--------|----------------|
| Increment group ID | Change `id=5` to `id=6` | Returns different org's group |
| Change group_owner | Modify body `group_owner` field | Assigns group to wrong org |
| Cross-org member access | Use member ID from different org | Returns cross-org data |
| Permission bypass | Member accessing admin endpoint | Action succeeds without check |
| Enumerate user IDs | Test IDs 1-100 | Find valid users from other orgs |

### 5. Response Analysis

| Status | Interpretation |
|--------|----------------|
| 200 OK | Potential IDOR — verify data ownership |
| 403 Forbidden | Access control working (check `org.canManageUsers`) |
| 404 Not Found | Could be secure (empty result) or missing resource |
| 401 Unauthorized | Auth check working |
| 500 Error | Possible input validation gap |

## Remediation (MGM-Web Patterns)

### Always Filter by Org Context

```typescript
// ✅ Every query MUST include group_owner filter
const { data } = await supabase
  .from("groups")
  .select("*")
  .eq("group_owner", org.organizationRootUserId);
```

### Check Permissions for Admin Actions

```typescript
// ✅ Check RBAC level before destructive actions
if (!org.canManageUsers) {
  return NextResponse.json({ error: "Forbidden" }, { status: 403 });
}
```

### Verify Resource Ownership Before Detail Access

```typescript
// ✅ Verify group belongs to org before returning details
const { data: group } = await supabase
  .from("groups")
  .select("*")
  .eq("id", groupId)
  .eq("group_owner", org.organizationRootUserId)
  .single();

if (!group) {
  return NextResponse.json({ error: "Not found" }, { status: 404 });
}
```

### Use Indirect References Where Possible

```typescript
// ✅ Instead of exposing numeric IDs in URLs
// Use org-scoped queries that don't need external IDs
const { data } = await supabase
  .from("subscriptions")
  .select("*")
  .eq("user_id", org.userId) // Always use session user
  .single();
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| All requests return 403 | Try method switching (GET→POST→PUT), parameter pollution |
| App uses UUIDs | Check response bodies for leaked UUIDs, JS files for hardcoded values |
| Rate limited | Add delays, target specific high-value IDs, test during off-peak |
| Can't verify impact | Create unique data in victim account, compare response lengths |
| Supabase RLS blocks everything | Test with `createAdminClient()` to see if RLS is the protection vs app code |

## Related Skills

- `security-threat-model` — Map trust boundaries and attack paths
- `security-best-practices` — Next.js/React security review
- `api-security-best-practices` — API auth, validation, rate limiting
- `xss-html-injection` — Client-side injection testing
