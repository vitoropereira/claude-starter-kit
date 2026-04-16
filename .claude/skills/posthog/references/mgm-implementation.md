# Implementação PostHog no MGM

## Arquivos Principais

### 1. Provider Client (`src/providers/posthog-provider.tsx`)

**O que faz:**
- Inicializa PostHog no client-side
- Identifica usuários automaticamente via `PostHogIdentifier`
- Configura error tracking global (`window.onerror`, `unhandledrejection`)
- Configura session replay com masking de senhas

**Configuração atual:**
```typescript
posthog.init(process.env.NEXT_PUBLIC_POSTHOG_KEY, {
  api_host: "/ingest",                    // Reverse proxy
  capture_pageview: "history_change",     // Auto-capture para App Router
  capture_pageleave: true,
  persistence: "localStorage",
  autocapture: true,
  session_recording: {
    maskAllInputs: false,
    maskInputOptions: { password: true },
    maskTextSelector: ".ph-no-capture",
  },
})
```

### 2. Server Client (`src/lib/posthog-server.ts`)

**Funções exportadas:**
- `captureServerEvent(distinctId, event, properties)` - Captura evento server-side
- `identifyServerUser(distinctId, properties)` - Identifica usuário server-side
- `shutdownPostHog()` - Encerra cliente (para cleanup)

**Quando usar:**
- API routes que precisam de 100% precisão (billing, signup)
- Webhooks (Stripe, etc.)
- Eventos críticos para funnels de conversão

### 3. Reverse Proxy (`next.config.mjs`)

```javascript
async rewrites() {
  return [
    { source: "/ingest/static/:path*", destination: "https://us-assets.i.posthog.com/static/:path*" },
    { source: "/ingest/:path*", destination: "https://us.i.posthog.com/:path*" },
    { source: "/ingest/decide", destination: "https://us.i.posthog.com/decide" },
  ]
}
```

**Por que existe:** Ad blockers bloqueiam requisições diretas para `posthog.com`. O reverse proxy roteia via nosso domínio.

### 4. Hook useTrackSection (`src/hooks/useTrackSection.ts`)

**O que faz:**
- Tracking automático de visualização de seções
- Helper `trackEvent()` para eventos customizados
- Helper `trackFeature()` para uso de features

**Seções disponíveis:**
```typescript
type SectionId =
  | "dashboard" | "analytics" | "members" | "alerts"
  | "settings" | "summaries" | "integrations" | "help"
  | "group-detail" | "roadmap"
```

### 5. PostHog API (`src/lib/posthog-api.ts`)

**O que faz:**
- Queries HogQL para extração de dados
- Usado para gerar relatórios e insights

---

## Fluxo de Dados

```
┌─────────────────┐      ┌─────────────────┐
│  Browser/Client │      │   Server/API    │
│   (posthog-js)  │      │  (posthog-node) │
└────────┬────────┘      └────────┬────────┘
         │                        │
         │ /ingest (proxy)        │ direct
         │                        │
         ▼                        ▼
┌─────────────────────────────────────────────┐
│           PostHog Cloud (us.i.posthog.com)  │
└─────────────────────────────────────────────┘
```

---

## Identificação de Usuário

### Como funciona no MGM

O `PostHogIdentifier` é montado no provider e observa o estado de auth:

```typescript
function PostHogIdentifier() {
  const { profile, user } = useAuth()

  useEffect(() => {
    if (profile && user) {
      posthog.identify(String(profile.id), {
        email: profile.email,
        name: profile.name,
        supabase_auth_id: user.id,
      })
    } else {
      posthog.reset()  // Logout
    }
  }, [profile, user])
}
```

### Distinct ID

- **Client:** `profile.id` (número convertido para string)
- **Server:** Mesmo `profile.id` passado para `captureServerEvent()`

**Importante:** Manter consistência entre client e server para que eventos sejam associados ao mesmo usuário.

---

## Error Tracking

### Configuração Atual

O provider configura dois handlers globais:

1. **`window.onerror`** - Erros síncronos não capturados
2. **`window.onunhandledrejection`** - Promises rejeitadas

Ambos usam `posthog.captureException()` com metadata adicional.

### Error Boundaries Next.js

Arquivos existentes:
- `src/app/error.tsx` - Error boundary para rotas
- `src/app/global-error.tsx` - Error boundary global

---

## Eventos Atuais por Arquivo

| Arquivo | Eventos |
|---------|---------|
| `src/app/auth/signup/page.tsx` | `auth:signup_start` |
| `src/app/api/auth/signup/route.ts` | `auth:signup_complete` |
| `src/app/auth/checkout/page.tsx` | `billing:checkout_start` |
| `src/app/api/stripe/webhook/route.ts` | `billing:checkout_complete`, `billing:payment_fail` |
| `src/app/page.tsx` | `landing:page_view` |
| `src/app/dashboard/section-home.tsx` | `onboarding:start` |
| `src/app/dashboard/group/[id]/page.tsx` | `activation:first_insight_view` |
| `src/hooks/useGroups.ts` | `group_deleted` |
| `src/hooks/useTutorialStatus.ts` | `tutorial_*` |
| `src/lib/services/group-add-service.ts` | `group:add_success`, `group:add_error` |
