# Purpose

This file is volatile project memory for future agents. Update it after meaningful progress, decisions, blockers, verification results, failed attempts, or handoff-relevant repository changes.

# Current Session Update

- Snapshot time: 2026-07-06 10:55:28 CEST.
- Active user request: review whether README install requirements are still accurate and shorten the Quick Start by removing detailed source-include/caption material, then present the change for user correction.
- Working tree before edits: `trunk...origin/trunk [ahead 1]`; no unstaged diff was present. The ahead commit is `e795c16` (`chore: record v0.2.3 release state`).
- Evidence checked:
  - `README.md` install and Quick Start sections.
  - `src/app/md2pdf.sh` dependency check requires `pandoc`, `pdflatex`, `pandoc-include`, `pandoc-crossref`, and conditionally `python3` when `--asset-link` is used.
  - `Makefile` install target uses `make` and the standard `install` utility.
  - `doc/exp` contains runnable examples, including filter and source-include cases.
- Documentation changes made:
  - Renamed README `Requirements` to `Runtime requirements`.
  - Added that repository installation also requires `make` and `install`.
  - Removed the detailed source-snippet, captioned `lst:` snippet, internal listings-normalization note, and duplicate build command from Quick Start.
  - Added a concise pointer to `doc/exp` for runnable examples.
- Verification passed:
  - README and state diff review.
  - `./utl/check-charset.sh`
- Current intent: leave README changes uncommitted for user correction.

# Current Session Update

- Snapshot time: 2026-07-02 11:44:09 CEST.
- Active user request: add `\usepackage{pdflscape}` cleanly to the md2pdf templates.
- Working tree before edits: clean on `trunk...origin/trunk`.
- Diagnosis: template-specific LaTeX package includes live in paired `.icl` files, and all runtime templates load their selected `.icl` through `-H`; therefore `pdflscape` belongs in every template include file rather than in the `.tex` bodies or CLI.
- Changes made:
  - Added `\usepackage{pdflscape}` after `\usepackage{graphicx}` in `src/lib/templates/article-modern.icl`, `src/lib/templates/article-stylish.icl`, `src/lib/templates/article-stylish-2col.icl`, `src/lib/templates/default.icl`, `src/lib/templates/note-modern.icl`, and `src/lib/templates/report-stylish.icl`.
- Verification passed:
  - `./utl/check-templates.sh`
  - `./src/app/md2pdf.sh --list-templates`
  - `rg -n "pdflscape" src/lib/templates/*.icl`
  - Manual PDF smoke test compiling a raw LaTeX `landscape` environment through all six templates.
  - `make verify`
- Failed/non-impacting attempt:
  - The first manual smoke test put Markdown headings and tables inside a raw LaTeX `landscape` environment, so Pandoc passed `##` through to TeX and produced `macro parameter character #` errors. The test input was corrected to use pure LaTeX content inside the raw environment and then passed for all templates.
- Current working tree after changes: modified six template `.icl` files and this state file.
- Release decision: user approved a patch release as `v0.2.3`.
- Release metadata changes:
  - `src/app/md2pdf.sh` version bumped to `0.2.3`.
  - `CHANGELOG.md` entry added for `0.2.3 - 2026-07-02`.
- Verification passed after release metadata update:
  - `./src/app/md2pdf.sh --version` returned `md2pdf, v0.2.3, (C) 2026 nemron`.
  - `make verify`
- Release completion:
  - Commit `8e82035` (`fix: add pdflscape to templates`) was created on `trunk`.
  - Tag `v0.2.3` was created on commit `8e82035`.
  - `origin/trunk` and `origin/v0.2.3` were pushed.
  - GitHub Release `v0.2.3` was created at `https://github.com/normenmueller/md2pdf/releases/tag/v0.2.3`.
- Post-release note: this state update is intentionally after the release tag so the tag remains on the verified release commit.
- Current working tree after release: only `.ai4X/STATE.md` is modified.
- Next action: no release work remains; commit the post-release state note only if desired.

# Current Session Update

