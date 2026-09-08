# Signal Score Architecture Decisions

## LLM-as-Judge over Embeddings
**Decision:** Use LLM direct evaluation, not embedding similarity.
**Rationale:** Embeddings add infrastructure for a problem that doesn't need it. LLMs can read and reason about full application text. Cost: ~$0.02/app with Haiku 4.5.

## Trust Equation as Framework
**Decision:** Score using `T = (C + R + I) / (1 + S)` mapped to AF's own evaluation criteria.
**Rationale:** The Trusted Advisor framework maps directly to the Awesome Foundation's New Chapter Handbook criteria. Validated empirically with zero false negatives on 181 labeled apps.

## Content Analysis, Not Bot Detection
**Decision:** Signal Score analyzes *what* was written. Existing SpamChecker/SpamClassifier handle *how* the form was filled out.
**Rationale:** Clean separation of concerns. No overlap. Signal Score runs async after submission.

## Batch API for Scoring
**Decision:** Use Anthropic Batch API (not real-time).
**Rationale:** 50% cost reduction, no rate limit pressure, results within 24h. Good fit since scoring doesn't need to be instant.

## Pattern Discovery Before Rubric
**Decision:** Use LLM as qualitative researcher first, then build rubric from discovered patterns.
**Rationale:** Avoids encoding assumptions. Patterns emerged from data, not preconceptions.

## "Signal Score" Naming
**Decision:** Renamed from "Auto-Awesome Score" to "Signal Score."
**Rationale:** "Auto-Awesome" implies bypassing human review. Signal Score communicates that it surfaces signals for trustees to interpret.

## Data Location
**Decision:** Historical data in `.scratch/data/` (gitignored). Source CSVs from privileged Google Drive folder.
**Rationale:** Data contains PII (applicant names, emails, project descriptions). Must not be committed to a public fork.

## Secrets in .env.local
**Decision:** Use `.env.local` for personal API keys, not `.env`.
**Rationale:** `.env` could be checked in by accident. `.env.local` is the Rails/dotenv convention for personal secrets. `dotenv-rails` already in the Gemfile loads it automatically.
