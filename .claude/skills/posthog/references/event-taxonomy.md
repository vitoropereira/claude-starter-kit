# Taxonomia de Eventos - MGM

## Padrão de Nomenclatura

### Formato: `category:object_action`

```
category:object_action
   │        │     │
   │        │     └── verbo (start, complete, view, create, delete)
   │        └── substantivo (signup, checkout, group, insight)
   └── contexto (auth, billing, group, ai, dashboard)
```

### Regras

| Regra | Correto | Errado |
|-------|---------|--------|
| Lowercase | `auth:signup_start` | `Auth:Signup_Start` |
| Snake case | `group_add` | `groupAdd` |
| Presente | `create`, `view` | `created`, `viewed` |
| Categoria obrigatória | `group:add_start` | `group_added` |

---

## Categorias do MGM

### `auth:` - Autenticação

```typescript
"auth:signup_start"      // Usuário iniciou signup (client)
"auth:signup_complete"   // Signup finalizado com sucesso (server)
"auth:login_success"     // Login bem sucedido (client)
"auth:logout"            // Usuário fez logout (client)
"auth:password_reset"    // Solicitou reset de senha (client)
```

**Propriedades comuns:**
```typescript
{
  method: "email" | "google" | "magic_link",
  source: "landing" | "invite" | "direct",
}
```

### `billing:` - Pagamentos e Assinaturas

```typescript
"billing:checkout_start"     // Iniciou checkout (client)
"billing:checkout_complete"  // Pagamento confirmado (server - webhook)
"billing:payment_fail"       // Falha no pagamento (server - webhook)
"billing:plan_upgrade"       // Upgrade de plano (server)
"billing:plan_downgrade"     // Downgrade de plano (server)
"billing:subscription_cancel" // Cancelou assinatura (server)
```

**Propriedades comuns:**
```typescript
{
  plan_name: "starter" | "pro" | "enterprise",
  plan_price: number,
  currency: "BRL",
  stripe_session_id?: string,
  members_limit?: number,
}
```

### `group:` - Grupos de WhatsApp

```typescript
"group:add_start"        // Abriu modal de adicionar (client)
"group:add_success"      // Grupo adicionado com sucesso (server)
"group:add_error"        // Erro ao adicionar grupo (server)
"group:delete"           // Grupo deletado (client)
"group:view"             // Visualizou detalhes do grupo (client)
"group:refresh"          // Atualizou dados do grupo (client)
```

**Propriedades comuns:**
```typescript
{
  group_id: number,
  group_name?: string,
  members_count?: number,
  source?: "dashboard" | "onboarding",
  error_type?: string,  // Para group:add_error
}
```

### `ai:` - Chat com IA

```typescript
"ai:chat_open"           // Abriu chat de IA (client)
"ai:message_send"        // Enviou mensagem (client)
"ai:message_receive"     // Recebeu resposta (client)
"ai:conversation_create" // Nova conversa criada (client)
"ai:feedback_positive"   // Feedback positivo na resposta (client)
"ai:feedback_negative"   // Feedback negativo na resposta (client)
```

**Propriedades comuns:**
```typescript
{
  conversation_id?: string,
  group_id?: number,       // Se chat é sobre um grupo específico
  message_length?: number,
  response_time_ms?: number,
  question_type?: string,  // Classificação da pergunta
}
```

### `analytics:` - Dashboard de Analytics

```typescript
"analytics:view"            // Visualizou página de analytics (client)
"analytics:block_view"      // Visualizou bloco específico (client)
"analytics:export"          // Exportou dados (client)
"analytics:date_change"     // Mudou período de análise (client)
"analytics:filter_apply"    // Aplicou filtro (client)
```

**Propriedades comuns:**
```typescript
{
  block_id?: string,
  date_range?: string,
  export_format?: "csv" | "pdf",
  filter_type?: string,
}
```

### `onboarding:` - Fluxo de Onboarding

```typescript
"onboarding:start"           // Iniciou onboarding (client)
"onboarding:step_complete"   // Completou etapa (client)
"onboarding:skip"            // Pulou onboarding (client)
"onboarding:complete"        // Finalizou onboarding (client)
```

**Propriedades comuns:**
```typescript
{
  step_number: number,
  step_name: string,
  total_steps: number,
  skip_reason?: string,
}
```

### `activation:` - Momentos de Ativação

```typescript
"activation:first_group_add"     // Adicionou primeiro grupo
"activation:first_insight_view"  // Viu primeiro insight
"activation:first_ai_chat"       // Usou chat de IA pela primeira vez
"activation:first_alert_create"  // Criou primeiro alerta
```

**Propriedades comuns:**
```typescript
{
  days_since_signup: number,
  is_trial: boolean,
}
```

### `dashboard:` - Navegação Geral

```typescript
"section_viewed"    // Visualizou seção (via useTrackSection)
"feature_used"      // Usou feature (via useTrackSection)
"landing:page_view" // Visualizou landing page
```

---

## Propriedades Padrão

### Sufixos

| Sufixo | Tipo | Exemplo |
|--------|------|---------|
| `_id` | string/number | `user_id`, `group_id` |
| `_count` | number | `members_count`, `groups_count` |
| `_at` | ISO string | `created_at`, `upgraded_at` |
| `_ms` | number | `response_time_ms`, `load_time_ms` |

### Prefixos Booleanos

| Prefixo | Exemplo |
|---------|---------|
| `is_` | `is_first_time`, `is_trial`, `is_admin` |
| `has_` | `has_subscription`, `has_groups` |

### Propriedades Automáticas (PostHog)

Não precisa enviar - PostHog adiciona automaticamente:

```typescript
$current_url       // URL atual
$browser           // Browser do usuário
$device_type       // desktop/mobile/tablet
$os                // Sistema operacional
$referrer          // Referrer
$session_id        // ID da sessão
$lib               // Biblioteca (posthog-js)
```

---

## Anti-Patterns

```typescript
// ❌ Espaços e caps
"User Signed Up"

// ❌ Passado
"user_signed_up"

// ❌ Sem categoria
"signup_complete"

// ❌ Objetos aninhados
{ user: { id: "123", name: "João" } }

// ✅ Estrutura flat
{ user_id: "123", user_name: "João" }

// ❌ Propriedades demais (noise)
{ x: 1, y: 2, z: 3, timestamp: "...", random_data: "..." }

// ✅ Só o necessário
{ group_id: 123, action: "delete" }
```

---

## Versionamento de Eventos

Se precisar mudar significativamente um evento:

```typescript
// Versão original
"onboarding:step_complete"

// Nova versão (fluxo redesenhado)
"onboarding_v2:step_complete"
```

Manter ambos por um período para não quebrar funnels existentes.
