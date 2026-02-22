# CLAUDE.md — Instructions for Claude Code Sessions

This file is read automatically at the start of every Claude Code session in this workspace.

## Project

**Awesomebits** — the web application for the Awesome Foundation, a global micro-granting community that gives $1,000 grants to "awesome" projects. This is a fork (`divideby0/awesomebits`) of the upstream repo (`awesomefoundation/awesomebits`).

We're building **Signal Score** — an AI-assisted application pre-screening system that helps trustees prioritize grant applications by surfacing quality signals. See GitHub issue #590.

## Project Structure

```
.
├── app/                  # Rails application
│   ├── extras/           # SpamChecker, SpamClassifier
│   ├── models/           # ActiveRecord models (Project, Chapter, etc.)
│   └── ...
├── context/
│   └── memory/           # basic-memory knowledge base for Signal Score
├── scripts/
│   └── signal-score/     # Signal Score tooling (Ruby)
├── .scratch/             # Local data, never committed
│   └── data/             # Parquet, CSV, DuckDB files
├── CLAUDE.md             # This file
└── ...
```

## Tech Stack

- **Ruby on Rails** — existing app (Ruby 3.3.6, Rails 7.2.3)
- **PostgreSQL** — production database
- **Ruby** — Signal Score scripts (same toolchain, future Rails integration)
- **DuckDB** — local analytical queries on historical grant data

## Secrets & Configuration

- **`.env.local`** — personal API keys and secrets (gitignored). Never use `.env` for secrets.
- `dotenv-rails` is in the Gemfile and loads `.env.local` automatically.
- Required keys:
  ```
  ANTHROPIC_API_KEY=sk-ant-...
  ```

## Git & Commits

### Commit Lint
- **Header max 50 characters** — this is strict, plan for it
- **Body lines max 72 characters**
- **Format:** `type(scope): description`
- **Types:** feat, fix, refactor, chore, docs, test, perf, ci
- **Valid scopes:** signal-score, spam, data, scripts, context, infra, docs, deps, repo
- **References required:** Include `Refs: #591` or `Closes: #N` in the body
- **Subject must be lowercase** — no sentence-case, start-case, pascal-case, or upper-case

### Branch Convention
- Feature branches: `feat/<issue-number>-<name>` (e.g. `feat/0591-signal-score-scripts`)
- Always branch from `master` (upstream default)

### Git Remotes
- `origin` → `awesomefoundation/awesomebits` (upstream, read-only for us)
- `fork` → `divideby0/awesomebits` (our fork, push here)
- Push to `fork`, PR against `origin`

## Data

### Historical Grant Data
Historical application data is exported from the Awesome Foundation production database and stored in a privileged Google Drive folder. Contact @divideby0 for access.

### Local Data Setup
Data files live in `.scratch/data/` (gitignored). Expected files:
- `projects.csv` → `projects.parquet` → loaded into `awesomebits.duckdb`
- `chapters.csv` → `chapters.parquet` → loaded into `awesomebits.duckdb`
- Additional: `comments.csv`, sample sets, validation scores

### DuckDB
```bash
duckdb .scratch/data/awesomebits.duckdb
```

Use for analytical queries on historical data. Never connect to production.

## Signal Score Architecture

### Scoring Pipeline
1. Application text → LLM batch API (Anthropic)
2. Structured JSON output with Trust Equation dimensions
3. Composite score 0.0–1.0 + feature breakdown + flags

### Trust Equation
`T = (Credibility + Reliability + Intimacy) / (1 + Self-Interest)`

### Key Files
- `scripts/signal-score/score_grants.rb` — batch scoring via Anthropic API
- `scripts/signal-score/import_data.rb` — CSV → Parquet → DuckDB
- `context/memory/` — research notes, analysis, pattern discovery

## Context: Existing Spam Detection

Two existing systems (bot detection only, not content analysis):
- `app/extras/spam_checker.rb` — blocklist + identical fields
- `app/extras/spam_classifier.rb` — behavioral JS metadata analysis

Signal Score is complementary — it analyzes content, not form behavior.

## Notifying Evie

When you finish a task, get stuck, or need feedback:
```bash
openclaw agent --agent main --message "[CC: <brief task name>] <your message>" --timeout 30
```

Keep messages concise — they'll be read on a phone.
