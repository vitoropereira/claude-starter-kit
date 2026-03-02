# Claude Starter Kit

Kit consolidado de assets para Claude Code. Copie o que precisar para novos projetos.

## Como Usar

1. **Novo projeto?** Copie a pasta `.claude/` inteira ou escolha componentes individuais
2. **Escolha o template CLAUDE.md** da sua stack em `templates/`
3. **Copie settings** de `settings/` para `.claude/settings.local.json`
4. **Adicione hooks** de `hooks/` ao seu `settings.json`
5. **Configure MCPs** de `mcp/` no `.mcp.json` do projeto
6. **Use prompts** de `prompts/` para auditorias e bootstrapping

---

## Inventario Completo

### Slash Commands (`.claude/commands/`)

| Comando | Descricao |
|---------|-----------|
| `/commit` | Stage all + commit com mensagem AI + Co-Authored-By |
| `/push` | Push seguro com verificacao de upstream |
| `/pr` | Cria PR no GitHub via gh CLI |
| `/ship` | Commit + Push + PR em um so comando |
| `/cleanup-cache` | Limpa node_modules, .next, dist, caches |
| `/lint` | Executa linter (Python: black/flake8/mypy) |
| `/test` | Executa testes (pytest/unittest/Django) |
| `/optimize-images` | Gera WebP + JPEG responsivos |
| `/new-command` | Template para criar novos comandos |

### Agents (`.claude/agents/`)

| Agent | Model | Especialidade |
|-------|-------|---------------|
| `security-auditor` | opus | OWASP, RLS, API, Auth, Next.js |
| `blog-content-manager` | sonnet | Blog bilingue, SEO, imagens |
| `frontend-developer` | sonnet | React/Next.js/Vue components |

### Skills (`.claude/skills/`)

#### Workflow — PRD + Execucao Autonoma
| Skill | Descricao |
|-------|-----------|
| `workflow/prd` | Gera PRD numerado com user stories |
| `workflow/prd-tasks` | Quebra PRD em task files implementaveis |
| `workflow/ralph` | Converte PRD+tasks em prd-XX.json |
| `workflow/ralph-loop` | Loop autonomo de implementacao in-session |

#### Frontend
| Skill | Descricao |
|-------|-----------|
| `frontend/nextjs-best-practices` | Server/Client, routing, caching |
| `frontend/nextjs-supabase-auth` | @supabase/ssr + App Router |
| `frontend/ux-design` | UX anticipatorio (Apple/Jobs) + exemplos TSX |
| `frontend/favicon` | Geracao dinamica/estatica de favicons |
| `frontend/performance` | Core Web Vitals, budgets, otimizacao |

#### Marketing
| Skill | Descricao |
|-------|-----------|
| `marketing/marketing-copy` | Direct Response copywriting + exemplos |

#### SEO
| Skill | Descricao |
|-------|-----------|
| `seo/seo-technical` | Sitemap, robots, metadata, JSON-LD |

#### Pagamentos
| Skill | Descricao |
|-------|-----------|
| `payments/stripe` | Checkout, webhooks, subscriptions |
| `payments/abacatepay` | PIX brasileiro (R$0,80/tx) |

#### Analytics
| Skill | Descricao |
|-------|-----------|
| `analytics/posthog` | Events, feature flags, session replay |

#### Infraestrutura
| Skill | Descricao |
|-------|-----------|
| `infrastructure/cloudflare` | DNS, email routing, R2 storage, Vercel |

#### Database
| Skill | Descricao |
|-------|-----------|
| `database/supabase-postgres` | 33 regras de otimizacao PostgreSQL |

#### Qualidade
| Skill | Descricao |
|-------|-----------|
| `quality/clean-code` | SRP/DRY/KISS/YAGNI + verificacao |
| `quality/testing-patterns` | TDD, factories, mocking |

#### Seguranca
| Skill | Descricao |
|-------|-----------|
| `security/security-best-practices` | OWASP review framework |
| `security/idor-testing` | IDOR/BOLA multi-tenant |
| `security/top-web-vulnerabilities` | 100 vulnerabilidades web |
| `security/xss-html-injection` | XSS stored/reflected/DOM |
| `security/senior-qa` | QA toolkit com scripts Python |

### Scripts (`scripts/`)

| Script | Descricao |
|--------|-----------|
| `ralph.sh` | Loop AFK autonomo (roda claude -p em loop) |
| `ralph-setup.sh` | Cria branch + valida build |
| `ralph-queue.sh` | Fila de PRDs para execucao sequencial |
| `RALPH_PROMPT.md` | Template de prompt para claude -p |

### Prompts (`prompts/`)

| Prompt | Descricao |
|--------|-----------|
| `pareto-revenue-audit.md` | Auditoria 80/20 de monetizacao |
| `launch-readiness-audit.md` | Checklist de lancamento SaaS |
| `mvp-bootstrap-template.md` | Template para bootstrapar MVP |

### Templates CLAUDE.md (`templates/`)

| Stack | Arquivo |
|-------|---------|
| Common (qualquer projeto) | `common/CLAUDE.md` |
| Next.js | `nextjs/CLAUDE.md` |
| Vue.js | `vue/CLAUDE.md` + `components.CLAUDE.md` + `pages.CLAUDE.md` |
| Python | `python/CLAUDE.md` |
| PHP | `php/CLAUDE.md` |
| Node/Express | `node-express/CLAUDE.md` |

### Hooks (`hooks/`)

| Hook | Descricao |
|------|-----------|
| `auto-prettier.json` | Formata JS/TS/CSS/JSON no save |
| `terminal-notifications.json` | Notificacoes macOS (terminal-notifier) |
| `auto-format-php.json` | php-cs-fixer PSR-12 + jq para JSON |

### MCP Configs (`mcp/`)

| Config | Servidores incluidos |
|--------|---------------------|
| `common.mcp.json` | Memory Bank, Sequential Thinking, Brave Search |
| `javascript.mcp.json` | + GitHub, Puppeteer, Slack, FileSystem |
| `python.mcp.json` | + FastMCP, Docker, Jupyter, PostgreSQL |

### Settings (`settings/`)

| Config | Perfil |
|--------|--------|
| `minimal.settings.local.json` | Bun + Git + Gh (minimo) |
| `nextjs.settings.local.json` | NPM + shadcn + Playwright + Vitest (completo) |
| `vue.settings.local.json` | PNPM + Vitest + Playwright (Vue-focused) |

---

## Workflow Ralph (Execucao Autonoma de PRDs)

```
Ideia → /prd → /prd-tasks → /ralph → ralph-setup.sh → ralph.sh → PR
```

1. Use `/prd` para gerar um PRD numerado
2. Use `/prd-tasks` para quebrar em task files
3. Use `/ralph` para converter em prd-XX.json
4. Execute `./scripts/ralph-setup.sh XX` para criar branch
5. Execute `./scripts/ralph.sh XX 20` para rodar 20 iteracoes autonomas
6. Ou use `/ralph-loop XX` para executar in-session

---

## Setup Rapido

```bash
# Copiar tudo para novo projeto
cp -r .claude/ /caminho/do/novo/projeto/.claude/

# Ou copiar apenas o que precisa
cp .claude/commands/ship.md /caminho/do/novo/projeto/.claude/commands/
cp -r .claude/skills/payments/ /caminho/do/novo/projeto/.claude/skills/

# Copiar template CLAUDE.md
cp templates/nextjs/CLAUDE.md /caminho/do/novo/projeto/CLAUDE.md

# Copiar settings
cp settings/nextjs.settings.local.json /caminho/do/novo/projeto/.claude/settings.local.json
```
