---
name: stripe
description: "Help with Stripe payment integration in Next.js projects. Use when implementing checkout flows, subscriptions, webhooks, customer portal, or debugging payment issues. Covers Stripe SDK usage, webhook verification, subscription management, idempotency, and dunning."
allowed-tools: Read, Glob, Grep, Write, Edit, Bash, WebSearch
---

# Stripe Integration

You are a payments engineer who has processed billions in transactions.
You've seen every edge case - declined cards, webhook failures, subscription
nightmares, currency issues, refund fraud. You know that payments code must
be bulletproof because errors cost real money. You're paranoid about race
conditions, idempotency, and webhook verification.

## Quick Reference

### Installation
```bash
npm install stripe @stripe/stripe-js
```

### Environment Variables
```bash
# Server-side (secret)
STRIPE_SECRET_KEY="sk_live_..."
STRIPE_WEBHOOK_SECRET="whsec_..."

# Client-side (publishable)
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY="pk_live_..."

# App URL for callbacks
NEXT_PUBLIC_SITE_URL="http://localhost:3003"
```

### SDK Initialization

**Server-side:**
```typescript
// lib/stripe.ts
import Stripe from "stripe";

export const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: "2025-01-27.acacia",
  typescript: true,
});
```

**Client-side:**
```typescript
// lib/stripe-client.ts
import { loadStripe } from "@stripe/stripe-js";

export const stripePromise = loadStripe(
  process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY!
);
```

## Key Patterns

### Idempotency Key Everything

Use idempotency keys on ALL payment operations to prevent duplicate charges:

```typescript
const session = await stripe.checkout.sessions.create(
  { /* params */ },
  { idempotencyKey: `checkout_${org.userId}_${Date.now()}` }
);
```

### Webhook State Machine

Handle webhooks as **state transitions**, not triggers. The webhook is the source of truth for payment status, not the API response.

### Test Mode Throughout Development

Use Stripe test mode with real test cards. Never mix test/live keys.

## Common Tasks

### 1. Create Checkout Session

```typescript
// app/api/stripe/create-checkout/route.ts
import { NextResponse } from "next/server";
import { getOrgContextFromCookies } from "@/lib/auth/get-org-context";
import { createAdminClient } from "@/lib/supabase/server";
import { stripe } from "@/lib/stripe";

export async function POST(request: Request) {
  const org = await getOrgContextFromCookies();
  if (!org) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  const { priceId } = await request.json();
  const supabase = createAdminClient();

  // Get user email for pre-fill
  const { data: user } = await supabase
    .from("users")
    .select("email, stripe_id")
    .eq("id", org.userId)
    .single();

  const session = await stripe.checkout.sessions.create({
    mode: "subscription",
    payment_method_types: ["card"],
    line_items: [{ price: priceId, quantity: 1 }],
    success_url: `${process.env.NEXT_PUBLIC_SITE_URL}/settings?checkout=success`,
    cancel_url: `${process.env.NEXT_PUBLIC_SITE_URL}/checkout`,
    metadata: { userId: String(org.userId) },
    customer: user?.stripe_id || undefined,
    customer_email: user?.stripe_id ? undefined : user?.email,
  });

  return NextResponse.json({ url: session.url });
}
```

### 2. Create Customer Portal Session

```typescript
// app/api/stripe/portal/route.ts
export async function POST(request: Request) {
  const org = await getOrgContextFromCookies();
  if (!org) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  const supabase = createAdminClient();
  const { data: user } = await supabase
    .from("users")
    .select("stripe_id")
    .eq("id", org.userId)
    .single();

  if (!user?.stripe_id) {
    return NextResponse.json({ error: "No subscription" }, { status: 400 });
  }

  const session = await stripe.billingPortal.sessions.create({
    customer: user.stripe_id,
    return_url: `${process.env.NEXT_PUBLIC_SITE_URL}/settings`,
  });

  return NextResponse.json({ url: session.url });
}
```

### 3. Webhook Handler

```typescript
// app/api/stripe/webhook/route.ts
import { NextResponse } from "next/server";
import { stripe } from "@/lib/stripe";
import Stripe from "stripe";

export async function POST(request: Request) {
  const body = await request.text(); // RAW body - never parse before verify
  const signature = request.headers.get("stripe-signature")!;

  let event: Stripe.Event;

  try {
    event = stripe.webhooks.constructEvent(
      body,
      signature,
      process.env.STRIPE_WEBHOOK_SECRET!
    );
  } catch (err) {
    console.error("Webhook signature verification failed");
    return NextResponse.json({ error: "Invalid signature" }, { status: 400 });
  }

  switch (event.type) {
    case "checkout.session.completed": {
      const session = event.data.object as Stripe.Checkout.Session;
      await handleCheckoutComplete(session);
      break;
    }
    case "customer.subscription.updated": {
      const subscription = event.data.object as Stripe.Subscription;
      await handleSubscriptionUpdate(subscription);
      break;
    }
    case "customer.subscription.deleted": {
      const subscription = event.data.object as Stripe.Subscription;
      await handleSubscriptionCancelled(subscription);
      break;
    }
    case "invoice.payment_failed": {
      const invoice = event.data.object as Stripe.Invoice;
      await handlePaymentFailed(invoice);
      break;
    }
  }

  return NextResponse.json({ received: true });
}
```

### 4. Subscription Sync Pattern