- Snapshot time: 2026-06-30 14:45:00 CEST.
- Active user request: discard the recent `mono.theme` direction and instead keep the `idiomatic`/LaTeX `listings` look while fixing duplicate captions for captioned `lst:` code blocks.
- Reset action: local unpushed commit `d0ef2de` (`fix: use bundled mono highlighting theme`) was discarded with `git reset --hard origin/trunk`. No `v0.2.2` tag existed and nothing from that commit was pushed.
- Diagnosis refinement: `idiomatic` is not a Pandoc theme; it is Pandoc's LaTeX `listings` backend. Therefore no custom theme is needed for the desired look.
- Implementation changes in progress:
  - `src/app/md2pdf.sh` version bumped to `0.2.2`.
  - Runtime keeps `--syntax-highlighting=idiomatic` and adds `--metadata listings=true`.
  - Added `src/lib/filters/listing-caption-wrap.lua`.
  - `src/lib/filters/manifest.sh` now runs `listing-caption-wrap.lua` before `pandoc-crossref`.
  - The filter converts captioned `lst:` code blocks to pandoc-crossref listing Divs only for LaTeX output with `listings=true`, so `pandoc-crossref` produces a clean `lstlisting` with exactly one `caption=` option.
  - Updated `src/tst/run.sh` Crossref regression path to use `idiomatic` plus `listings=true`, fail on `codelisting`, and require exactly one `caption=` option.
  - Updated `src/tst/expected/filters-include-code-crossref.tex` to expect `lstlisting`.
  - Updated `CHANGELOG.md` for `0.2.2`.
  - Added README documentation for captioned `lst:` source snippets and the internal normalization that preserves the `idiomatic`/`listings` backend with one caption.
  - Updated `.ai4X/CONTEXT.md` with the durable rationale for `listing-caption-wrap.lua`.
- Verification passed:
  - `bash -n src/app/md2pdf.sh`
  - `bash -n src/tst/run.sh`
  - `./src/app/md2pdf.sh --version` returned `md2pdf, v0.2.2, (C) 2026 nemron`
  - Targeted LaTeX command confirmed a captioned include-code fixture now emits one `lstlisting` with one `caption=` and no `codelisting`.
  - Temporary md2pdf PDF smoke test with a local included Haskell source rendered one visible `Listing 1: Included Haskell Contexts` caption and expanded source code.
  - `src/tst/run.sh`
  - `make verify`
  - `make -n install`
  - `make -n uninstall`
- Current commit state: the local `fix: normalize crossref listings captions` commit contains the v0.2.2 implementation and documentation updates. It is ahead of `origin/trunk` and has not been pushed or tagged.
- Next actions: tag/push/create GitHub Release `v0.2.2` only after final approval.

# Current Session Update

