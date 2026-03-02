# Prompt: Auditoria Pareto de Revenue — Claude Code

> **Como usar:** Cole este prompt inteiro no Claude Code na raiz do seu projeto.
> Ele vai analisar o codebase, pesquisar dados de mercado, e gerar um relatório completo em `/docs/pareto-revenue-audit.md`.

---

## O Prompt

```
Você é um auditor técnico-estratégico de startups e micro-SaaS especializado em análise de Pareto (80/20). Sua missão é analisar este projeto de ponta a ponta e identificar as ações de MAIOR IMPACTO com MENOR ESFORÇO que vão fazer este produto começar a faturar o mais rápido possível.

## FASE 1 — RECONHECIMENTO COMPLETO DO PROJETO

Antes de qualquer análise, faça um reconhecimento exaustivo:

1. **Estrutura do projeto**: Leia o README, package.json (ou equivalente), estrutura de pastas, configurações de deploy, variáveis de ambiente (.env.example), docker-compose, etc.
2. **Stack tecnológica**: Identifique frameworks, linguagens, banco de dados, serviços externos, APIs, integrações de pagamento, autenticação, etc.
3. **Funcionalidades existentes**: Mapeie TODAS as rotas, páginas, componentes, endpoints de API, models/schemas do banco, migrations, e fluxos de usuário implementados.
4. **Estado de maturidade**: Determine se o projeto está em fase de ideia, MVP, beta, ou produção. Verifique se há usuários ativos, dados reais, ou se é apenas código.
5. **Monetização atual**: Procure por integrações de pagamento (Stripe, Asaas, Mercado Pago, PayPal, etc.), planos, pricing pages, trials, paywalls, ou qualquer lógica de cobrança.
6. **Gaps críticos**: Identifique o que está FALTANDO para o produto ser vendável (ex: landing page, onboarding, checkout, email transacional, etc.).

## FASE 2 — PESQUISA DE MERCADO E VALIDAÇÃO

Use a internet para pesquisar e validar:

1. **Concorrentes diretos**: Busque por ferramentas similares. Analise pricing, funcionalidades-chave, posicionamento, e diferenciais.
2. **Tamanho do mercado**: Estime o TAM/SAM/SOM com dados disponíveis online.
3. **Modelos de monetização do setor**: Como os concorrentes cobram? Freemium? Trial? Pay-per-use? Licença?
4. **Preço médio praticado**: Qual a faixa de preço que o mercado aceita para esse tipo de solução?
5. **Canais de aquisição comuns**: Como os concorrentes adquirem clientes? SEO, ads, comunidade, afiliados, product-led growth?
6. **Tendências e oportunidades**: Há alguma tendência de mercado que este projeto pode surfar?

## FASE 3 — ANÁLISE DE PARETO (O CORAÇÃO DO RELATÓRIO)

Aplique o Princípio de Pareto em múltiplas dimensões:

### 3.1 — Funcionalidades vs Revenue
- Quais 20% das funcionalidades geram (ou gerariam) 80% do valor percebido pelo cliente?
- Quais funcionalidades existentes são "nice to have" e quais são "must have" para justificar cobrança?
- Existe alguma funcionalidade faltando que é bloqueante para monetização?

### 3.2 — Esforço vs Impacto (Matriz)
Classifique CADA ação recomendada em uma matriz 2x2:
- **Quick Wins** (baixo esforço + alto impacto) → PRIORIDADE MÁXIMA
- **Projetos Estratégicos** (alto esforço + alto impacto) → Planejar
- **Tarefas Incrementais** (baixo esforço + baixo impacto) → Fazer se sobrar tempo
- **Armadilhas** (alto esforço + baixo impacto) → EVITAR

### 3.3 — Caminho Crítico para o Primeiro Real
Mapeie a sequência MÍNIMA de passos necessários para ir do estado atual até o primeiro pagamento de um cliente real. Seja brutalmente pragmático.

## FASE 4 — ANÁLISE TÉCNICA DE PRONTIDÃO

Avalie o projeto tecnicamente:

1. **Qualidade do código**: Está organizado? Há padrões? Tem testes? O código é manutenível?
2. **Performance e escalabilidade**: Há gargalos óbvios? Queries N+1? Falta de cache? Bundle muito grande?
3. **Segurança**: Autenticação implementada? Rate limiting? Validação de inputs? CORS configurado?
4. **DevOps e Deploy**: Está em produção? CI/CD configurado? Monitoramento? Logs?
5. **Dívida técnica**: O que precisa ser refatorado ANTES de escalar?
6. **Integrações de pagamento**: O gateway está configurado? Webhooks funcionando? Lógica de planos implementada?

## FASE 5 — PLANO DE AÇÃO PRIORIZADO

Gere um plano de ação concreto e sequencial:

### Sprint 1 — Quick Wins (1-3 dias)
Ações que podem ser implementadas imediatamente com impacto direto na capacidade de faturar.

### Sprint 2 — Fundação de Revenue (1-2 semanas)
Implementações essenciais para ter um funil de conversão funcional.

### Sprint 3 — Otimização e Escala (2-4 semanas)
Melhorias que aumentam conversão, retenção, e ticket médio.

### Sprint 4 — Crescimento (1-2 meses)
Estratégias de aquisição e expansão.

Para CADA ação, forneça:
- **O que fazer**: Descrição clara e objetiva
- **Por que fazer**: Impacto esperado na receita
- **Como fazer**: Passos técnicos específicos (arquivos a criar/editar, comandos, APIs a integrar)
- **Estimativa de esforço**: Em horas de desenvolvimento
- **Métrica de sucesso**: Como saber se funcionou
- **Dependências**: O que precisa estar pronto antes

## FASE 6 — SUGESTÃO DE PRICING

Com base na análise de mercado e funcionalidades:

1. **Modelo de pricing recomendado**: Qual modelo faz mais sentido para este projeto?
2. **Planos sugeridos**: Defina 2-3 planos com nomes, preços, e limites.
3. **Estratégia de conversão**: Free trial? Freemium? Demo? Qual a melhor porta de entrada?
4. **Projeção conservadora**: Estimativa de receita nos primeiros 3, 6, e 12 meses com premissas claras.

## FASE 7 — GERAÇÃO DO RELATÓRIO

Compile TODA a análise em um relatório completo e bem formatado.

**IMPORTANTE — Salve o relatório em `/docs/pareto-revenue-audit.md`** com a seguinte estrutura:

```markdown
# Auditoria Pareto de Revenue
## [Nome do Projeto]
> Gerado em: [data atual]

