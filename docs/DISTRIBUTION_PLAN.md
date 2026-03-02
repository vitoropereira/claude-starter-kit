# Plano de Distribuicao — Claude Starter Kit

> Anotacoes para quando for hora de transformar o kit em produto distribuivel.

## Estado Atual

O kit ja esta 80% generico. Consolidado de 20 projetos, 117 arquivos, tudo sem referencias a projetos especificos.

## O que ja esta pronto pra distribuir

- Commands (commit, push, pr, ship) — 100% universais
- Skills de workflow (PRD/Ralph) — funcionam em qualquer projeto
- Prompts (pareto audit, launch readiness, MVP bootstrap) — genericos
- Templates CLAUDE.md — ja separados por stack
- Hooks e settings — opcionais por natureza

## Ajustes necessarios

### 1. Licenciamento

Alguns conteudos tem origem de terceiros:

| Skill | Origem | Licenca |
|-------|--------|---------|
| `supabase-postgres/` | Supabase official | MIT — manter atribuicao |
| `security-best-practices/` | Credito "authored by OpenAI" | Verificar |
| Skills do tinyplate/claude-code-templates | Daniel Avila | Verificar licenca |

### 2. Stack bias

O kit pende pra Next.js + Supabase + Stripe. Pra distribuicao:

- Separar em "packs" opcionais
- Manter um `core/` com o que e universal

### 3. README publico

O CLAUDE.md atual serve pra uso interno. Pra distribuicao precisa de um `README.md` com:

- O que e, screenshots/demo
- Instalacao (npx? git clone? copy manual?)
- Catalogo visual dos componentes
- Como contribuir

## Estrutura proposta para distribuicao

```
claude-starter-kit/
├── core/                    # Sempre incluido
│   ├── commands/            # commit, push, pr, ship
│   ├── skills/workflow/     # prd, ralph
│   ├── skills/quality/      # clean-code, testing
│   └── prompts/             # auditorias
├── packs/                   # Escolhe o que quer
│   ├── nextjs/              # nextjs-best-practices, supabase-auth, favicon, seo
│   ├── vue/                 # templates vue, components, pages
│   ├── python/              # template python
│   ├── payments-br/         # stripe + abacatepay
│   ├── payments-intl/       # so stripe
│   ├── security/            # OWASP, IDOR, XSS, top-100
│   ├── marketing/           # copywriting + UX
│   └── infrastructure/      # cloudflare, posthog
├── scripts/                 # Ralph automation
├── install.sh               # Script de instalacao interativo
└── README.md                # Documentacao publica
```

### install.sh (ideia)

Script interativo que pergunta:
- Qual sua stack? (Next.js / Vue / Python / PHP / Node)
- Quer pack de pagamentos? (BR / Internacional / Nenhum)
- Quer pack de seguranca? (Sim / Nao)
- Quer pack de marketing/SEO? (Sim / Nao)

E copia so o relevante para `.claude/` do projeto alvo.

## Proximos passos quando for executar

1. Verificar licencas dos conteudos de terceiros
2. Reorganizar na estrutura core/ + packs/
3. Criar install.sh interativo
4. Escrever README.md publico com catalogo visual
5. Adicionar CONTRIBUTING.md
6. Publicar (GitHub public + talvez npx)