- Snapshot time: 2026-06-30 13:39:53 CEST.
- Active user request: decide whether a `default.icl` fix for `!include` inside a captioned Haskell code block should also be applied to the other template include files; user provided the concrete failing Markdown and LaTeX error `Environment codelisting undefined`.
- Diagnosis: with `pandoc-include` followed by `pandoc-crossref`, a fenced code block such as ```` ```{#lst:o2i-context-types .haskell caption="O2I Kontexttypen"}```` is emitted as LaTeX `\begin{codelisting}`. Since md2pdf loads the selected template's paired `.icl`, `default.icl` does not protect named templates from the same missing-environment error.
- Pre-existing user change: `src/lib/templates/default.icl` already had the `float`/`codelisting` definition when this session began.
- Changes made:
  - Added the same `\usepackage{float}`, `\floatstyle{plain}`, `\newfloat{codelisting}{htbp}{lol}`, and `\floatname{codelisting}{Listing}` block to `article-modern.icl`, `article-stylish.icl`, `article-stylish-2col.icl`, `note-modern.icl`, and `report-stylish.icl`.
  - Updated `doc/exp/filters/include-code.md` to include a captioned `lst:` Haskell include block.
  - Updated existing include-code golden JSON/LaTeX fixtures.
  - Added `src/tst/expected/filters-include-code-crossref.tex`.
  - Extended `src/tst/run.sh` with a targeted `pandoc-crossref` LaTeX regression check for the include-code fixture without adding noisy Crossref metadata to every JSON golden.
- Verification passed:
  - `./utl/check-templates.sh`
  - `src/tst/run.sh`
  - Manual PDF compile of the captioned include-code fixture through `pandoc-include`, md2pdf Lua filters, and `pandoc-crossref` for all six templates: `article-modern`, `article-stylish`, `article-stylish-2col`, `default`, `note-modern`, and `report-stylish`.
  - `make verify`
- Working tree after changes: modified template `.icl` files, include-code fixture/goldens, `src/tst/run.sh`, and this state file; new untracked golden file `src/tst/expected/filters-include-code-crossref.tex`.
- Next action: review the diff and decide whether to commit this as a bug fix.

# Current Session Update

- Snapshot time: 2026-06-23 12:26:54 CEST.
- Active user request: make `pandoc-include` and `pandoc-crossref` fixed md2pdf runtime dependencies, remove the optional `--no-crossref` mode, and treat the change as a clear breaking release.
- Version decision: use `0.2.0` rather than `0.1.3` because the change removes a CLI option and adds a standard runtime dependency. User accepted `0.2` wording; implementation uses full SemVer-style `0.2.0`.
- Branch: `feat/require-pandoc-include`.
- Working tree before edits: clean on `trunk...origin/trunk`; branch was created before editing.
- Implementation changes:
  - `src/app/md2pdf.sh` version bumped to `0.2.0`.
  - `--no-crossref` removed from usage and option parsing.
  - Runtime dependency check now requires `pandoc`, `pdflatex`, `pandoc-include`, and `pandoc-crossref`; `python3` remains conditional for `--asset-link`.
  - Pandoc command now runs `pandoc-include` before the md2pdf Lua filter pipeline and always runs `pandoc-crossref` after it.
  - README documents required filters, `pipx install pandoc-include`, PATH verification, and a source-snippet include example.
  - Bash, Zsh, and Fish completions no longer advertise `--no-crossref`.
  - `CHANGELOG.md` has a `0.2.0 - 2026-06-23` breaking-change entry.
  - Test runner now invokes `pandoc-include` before md2pdf Lua filters and runs from the repository root for deterministic relative include paths.
  - New include regression fixture: `doc/exp/filters/include-code.md`, `doc/exp/filters/include-source.hs`, and matching golden JSON/LaTeX outputs.
  - `.ai4X/BEHAVIOR.md` and `.ai4X/CONTEXT.md` now describe required `pandoc-include`/`pandoc-crossref`.
- Local dependency observation: `pandoc-include` is available at `/opt/homebrew/bin/pandoc-include`, which symlinks to `/Users/normenmueller/.local/bin/pandoc-include`; that wrapper uses the pipx venv at `/Users/normenmueller/.local/pipx/venvs/pandoc-include`. Homebrew has no local `pandoc-include` formula installed.
- Verification passed:
  - `bash -n src/app/md2pdf.sh`
  - `bash -n src/tst/run.sh`
  - `./src/app/md2pdf.sh --version` returned `md2pdf, v0.2.0, (C) 2026 nemron`
  - `./src/app/md2pdf.sh --list-templates`
  - `src/tst/run.sh`
  - `make verify`
  - `./src/app/md2pdf.sh --debug -o /tmp/o2i-include.pdf -- /Users/normenmueller/Documents/RND/str/mdl/o2i/o2i.md`
  - Manual LaTeX-control command confirmed O2I include directives expand into Haskell code and no literal `!include` remains in matched output.
- Failed/non-impacting attempts:
  - A search command using double quotes around a pattern with backticks accidentally executed `pandoc-crossref` with no arguments; it only printed its help/error text and did not modify files.
  - A manual LaTeX-control command first failed because it used relative md2pdf filter paths from the O2I directory; rerun with absolute filter paths passed.
  - `pipx list` failed in the sandbox because pipx tried to write logs outside the workspace. Direct file inspection confirmed the pipx installation layout.
- Next actions: review diff, decide whether to commit, and release/tag only after explicit user approval.
- Release completion update: user approved commit, push, merge to `trunk`, and release creation in the active session. Commit `538bc43` (`feat: require pandoc include and crossref`) was pushed on branch `feat/require-pandoc-include`, fast-forward merged into `trunk`, verified with `make verify`, tagged as `v0.2.0`, and pushed to `origin/trunk` plus `origin/v0.2.0`. GitHub Release `v0.2.0` was created at `https://github.com/normenmueller/md2pdf/releases/tag/v0.2.0`.
- Post-release note: this state update is intentionally after the release tag so the tag remains on the verified release commit.