### Sumário Executivo
[Resumo de 3-5 parágrafos com as conclusões principais]

### 1. Visão Geral do Projeto
[Dados da Fase 1]

### 2. Análise de Mercado
[Dados da Fase 2 — inclua links das fontes pesquisadas]

### 3. Análise de Pareto
#### 3.1 Funcionalidades Core vs Nice-to-Have
#### 3.2 Matriz Esforço vs Impacto
#### 3.3 Caminho Crítico para o Primeiro Faturamento

### 4. Análise Técnica
[Dados da Fase 4]

### 5. Plano de Ação
#### Sprint 1 — Quick Wins (1-3 dias)
#### Sprint 2 — Fundação de Revenue (1-2 semanas)
#### Sprint 3 — Otimização (2-4 semanas)
#### Sprint 4 — Crescimento (1-2 meses)

### 6. Estratégia de Pricing
[Dados da Fase 6]

### 7. Riscos e Mitigações
[Principais riscos identificados e como mitigar]

### 8. Métricas de Acompanhamento
[KPIs sugeridos para monitorar o progresso]

### 9. Próximos Passos Imediatos
[Top 5 ações para executar HOJE]
```

Crie também o arquivo `/docs/pareto-action-checklist.md` com um checklist executável de todas as ações recomendadas, organizado por sprint, com checkboxes markdown (`- [ ]`).

## REGRAS IMPORTANTES

- Seja PRAGMÁTICO, não teórico. O objetivo é faturar, não ter o código perfeito.
- Prefira soluções que gerem receita em DIAS, não meses.
- Considere o contexto brasileiro quando relevante (meios de pagamento, comportamento do consumidor, etc.).
- Não recomende reescrever o projeto do zero. Trabalhe com o que existe.
- Se encontrar algo crítico que impede a monetização (ex: sem gateway de pagamento), destaque com WARNING.
- Inclua estimativas de receita quando possível, mesmo que conservadoras.
- Use dados reais da internet para embasar recomendações de pricing e mercado.
- Se o projeto já tem funcionalidades prontas que não estão sendo cobradas, destaque isso como a PRIMEIRA oportunidade.
- Crie a pasta `/docs` se ela não existir.

Comece a análise agora. Leia o projeto inteiro primeiro, depois pesquise o mercado, e então gere os relatórios.
```

---

## Variações de Uso

### Para projetos em estágio inicial (só ideia/código)
Adicione ao final do prompt:
```
CONTEXTO ADICIONAL: Este projeto está em estágio inicial e ainda não tem usuários. Foque em identificar o MVP mínimo viável para validação paga — o menor conjunto de funcionalidades que alguém pagaria para usar.
```

### Para projetos que já têm usuários mas não faturam
Adicione ao final do prompt:
```
CONTEXTO ADICIONAL: Este projeto já tem usuários ativos mas não cobra nada. Foque em estratégias de monetização que não afugentem a base atual — como introduzir um plano premium sem remover funcionalidades existentes (modelo freemium).
```

### Para projetos que já faturam mas querem escalar
Adicione ao final do prompt:
```
CONTEXTO ADICIONAL: Este projeto já fatura [R$ X/mês]. Foque em identificar os alavancadores de crescimento — como aumentar ticket médio, reduzir churn, melhorar conversão do trial, e escalar aquisição.
```

---

## Dicas de Execução

1. **Rode na raiz do projeto** — O Claude Code precisa ter acesso a todos os arquivos.
2. **Tenha um `.env.example`** — Ajuda o Claude a entender as integrações externas.
3. **Tenha um README atualizado** — Mesmo que básico, ajuda na Fase 1.
4. **Permita acesso à internet** — Essencial para a Fase 2 (pesquisa de mercado).
5. **Revise o relatório** — O Claude é excelente em análise, mas você conhece seu mercado melhor. Use o relatório como ponto de partida, não como verdade absoluta.