```typescript
async function syncSubscription(
  userId: number,
  subscription: Stripe.Subscription
) {
  const supabase = createAdminClient();

  await supabase
    .from("subscriptions")
    .upsert({
      user_id: userId,
      stripe_subscription_id: subscription.id,
      plan_name: subscription.items.data[0].price.lookup_key || "pro",
      status: subscription.status, // "active", "canceled" (American spelling!)
      is_active: ["active", "trialing", "past_due"].includes(subscription.status),
      current_period_end: new Date(subscription.current_period_end * 1000).toISOString(),
    }, { onConflict: "user_id" });
}
```

## Sharp Edges

| Issue | Severity | What Happens |
|-------|----------|-------------|
| Not verifying webhook signatures | **critical** | Attackers can forge fake payment events |
| JSON middleware parsing body before webhook verify | **critical** | Signature check fails silently — use `request.text()` not `request.json()` |
| Not using idempotency keys | **high** | Duplicate charges on retries or network issues |
| Trusting API responses instead of webhooks | **critical** | Payment status drifts — always use webhook-first architecture |
| Not passing metadata through checkout session | **high** | Can't link payment to user after checkout completes |
| Local subscription state drifting from Stripe | **high** | Handle ALL subscription webhooks, not just `checkout.session.completed` |
| Not handling failed payments (dunning) | **high** | Revenue leaks — handle `invoice.payment_failed` and notify user |
| Mixing test/live keys between environments | **high** | Silent failures or real charges in dev |

## Anti-Patterns

- **Trust the API response** — Always verify state via webhooks, not checkout session return
- **Webhook without signature verification** — Never skip `constructEvent()`
- **Subscription status checks without refresh** — Don't cache subscription status client-side, always verify server-side
- **Using `"cancelled"` spelling** — Stripe uses American spelling: `"canceled"`

## Webhook Events

| Event | When to Handle |
|-------|----------------|
| `checkout.session.completed` | User completes checkout |
| `customer.subscription.created` | New subscription starts |
| `customer.subscription.updated` | Plan change, renewal |
| `customer.subscription.deleted` | Subscription cancelled |
| `invoice.payment_succeeded` | Successful payment |
| `invoice.payment_failed` | Failed payment attempt |
| `customer.updated` | Customer info changed |

## Subscription Status Values

Aligned with `src/lib/types.ts` — `SubscriptionStatus` enum:

| Status | `is_active` | Description |
|--------|-------------|-------------|
| `active` | `true` | Normal active subscription |
| `trialing` | `true` | In trial period |
| `past_due` | `true` | Payment failed, grace period |
| `canceling` | `true` | Scheduled cancellation at period end |
| `canceled` | `false` | Subscription ended (American spelling!) |
| `unpaid` | `false` | All retry attempts failed |
| `incomplete` | `false` | First payment pending |

## Database Schema (MGM-Web)

Key fields in `users` and `subscriptions` tables:

```sql
-- users table
stripe_id         TEXT     -- Stripe customer ID (cus_xxx)

-- subscriptions table
user_id           INTEGER  -- FK to users.id (numeric, not UUID)
stripe_subscription_id TEXT
plan_name         TEXT
status            TEXT     -- SubscriptionStatus enum
is_active         BOOLEAN
current_period_end TIMESTAMP
```

## Testing

### Test Card Numbers

| Card | Scenario |
|------|----------|
| `4242424242424242` | Successful payment |
| `4000000000000002` | Card declined |
| `4000002500003155` | Requires 3D Secure |
| `4000000000009995` | Insufficient funds |

### Stripe CLI for Local Webhooks

```bash
# Install Stripe CLI
brew install stripe/stripe-cli/stripe

# Login
stripe login

# Forward webhooks to local (port 3003!)
stripe listen --forward-to localhost:3003/api/stripe/webhook

# Trigger test events
stripe trigger checkout.session.completed
```

## Pricing Page Pattern

```typescript
// Server Component or API route
const prices = await stripe.prices.list({
  active: true,
  expand: ["data.product"],
});

// Display in component
{prices.data.map((price) => (
  <PriceCard
    key={price.id}
    name={(price.product as Stripe.Product).name}
    price={price.unit_amount! / 100}
    interval={price.recurring?.interval}
    priceId={price.id}
  />
))}
```

## Security Best Practices

1. **Never expose secret key** — `STRIPE_SECRET_KEY` only server-side
2. **Verify webhook signatures** — Always use `stripe.webhooks.constructEvent`
3. **Idempotency keys** — On every payment operation to prevent duplicate charges
4. **Raw body for webhooks** — Use `request.text()`, never parse JSON before verification
5. **Use metadata** — Store `userId` in checkout session metadata to link payment to user
6. **Webhook-first architecture** — Don't trust API responses for payment status

## Common Issues

| Issue | Solution |
|-------|----------|
| Webhook signature invalid | Use `request.text()` for raw body, not `request.json()` |
| Customer not found | Create customer before checkout or use `customer_email` |
| Subscription not syncing | Handle ALL subscription webhooks, not just checkout |
| Test cards failing | Ensure using test mode keys (`sk_test_`, `pk_test_`) |
| Portal not loading | Verify customer has active subscription in Stripe |
| Status mismatch | Use American `"canceled"` not British `"cancelled"` |
| Wrong port in CLI | Use `localhost:3003` not `localhost:3000` |

## Useful Commands

```bash
# List products
stripe products list

# List prices
stripe prices list

# Get subscription
stripe subscriptions retrieve sub_xxx

# Cancel subscription
stripe subscriptions cancel sub_xxx

# Check webhook events
stripe events list --limit 5
```

## Related Skills

Works well with: `nextjs-supabase-auth`, `supabase-postgres-best-practices`, `security-best-practices`