# Current Session Update

- Snapshot time: 2026-06-06 16:56:18 CEST.
- Active user request: diagnose and fix overly tight text placement after Markdown level-4 headings when running `md2pdf -o o2i.pdf -- o2i.md`; user-provided examples are under `tmp/`.
- Root-selection evidence: `git rev-parse --show-toplevel` returned `/Users/normenmueller/Documents/RND/etc/md2pdf`.
- Branch/status evidence before edits: `git status --short --branch` reported `## trunk...origin/trunk` and untracked `tmp/`.
- Diagnosis: Pandoc maps Markdown level 4 and 5 headings to LaTeX `\paragraph` and `\subparagraph`; LaTeX defaults render these as run-in headings, causing following content to sit too close to the heading.
- Change made: template include files now define `\paragraph` and `\subparagraph` as block headings with explicit `titlesec` spacing. Touched files: `src/lib/templates/default.icl`, `src/lib/templates/article-modern.icl`, `src/lib/templates/article-stylish.icl`, `src/lib/templates/article-stylish-2col.icl`, `src/lib/templates/note-modern.icl`, and `src/lib/templates/report-stylish.icl`.
- Verification passed: `make verify`.
- Example verification passed: `./src/app/md2pdf.sh -o tmp/o2i-fixed.pdf -- tmp/o2i.md`.
- Visual verification passed: rendered page 4 of `tmp/o2i-fixed.pdf` to `tmp/o2i-fixed-page-04.png`; level-4 headings such as `3.1.1.1 Leitprinzipien` and `3.1.1.2 Mission` render as separate block headings with visible spacing before the following definition boxes.
- Working tree after edits: expected modified template include files plus this state file; `tmp/` remains untracked and user-provided/generated diagnostic output.
- Release plan approved by user on 2026-06-06. Active release branch: `fix/block-heading-spacing`.
- Release target: `v0.1.2` as a patch release. Version bump applied in `src/app/md2pdf.sh`; `CHANGELOG.md` entry added for 2026-06-06.
- Integration plan: commit on `fix/block-heading-spacing`, merge into `trunk`, verify `trunk`, then tag `v0.1.2` on `trunk`.
- Release completion: `fix/block-heading-spacing` was fast-forward merged into `trunk`; `make verify` passed on `trunk`; `v0.1.2` was tagged on commit `7a02c00`; `origin/trunk` and tag `v0.1.2` were pushed; GitHub Release `v0.1.2` was created at `https://github.com/normenmueller/md2pdf/releases/tag/v0.1.2`.
- Post-release note: this state update is intentionally after the release tag so the tag remains on the verified release commit.
- Post-release branch cleanup on 2026-06-06 22:57:45 CEST: `git fetch --prune origin` found no remote feature/fix branches; only `origin/trunk` remains. Local merged branch `fix/block-heading-spacing` was deleted. Local branch `pre-initial-20260311-190137` remains because it is not a feature/fix cleanup target and is not merged into `trunk`.
- Current working tree note: `.gitignore` now ignores `tmp/` so user-provided/generated diagnostic files remain out of Git. `trunk` was synchronized with `origin/trunk` before this state-note update.

# Snapshot

