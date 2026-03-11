# md2pdf Workflow and Guidelines

## Purpose

This document defines the strict execution workflow and quality gates for engineering work in `md2pdf`.
It is optimized for agentic execution and must be followed exactly once activated.

## Activation

Apply this workflow only after explicit user instruction.
Examples: "use workflow", "run release workflow", "strict mode".

## Operating Principles

- Determinism over convenience.
- Small, reversible changes over broad rewrites.
- Verification before conclusion.
- Documentation parity with implementation.
- Explicit assumptions; no hidden behavior changes.

## Language and Character Policy

- All source code and repository documentation must be written in English.
- Agent chat with users must be in German unless the user explicitly requests another language.
- Allowed character set in code and documentation:
  - ASCII characters
  - German umlauts and sharp s: `ä ö ü Ä Ö Ü ß`
  - Copyright symbol: `©`
  - double quote: `"`
  - LaTeX math symbols where needed
- No other Unicode characters are allowed.

## Mandatory Delivery Pipeline

### 1. Intake and Scope Lock

1. Restate requested outcome in concrete terms.
2. Identify touched areas (`src/app`, `src/lib/filters`, `src/lib/templates`, `src/tst`, `README`, completions).
3. Define acceptance checks before editing.

### 2. Repository Discovery

1. Inspect status (`git status --short`).
2. Locate impacted files with `rg`.
3. Read relevant code and docs fully before edits.

### 3. Design Before Edit

1. Choose minimal architecture change that satisfies requirements.
2. Preserve backward-compatible behavior unless explicitly changed.
3. For CLI/path changes, plan cross-cut updates:
   - runtime resolution
   - install/uninstall
   - shell completions
   - tests and docs

### 4. Implementation Rules

1. Prefer `apply_patch` for precise single-file edits.
2. Keep scripts strict (`set -euo pipefail`, defensive checks).
3. Keep Lua filters pure and AST-safe; avoid side effects.
4. Keep templates field-compatible unless change is requested.
5. Use clear naming and avoid temporary compatibility hacks unless explicitly needed.

### 5. Validation Gates

Run what applies to the change set:

1. Shell syntax:
   - `bash -n src/app/md2pdf.sh`
   - `bash -n src/tst/run.sh`
2. CLI sanity:
   - `./src/app/md2pdf.sh --list-templates`
3. Regression tests:
   - `src/tst/run.sh`
4. Install flow sanity:
   - `make -n install`
   - `make -n uninstall`
5. Unified quality gate:
   - `make verify`
6. Smoke render when templates/runtime changed:
   - default template render
   - specialized template render (if touched)

No completion without green checks or explicit note of skipped checks.

### 6. Documentation Sync

When behavior, structure, or naming changes:

1. Update `README.md` to final-state wording only (no migration narrative).
2. Keep path references accurate.
3. Keep template catalog accurate, including specialties.
4. Update operational docs when workflow or release rules changed.

### 7. Commit Discipline

1. Stage all intended changes only.
2. Use a clear, scoped commit message (`feat:`, `fix:`, `refactor:`, `docs:`, `chore:`).
3. Do not amend unless explicitly requested.
4. Never rewrite user changes without request.
5. Use a dedicated branch for each feature, fix, refactor, docs, or chore change.
6. Name branches by change type (`feat/<topic>`, `fix/<topic>`, `refactor/<topic>`, `docs/<topic>`, `chore/<topic>`).
7. Keep one logical change per branch and integrate through a pull request whenever possible.
8. Keep `trunk` as stable integration; do not commit directly to `trunk` unless explicitly approved.
9. Re-run relevant validation gates after rebasing or merging latest `trunk` into a branch before merge.

## Domain-Specific Standards

## Shell and CLI Standards

- Support explicit `--` separation semantics.
- Provide precise error messages with actionable hints.
- Validate required tools and paths before execution.
- Keep install paths configurable through `Makefile` variables.
- Keep completions aligned with actual options.

## Lua Filter Standards

- Transform only intended node types.
- Preserve unaffected AST content exactly.
- Keep order-sensitive behavior documented.
- Add/adjust fixtures for every behavior change.

## Template Standards

- Keep `default` as reliable fallback.
- Keep each template pair (`.tex` + `.icl`) consistent.
- Ensure cross-template feature parity where expected.
- Prevent LaTeX mode conflicts (for example 2-column and `longtable`).
- Respect language metadata (`lang`) and localized labels where configured.

## Testing Standards

- Golden outputs are authoritative.
- Update expected fixtures only for intentional behavior changes.
- Treat diff noise as a signal until explained.

## Release Protocol

### Versioning Policy

Use semantic versioning:

- `MAJOR`: incompatible CLI/output behavior changes
- `MINOR`: backward-compatible feature additions
- `PATCH`: fixes, stability, or documentation-only updates without new behavior

### Mandatory Approval Gates

No public-release command is executed without explicit user approval in chat.
This includes `git push`, tag creation, and GitHub release publication.

Before each release action, provide a "message pack" and wait for approval:

1. Tag name and annotated tag message
2. Release title
3. Release notes body
4. Exact command list to be executed

If the user requests changes, update the message pack and ask again.
Only execute after explicit approval.

### Release Execution Checklist

1. Ensure release tooling is available and authenticated:
   - `gh` installed
   - `gh auth status` successful for target repository
2. Verify clean tree (`git status --short` must be empty).
3. Run quality gate (`make verify`) and report result.
4. Ensure version string in `src/app/md2pdf.sh` matches target release.
5. Ensure `CHANGELOG.md` contains the target version and release date (`YYYY-MM-DD`).
6. Ensure `README.md` reflects shipped behavior and options.
7. Present message pack for approval.
8. Create annotated tag:
   - `git tag -a vX.Y.Z -m "vX.Y.Z"`
9. Push branch and tag:
   - `git push origin trunk`
   - `git push origin vX.Y.Z`
10. Create GitHub release from the approved notes:
   - `gh release create vX.Y.Z --title "vX.Y.Z" --notes-file <file>`
11. Confirm publication by showing release URL and the exact tag/commit mapping.

## Documentation Guidelines

- Write in present tense and final-state form.
- Prefer command examples that run from repository root.
- Keep file paths exact.
- Document user-visible options and defaults.
- Avoid stale aliases or migration notes unless intentionally supported.

## Risk Controls

Stop and escalate if:

- unexpected repository changes appear that may conflict with active edits
- tests fail with unclear root cause
- packaging/runtime path changes could break installation safety

When escalating, provide:

1. concrete observation
2. impact
3. proposed safe options
