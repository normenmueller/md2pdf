# Purpose

This file contains volatile project memory for future agents. Update it after meaningful progress, decisions, blockers, verification results, failed attempts, or handoff-relevant repository changes.

# Snapshot

- Snapshot date: 2026-08-11 CEST.
- Project root: `/Users/normenmueller/Documents/RND/etc/md2pdf`.
- Stable integration branch: `trunk`; local and remote copies must be synchronized before new work.
- Latest release: `v0.2.4`; `./src/app/md2pdf.sh --version` reports `md2pdf, v0.2.4, (C) 2026 nemron`.
- Working tree was clean before the active maintenance change.

# Active Objective

No active product or migration objective remains. The lowercase `.ai4x/` normalization, repository-reference updates, merge, and branch cleanup are complete.
Evidence: active user instruction on 2026-08-11; merged PR #3.

# Current State

- `.ai4x/BEHAVIOR.md` is the durable operating contract.
- `.ai4x/CONTEXT.md` contains stable project understanding.
- `.ai4x/STATE.md` is this volatile handoff snapshot.
- Root `AGENTS.md` resolves to `.ai4x/BEHAVIOR.md`.
- The bootstrap migration from `doc/ops` completed in commit `8716051`; restoring those superseded files is not an active objective.
- Release `v0.2.4` includes the single-Pandoc performance change from commit `e55f616`; Pandoc manages required internal `pdflatex` reruns.
- Local and remote branch cleanup on 2026-08-11 removed merged or stale refs for `feat/require-pandoc-include`, `perf/single-pass`, and the local backup `pre-initial-20260311-190137` branch and tag. Only `trunk` remained before creating the active maintenance branch.
- PR #3 merged the lowercase `.ai4x/` migration into `trunk` as `aacfefd`; its local and remote work branch was deleted afterward.

# Change Ownership

The completed PR #3 scope was user-requested and agent-owned:

- Case-only rename of the legacy mixed-case directory to `.ai4x/`.
- Reference updates in `.ai4x/BEHAVIOR.md`, `.ai4x/CONTEXT.md`, `README.md`, and `.github/agents/md2pdf.agent.md`.
- Volatile-memory refresh in `.ai4x/STATE.md`.
- Root adapter update to `.ai4x/BEHAVIOR.md`.

No application code, Lua filters, templates, golden fixtures, completions, release metadata, or generated PDFs are in scope.

# Decisions

- 2026-08-11: Use lowercase `.ai4x/` consistently. Source: explicit user instruction.
- 2026-08-11: Remove the obsolete `pre-initial-20260311-190137` local backup branch and tag after confirming that the current code is consolidated in `trunk` and accepting loss of the three old granular commits. Source: explicit user approval.
- Existing: keep `trunk` stable; use a dedicated branch for merge- or release-intended changes and do not commit directly to `trunk` without explicit approval.

# Verification Status

Passed on 2026-08-11:

- Repository search found no legacy mixed-case path references.
- `AGENTS.md` resolves to `.ai4x/BEHAVIOR.md` and its target exists.
- `git ls-files` records `BEHAVIOR.md`, `CONTEXT.md`, and `STATE.md` under lowercase `.ai4x/`.
- `git diff --check HEAD --` passed.
- `make verify` passed, including Bash syntax, template integrity, charset, CLI template listing, JSON/LaTeX golden tests, and the cross-reference regression.

# Open Decisions

- None for the completed maintenance work.

# Risks And Unknowns

- Case-only renames require explicit verification because the current macOS filesystem is case-insensitive while Git paths are case-sensitive.
- No runtime behavior change is intended; any application or golden-output diff would be unexpected and must be investigated.
- External dependency versions were not re-audited for this administrative task.

# Immediate Next Action

No maintenance action remains. Begin future work from a clean, synchronized `trunk` and create a dedicated branch when required.

# Handoff

A future agent should read `.ai4x/BEHAVIOR.md`, `.ai4x/CONTEXT.md`, and this file, then run `git status --short --branch` before acting.