- Snapshot time: 2026-06-04 16:02:11 CEST.
- Project root: `/Users/normenmueller/Documents/RND/etc/md2pdf`.
- Root-selection evidence: `git rev-parse --show-toplevel` returned `/Users/normenmueller/Documents/RND/etc/md2pdf`.
- Branch before writing bootstrap files: `trunk...origin/trunk`.
- Branch used for this change: `chore/ai4x-bootstrap`.
- Pre-update working tree: clean according to `git status --short --branch`.
- Current phase: administrative migration of agent operational memory from `doc/ops` and root adapter into canonical `.ai4X/`.
- Prior `.ai4X/` bootstrap files: absent. Evidence: `find .ai4X -maxdepth 2 -type f -print` failed with `No such file or directory`.
- Prior host-specific artifacts: `doc/ops/AGENTS.md`, `doc/ops/_workflow.md`, and root symlink `AGENTS.md -> doc/ops/AGENTS.md` existed before migration.
- Current host-specific adapter: root symlink `AGENTS.md -> .ai4X/BEHAVIOR.md`.
- Bootstrap file status: `.ai4X/BEHAVIOR.md`, `.ai4X/CONTEXT.md`, and `.ai4X/STATE.md` were newly created during this operation.

# Evidence Freshness

Inspected for this update:

- Active user instruction in the current session.
- `git rev-parse --show-toplevel`.
- `git status --short --branch`.
- `rg --files`.
- `ls -la`.
- `find .ai4X -maxdepth 2 -type f -print`.
- `doc/ops/AGENTS.md`.
- `doc/ops/_workflow.md`.
- `README.md`.
- `Makefile`.
- `CHANGELOG.md`.
- `.gitignore`.
- `src/app/md2pdf.sh`.
- `src/tst/run.sh`.
- `src/lib/filters/manifest.sh`.
- `utl/check-templates.sh`.
- `utl/check-charset.sh`.
- Bash, Zsh, and Fish completion files under `utl/completions`.

Not inspected in detail:

- Every individual Lua filter implementation.
- Every LaTeX template body.
- Every golden fixture body.
- Generated PDFs or ignored LaTeX auxiliary outputs.
- External tool versions.

Detected stale or superseded facts:

- `doc/ops/AGENTS.md` and `doc/ops/_workflow.md` are superseded by `.ai4X/` after this migration.
- `README.md` project structure previously listed `doc/ops`; it must be updated when old artifacts are removed.

# Working Tree

- Pre-update observation boundary: before creating `.ai4X/`, the working tree was observed as clean on `trunk...origin/trunk`.
- Branch change: `git checkout -b chore/ai4x-bootstrap` was run before writing files.
- Changes caused by this bootstrap operation:
  - Created `.ai4X/BEHAVIOR.md`.
  - Created `.ai4X/CONTEXT.md`.
  - Created `.ai4X/STATE.md`.
  - Removed superseded old artifacts: `doc/ops/AGENTS.md`, `doc/ops/_workflow.md`, empty `doc/ops/`, and root symlink `AGENTS.md`.
  - Created new root adapter symlink `AGENTS.md -> .ai4X/BEHAVIOR.md` after explicit user confirmation.
  - Updated `README.md` project structure to remove `doc/ops` and add `.ai4X`.
- Existing user-owned changes before this operation: none observed by `git status --short --branch`.
- Ownership of all files modified during this operation: agent-owned for this bootstrap migration.
- State observation boundary: this file records the pre-write state and bootstrap changes. A post-write status check must be run before final handoff.
- Post-write status check was run after old artifact removal and before final validation; expected changed files were present.

# Current State

- `.ai4X/` is now the intended canonical location for agent operational memory.
- `.ai4X/BEHAVIOR.md` contains durable agent role, cognitive capabilities, startup protocol, source-of-truth rules, workflow, standards, commands, safety rules, and maintenance rules.
- `.ai4X/CONTEXT.md` contains stable project understanding, domain model, repository map, architecture/design notes, constraints, non-goals, and user preferences.
- `.ai4X/STATE.md` contains the current volatile snapshot, change ownership, open questions, assumptions, risks, verification status, attempt history, next actions, and handoff notes.
- Old operational artifacts were removed after confirming their useful content was transferred into `.ai4X/`.
- Root `AGENTS.md` now exists as a host-specific adapter to `.ai4X/BEHAVIOR.md`.

