# Claude Starter Kit

Uma coleção curada de skills, comandos, agentes e templates para o [Claude Code](https://claude.ai/code). Consolidado de 20+ projetos reais.

Copie para qualquer projeto e tenha 166 skills, 4 comandos e 1 agente prontos para uso.

## Como usar

### Instalação em um projeto existente

```bash
./install.sh /caminho/do/seu/projeto
```

O script copia `commands/`, `agents/` e `skills/` para o `.claude/` do projeto destino. Re-execute sempre que atualizar o starter-kit — ele sobrescreve os arquivos existentes.

### Instalação manual

Copie a pasta `.claude/` para a raiz do seu projeto:

```bash
cp -r .claude/commands/ /seu/projeto/.claude/commands/
cp -r .claude/agents/   /seu/projeto/.claude/agents/
cp -r .claude/skills/   /seu/projeto/.claude/skills/
```

### Atualizando projetos

Edite as skills, comandos ou agentes aqui no starter-kit e re-execute `./install.sh` nos projetos que quer atualizar.

## O que vem incluído

### Comandos (4)

| Comando | O que faz |
|---------|-----------|
| `/commit` | Stage all + commit com mensagem gerada por IA |
| `/push` | Push com verificação de upstream |
| `/pr` | Cria PR no GitHub via `gh` CLI |
| `/ship` | Commit + push + PR em um comando só |

### Agentes (1)

| Agente | O que faz |
|--------|-----------|
| `security-auditor` | Auditoria de segurança: APIs, banco de dados, webhooks, auth |

### Skills (166)

#### Desenvolvimento
`api-design` `backend-patterns` `bun-runtime` `clean-code` `claude-api` `coding-agent` `coding-standards` `documentation-lookup` `e2e-testing` `eval-harness` `frontend-patterns` `frontend-slides` `mcp-server-patterns` `nextjs-best-practices` `nextjs-supabase-auth` `nextjs-turbopack` `performance` `playwright-e2e-builder` `senior-qa` `supabase-postgres-best-practices` `tdd-workflow` `testing-patterns` `verification-loop`

#### Workflow & Produtividade
`coding-agent` `dmux-workflows` `gh-issues` `github` `go-mode` `prd` `prd-tasks` `ralph` `ralph-loop` `session-logs` `skill-creator` `strategic-compact` `plan-my-day` `daily-briefing-builder`

#### Marketing & Conteúdo
`ab-test-setup` `ad-creative` `article-writing` `case-study-builder` `churn-prevention` `cold-email` `cold-outreach-sequence` `competitor-alternatives` `content-engine` `content-idea-generator` `content-strategy` `copy-editing` `copywriting` `crosspost` `de-ai-ify` `email-sequence` `form-cro` `free-tool-strategy` `homepage-audit` `launch-strategy` `lead-magnets` `linkedin-authority-builder` `linkedin-profile-optimizer` `market-research` `marketing-copy` `marketing-ideas` `marketing-principles` `marketing-psychology` `newsletter-creation-curation` `onboarding-cro` `page-cro` `paid-ads` `paywall-upgrade-cro` `popup-cro` `positioning-basics` `pricing-strategy` `product-marketing-context` `referral-program` `revops` `sales-enablement` `signup-flow-cro` `social-card-gen` `social-content` `testimonial-collector` `tweet-draft-reviewer` `voice-extractor`

#### SEO
`ai-discoverability-audit` `ai-seo` `analytics-tracking` `posthog` `programmatic-seo` `schema-markup` `seo-audit` `seo-technical` `site-architecture`

#### Segurança
`api-fuzzing-bug-bounty` `api-security-best-practices` `broken-authentication` `healthcheck` `idor-testing` `security-best-practices` `security-review` `security-threat-model` `sql-injection-testing` `top-web-vulnerabilities` `xss-html-injection`

#### Pagamentos
`abacatepay` `stripe`

#### Infraestrutura
`cloudflare` `favicon`

#### Ferramentas CLI & Integrações
`1password` `apple-notes` `apple-reminders` `bear-notes` `blogwatcher` `blucli` `bluebubbles` `camsnap` `canvas` `clawhub` `deep-research` `discord` `eightctl` `exa-search` `fal-ai-media` `gemini` `gifgrep` `gog` `goplaces` `himalaya` `imsg` `investor-materials` `investor-outreach` `last30days` `mcporter` `meeting-prep` `model-usage` `nano-pdf` `node-connect` `notion` `obsidian` `openai-image-gen` `openai-whisper` `openai-whisper-api` `openhue` `oracle` `ordercli` `peekaboo` `reddit-insights` `sag` `sherpa-onnx-tts` `slack` `songsee` `sonoscli` `spotify-player` `summarize` `things-mac` `tmux` `trello` `vault-cleanup-auditor` `video-editing` `video-frames` `voice-call` `wacli` `weather` `x-api` `xurl` `youtube-summarizer`

#### UX & Design
`ux-design`

### Templates de CLAUDE.md (6 stacks)

Templates prontos para configurar o Claude Code em projetos de diferentes stacks:

`common` `nextjs` `node-express` `php` `python` `vue`

### Extras

| Pasta | O que contém |
|-------|-------------|
| `scripts/` | Scripts Ralph para execução autônoma de PRDs |
| `hooks/` | Configs de hooks (auto-prettier, terminal-notifications, auto-format-php) |
| `settings/` | `settings.local.json` pré-configurados (minimal, nextjs, vue) |
| `mcp/` | Configs de MCP servers (common, javascript, python) |
| `prompts/` | Prompts de auditoria e bootstrap |

## Workflow Ralph (execução autônoma)

```
Ideia → /prd → /prd-tasks → /ralph → ralph-setup.sh → ralph.sh → PR
```

Para execução AFK (terminal standalone):

```bash
./scripts/ralph-setup.sh 01   # Cria branch e valida build
./scripts/ralph.sh 01 20      # Roda até 20 iterações autônomas
```

## Licenciamento

Alguns conteúdos têm origens de terceiros:

| Conteúdo | Origem | Licença |
|----------|--------|---------|
| `supabase-postgres-best-practices/` | Supabase oficial | MIT |
| `security-best-practices/` | Creditado a OpenAI | A verificar |
| Diversas skills | tinyplate/claude-code-templates | A verificar |
