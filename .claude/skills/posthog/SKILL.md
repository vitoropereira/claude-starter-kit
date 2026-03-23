---
name: posthog
description: Implement PostHog analytics, feature flags, and session replay for Next.js apps. Use this skill for event tracking, user identification, A/B testing, experiments, and session recording setup. Also handles analytics reporting (funnel analysis, retention, SEO) with Google Search Console integration.
allowed-tools: Read, Glob, Grep, Write, Edit, WebSearch, Bash
---

# PostHog no MGM - Guia Operacional

## Arquitetura Atual no MGM

O PostHog está totalmente configurado no projeto. Aqui está onde cada coisa vive:

| Componente | Arquivo | Descrição |
|------------|---------|-----------|
| Provider Client | `src/providers/posthog-provider.tsx` | Inicialização, identificação de usuário, error tracking |
| Server Client | `src/lib/posthog-server.ts` | `captureServerEvent()`, `identifyServerUser()` |
| Reverse Proxy | `next.config.mjs` | Rewrites `/ingest` → PostHog (bypass ad blockers) |
| Section Tracking | `src/hooks/useTrackSection.ts` | Hook para tracking de seções |
| PostHog API | `src/lib/posthog-api.ts` | Queries HogQL e extração de dados |

### Variáveis de Ambiente

```bash
NEXT_PUBLIC_POSTHOG_KEY=phc_xxx    # Project API Key
NEXT_PUBLIC_POSTHOG_HOST=https://us.i.posthog.com
```

---

## Quando Usar Client vs Server

```
Onde trackear?
├── Ação do usuário no browser → Client (posthog-js)
│   Exemplos: clicks, navegação, interações UI
│
├── API route / webhook → Server (posthog-node)
│   Exemplos: signup completo, pagamento, erros críticos
│
├── Precisa 100% precisão → Server (sem ad blockers)
│   Exemplos: funnel de conversão, billing events
│
└── Feedback visual em tempo real → Client (posthog-js)
```

---

## Taxonomia de Eventos do MGM

### Padrão de Nomenclatura

Use `category:object_action` em **snake_case**:

```typescript
// ✅ Correto
"auth:signup_start"
"billing:checkout_complete"
"group:add_success"
"ai:chat_message_send"

// ❌ Errado
"User Signed Up"        // Sem espaços, sem caps
"signupComplete"        // Use snake_case
"group_added"           // Falta categoria
```

### Eventos Implementados no MGM

#### Autenticação (auth:)
```typescript
"auth:signup_start"      // Client - início do signup
"auth:signup_complete"   // Server - signup finalizado
"auth:login_success"     // Client - login bem sucedido
```

#### Billing (billing:)
```typescript
"billing:checkout_start"    // Client - início checkout
"billing:checkout_complete" // Server - pagamento confirmado (webhook)
"billing:payment_fail"      // Server - falha no pagamento
```

#### Grupos (group:)
```typescript
"group:add_start"       // Client - abriu modal de adicionar
"group:add_success"     // Server - grupo adicionado
"group:add_error"       // Server - erro ao adicionar
"group_deleted"         // Client - grupo deletado
```

#### Dashboard/Seções
```typescript
"section_viewed"        // Hook useTrackSection
"feature_used"          // Hook useTrackSection
"landing:page_view"     // Landing page
```

#### Onboarding
```typescript
"onboarding:start"              // Início do onboarding
"activation:first_insight_view" // Primeira visualização de insight
"tutorial_started"              // Tutorial iniciado
"tutorial_completed"            // Tutorial completado
```

### Propriedades Padrão

| Padrão | Exemplo | Quando Usar |
|--------|---------|-------------|
| `_id` | `user_id`, `group_id` | Identificadores |
| `_count` | `members_count` | Quantidades |
| `_at` | `created_at` | Timestamps |
| `is_` | `is_first_time` | Booleanos |
| `has_` | `has_subscription` | Booleanos de posse |

---

## Implementação Prática

### 1. Tracking no Client (Componentes)

```typescript
'use client'
import posthog from 'posthog-js'

// Evento simples
posthog.capture("group:add_start", {
  source: "dashboard",
  group_count: 5,
})

// Com o hook useTrackSection
import { useTrackSection } from "@/hooks"

function AnalyticsPage() {
  const { trackEvent, trackFeature } = useTrackSection("analytics")

  const handleExport = () => {
    trackFeature("export_csv", { rows: 100 })
  }
}
```

### 2. Tracking no Server (API Routes)