# Accepted Definitions

- `.ai4X/BEHAVIOR.md`: durable operating contract for future agents.
- `.ai4X/CONTEXT.md`: durable or slowly changing project understanding.
- `.ai4X/STATE.md`: volatile current project memory and handoff snapshot.
- Host-specific adapter: a file or symlink such as root-level `AGENTS.md` that points an AI runtime to operational instructions but is not canonical storage.
- Golden tests: deterministic expected JSON AST and LaTeX outputs under `src/tst/expected`.
- Unified quality gate: `make verify`.

# Decisions

- 2026-06-04: Use `.ai4X/` as canonical agent bootstrap memory. Source: active user instruction.
- 2026-06-04: Generate repository artifacts in English and continue chat in German. Source: active user instruction and former agent profile.
- 2026-06-04: Treat old `doc/ops` artifacts and root `AGENTS.md` symlink as superseded after successful migration. Source: active user instruction; evidence from repository.
- 2026-06-04: Use branch `chore/ai4x-bootstrap` for this administrative change. Rationale: project branch policy requires dedicated branches for changes intended for merge. Source: former agent profile and workflow.
- 2026-06-04: Create a new root adapter `AGENTS.md -> .ai4X/BEHAVIOR.md`. Source: explicit user answer after bootstrap migration.
- 2026-06-04: Do not record this administrative migration in `CHANGELOG.md`. Source: explicit user answer after bootstrap migration.
- 2026-06-04: There are no additional active technical objectives beyond the bootstrap migration. Source: explicit user answer after bootstrap migration.
- Existing decision: keep `trunk` as stable integration and avoid direct commits to `trunk` without explicit approval. Source: former agent profile and workflow.

# Change Ownership

Files created during this bootstrap operation:

- `.ai4X/BEHAVIOR.md`
- `.ai4X/CONTEXT.md`
- `.ai4X/STATE.md`
- `AGENTS.md` as symlink to `.ai4X/BEHAVIOR.md`

Files updated during this bootstrap operation:

- `README.md`

Files deleted during this bootstrap operation after migration confidence:

- `doc/ops/AGENTS.md`
- `doc/ops/_workflow.md`
- old `AGENTS.md` symlink to `doc/ops/AGENTS.md`
- `doc/ops/` as an empty directory.

Existing user changes preserved:

- None observed before this operation.

Files intentionally not touched:

- Application code under `src/app`.
- Lua filters under `src/lib/filters`.
- LaTeX templates under `src/lib/templates`.
- Golden fixtures under `src/tst/expected`.
- Shell completions under `utl/completions`.
- `CHANGELOG.md`, unless the user later requests changelog tracking for this administrative change.

Ownership uncertainties:

- UNKNOWN after future edits until a fresh `git status --short --branch` is inspected.

# Open Questions

- Should `.ai4X/README.md` exist to explain the bootstrap structure to humans? Impact: not required by the user and would add another artifact to maintain.

# Assumptions

- Assumption: Deleting `doc/ops/AGENTS.md`, `doc/ops/_workflow.md`, and the old root `AGENTS.md -> doc/ops/AGENTS.md` symlink satisfies "delete the old artifacts" after migration. Confidence: high. The user separately confirmed that a new adapter should be created.
- Assumption: No external research is needed because the task is repository-local and policy/instruction migration is based on local files and active user instruction. Confidence: high.
- Assumption: `make verify` is sufficient validation for this administrative migration after file changes, even though no runtime code changes are made. Confidence: medium; invalidated if environment lacks Pandoc or LaTeX.
- Assumption: `.ai4X/STATE.md` should record this operation even though writing it makes the tree dirty. Confidence: high; required by active user instruction.

# Risks

- Root adapter discovery risk is mitigated by the new symlink `AGENTS.md -> .ai4X/BEHAVIOR.md`.
- Removing `doc/ops/_workflow.md` means strict workflow content must remain discoverable in `.ai4X/BEHAVIOR.md`; migration must preserve quality gates, release approval rules, and risk controls.
- `utl/check-charset.sh` scans tracked files only. Newly created `.ai4X/` files will be checked by `make verify` only after they are tracked or when the check is adjusted. Post-write validation should still inspect charset manually or via `git add -N` before relying on `make verify`.
- Full `make verify` may fail if Pandoc, LaTeX, or `pandoc-crossref` are missing in the local environment. That would be an environment/tooling issue, not necessarily a migration defect.

# Working Model Status

- Working model: `md2pdf` is a deterministic Bash/Pandoc/LaTeX conversion tool whose correctness relies on stable CLI behavior, a fixed Lua filter order, paired templates/includes, installable runtime assets, aligned completions/docs, and golden tests.
- Confidence: high for inspected architecture and tooling paths.
- Evidence basis: `README.md`, `Makefile`, `src/app/md2pdf.sh`, `src/tst/run.sh`, `src/lib/filters/manifest.sh`, validation scripts, completions, and former operations docs.
- Unknowns: exact behavior of each Lua filter and each template body was not reviewed during this bootstrap migration.

# Runtime And Tooling Status

- Git is available and project root resolution succeeded.
- `rg` is available and was used for file discovery.
- `date` is available and produced the snapshot time.
- No external network access was needed.
- Runtime dependencies required by `make verify` were available in this environment.
- `make verify` passed after the bootstrap migration.

# Verification Log

- `git rev-parse --show-toplevel`: passed; returned project root.
- `git status --short --branch`: passed before writing; reported `## trunk...origin/trunk`.
- `rg --files`: passed; listed repository files.
- `find .ai4X -maxdepth 2 -type f -print`: failed because `.ai4X/` did not exist; expected pre-update result.
- `sed` reads of old operations docs and key project files: passed.
- `git checkout -b chore/ai4x-bootstrap`: passed; created and switched to migration branch.
- Manual `.ai4X/` charset check: passed. Rationale: `utl/check-charset.sh` checks tracked files via `git ls-files`, while `.ai4X/` files were still untracked during this operation.
- Post-write `git status --short --branch`: passed; showed expected migration changes on `chore/ai4x-bootstrap`.
- `make verify`: passed after the adapter decision update. It ran shell syntax checks, template checks, tracked-file charset check, CLI template listing, and all golden regression tests.
- Fresh-agent dry run: passed. Using `.ai4X/BEHAVIOR.md`, `.ai4X/CONTEXT.md`, `.ai4X/STATE.md`, and repository files, a new agent can identify startup protocol, active objective, constraints, relevant files, verified commands, unknowns, and immediate next action.

# Attempt History

- No failed implementation attempts.
- `.ai4X/` absence was expected and caused creation of new bootstrap files.
- No external research was attempted because the task is local and instruction-driven.

# Next Actions

Immediate:

1. Review `git diff --stat` and file diffs before staging or opening a pull request.
2. Stage intended files and open a pull request from `chore/ai4x-bootstrap` after user approval.

Optional follow-up:

- Stage intended files and open a pull request from `chore/ai4x-bootstrap` after user approval.

# Handoff Notes

- A future agent should begin by reading `.ai4X/BEHAVIOR.md`, `.ai4X/CONTEXT.md`, and this file, then run `git status --short --branch`.
- Briefing outline for the returning user:
  - Current objective: migrate operational agent memory into `.ai4X/`.
  - Current state: `.ai4X/` files created; old artifacts removed; root `AGENTS.md` adapter points to `.ai4X/BEHAVIOR.md`.
  - Open decisions: only whether `.ai4X/README.md` is useful.
  - Immediate next action: review diff and prepare staging or PR if requested.
  - Known risks: full verification depends on local Pandoc/LaTeX tooling, but it passed in this environment.
- Do not restore `doc/ops` or the old `AGENTS.md -> doc/ops/AGENTS.md` adapter.