```typescript
import { captureServerEvent } from "@/lib/posthog-server"

// Em qualquer API route
await captureServerEvent(String(userId), "billing:checkout_complete", {
  plan_name: "pro",
  amount: 79,
  currency: "BRL",
})
```

### 3. Identificação de Usuário

**Já acontece automaticamente** no `PostHogIdentifier` dentro do provider:

```typescript
// src/providers/posthog-provider.tsx
posthog.identify(String(profile.id), {
  email: profile.email,
  name: profile.name,
  supabase_auth_id: user.id,
})
```

### 4. Error Tracking

**Já configurado automaticamente** para:
- `window.onerror` - erros não capturados
- `unhandledrejection` - promises rejeitadas

Para erros manuais:
```typescript
posthog.captureException(error, {
  context: "custom_context",
  additional_data: "value",
})
```

---

## Feature Flags & Experimentos

### Verificar Flag no Client

```typescript
'use client'
import { useFeatureFlagEnabled, useFeatureFlagPayload } from 'posthog-js/react'

function MyComponent() {
  // Boolean flag
  const showNewFeature = useFeatureFlagEnabled('new-feature')

  // Multivariate / payload
  const variant = useFeatureFlagPayload('pricing-experiment')

  if (showNewFeature === undefined) {
    return <Skeleton /> // Loading state
  }

  return showNewFeature ? <NewFeature /> : <OldFeature />
}
```

### Verificar Flag no Server

```typescript
import { PostHog } from 'posthog-node'

const posthog = new PostHog(process.env.NEXT_PUBLIC_POSTHOG_KEY!, {
  host: process.env.NEXT_PUBLIC_POSTHOG_HOST,
})

const isEnabled = await posthog.isFeatureEnabled('feature-key', distinctId)
await posthog.shutdown()
```

---

## Session Replay

### Configuração Atual

```typescript
session_recording: {
  maskAllInputs: false,
  maskInputOptions: { password: true },
  maskTextSelector: ".ph-no-capture",
}
```

### Mascarar Elementos Sensíveis

```tsx
// Elemento não será gravado
<div className="ph-no-capture">
  Dados sensíveis aqui
</div>
```

---

## Queries HogQL (Extração de Dados)

Para extrair dados do PostHog via API:

```typescript
// POST /api/projects/:project_id/query
const response = await fetch(`${POSTHOG_HOST}/api/projects/${PROJECT_ID}/query`, {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${PERSONAL_API_KEY}`,
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    query: {
      kind: 'HogQLQuery',
      query: `
        SELECT
          event,
          count() as count
        FROM events
        WHERE timestamp > now() - INTERVAL 7 DAY
        GROUP BY event
        ORDER BY count DESC
        LIMIT 10
      `
    }
  })
})
```

Ver `src/lib/posthog-api.ts` para implementação existente.

---

## Troubleshooting

| Problema | Solução |
|----------|---------|
| Eventos não aparecem | Verificar se reverse proxy está funcionando (`/ingest`) |
| Ad blockers bloqueando | Usar reverse proxy (já configurado) |
| User não identificado | Verificar se `identify()` é chamado antes de eventos |
| Feature flag undefined | Estado de loading - mostrar skeleton |
| Erros não capturados | Verificar se provider está no layout root |
| Server events perdidos | Usar `await captureServerEvent()` com await |

---

## Referências Oficiais

Quando precisar de algo não coberto aqui, consulte:

| Tópico | Link |
|--------|------|
| **Next.js Setup** | https://posthog.com/docs/libraries/next-js |
| **Event Tracking** | https://posthog.com/docs/getting-started/send-events |
| **Feature Flags** | https://posthog.com/docs/feature-flags |
| **A/B Testing** | https://posthog.com/tutorials/nextjs-ab-tests |
| **Session Replay** | https://posthog.com/docs/session-replay |
| **Error Tracking** | https://posthog.com/docs/error-tracking |
| **HogQL/SQL** | https://posthog.com/docs/sql |
| **Group Analytics** | https://posthog.com/docs/product-analytics/group-analytics |
| **Privacy Controls** | https://posthog.com/docs/session-replay/privacy |
| **Query API** | https://posthog.com/docs/api/query |

---

## Checklist para Novas Features

Ao implementar tracking para uma nova feature:

- [ ] Definir evento com padrão `category:object_action`
- [ ] Decidir: client (UI) ou server (crítico)?
- [ ] Adicionar propriedades relevantes (IDs, counts, contexto)
- [ ] Se crítico para funnel → usar `captureServerEvent()`
- [ ] Testar com PostHog debug mode (`NODE_ENV=development`)
- [ ] Verificar no painel PostHog que eventos chegaram
