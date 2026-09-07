# Purpose

This file contains volatile project memory for future agents. Update it after meaningful progress, decisions, blockers, verification results, failed attempts, or handoff-relevant repository changes.

# Snapshot

- Snapshot date: 2026-09-07 CEST.
- Project root: `/Users/normenmueller/Documents/RND/etc/md2pdf`.
- Stable integration branch: `trunk`; local and remote copies must be synchronized before new work.
- Latest release: `v0.2.4`; `./src/app/md2pdf.sh --version` reports `md2pdf, v0.2.4, (C) 2026 nemron`.
- Active work branch: `feat/closure-manifest` (not yet merged).

# Active Objective

Implement GitHub issue #5: expose a canonical renderer-closure identity manifest so downstream reproducible-build consumers can verify two `md2pdf` installations render with the exact same effective inputs, not just the same `--version` string.
Evidence: issue #5; active user instruction on 2026-09-07.

# Current State

- `src/app/md2pdf.sh` gained `--closure-manifest`: prints a flat, deterministic JSON identity (schema `md2pdf.closure-manifest/v1`) covering: entry-script SHA-256; filter-manifest path (datadir-relative) + SHA-256; ordered active Lua filters as `{path, sha256}` (datadir-relative paths); selected template + header-include (`.icl`) paths (datadir-relative, or absolute if `--template` points outside datadir) + SHA-256; `pandoc`/`pandoc-crossref`/`pdflatex` version strings. `pandoc-include` is intentionally excluded from version reporting: it exposes no `--version`/`--help` (Pandoc JSON-filter-only protocol, crashes on introspection flags); `check_dependencies()` still fail-closes if the executable itself is missing.
- Design was deliberately kept lean per explicit user request: no `md2pdf.version`, no absolute host-specific paths for bundled assets, no `datadir`/`contract` versioning field, no `template.selector`, no duplicated `render.markdown_extensions`/`fixed_args` block - all considered redundant to the script hash or host-specific noise, per consensus of two background design-review agents (rubber-duck + independent general-purpose alternative design) explicitly commissioned for this feature.
- Fixed a pre-existing, tightly-coupled bug discovered during this work: `log_warn`/`log_error` wrote to stdout instead of stderr, which would have contaminated the new JSON output on any diagnostic and violated the issue's "actionable stderr diagnostic" acceptance criterion. This is a behavior change affecting the whole script's error/warn channel (now stderr), not just the new feature.
- `build_filter_args()` now guards `source "$filters_manifest"` against stdout pollution (`>/dev/null`) and fails closed with a clear message if sourcing fails, so a misbehaving filter manifest can never leak into `--closure-manifest`'s stdout.
- `datadir` is now canonicalized (symlink-resolved, absolute, no trailing slash) via `cd "$datadir" && pwd` right after `resolve_datadir()`, when it exists - needed so datadir-relative path computation in the manifest is stable.
- New helper functions: `sha256_of` (returns 1 instead of calling `exit`, so `set -e`/command-substitution interaction is explicit at call sites via `if ! x="$(sha256_of ...)"; then exit 1; fi`), `json_escape` (full JSON string escaping incl. all C0 control chars via `\uXXXX`, not just quotes/backslashes), `rel_to_datadir` (datadir-relative path for bundled assets, passthrough for external paths), `tool_version` (`LC_ALL=C <tool> --version`, first line only, locale-independent).
- `--closure-manifest` and `--list-templates` are mutually exclusive (explicit error, exit 1).
- Argument-parsing flow: `validate_datadir` -> mutual-exclusivity check -> (`--list-templates` short-circuit) -> `resolve_template_config` + `build_filter_args` (so template/filter resolution errors are fail-closed for closure-manifest too) -> (`--closure-manifest` branch: `check_dependencies` + `print_closure_manifest` + exit 0) -> normal input-file / render path unchanged.
- README, `CHANGELOG.md` (`## Unreleased` section), and all three shell completions (`utl/completions/md2pdf.bash`, `_md2pdf`, `md2pdf.fish`) updated to document `--closure-manifest`. No version bump performed - left for an explicit release step per safety rules on release actions.

# Verification Status

Passed on 2026-09-07 (on branch `feat/closure-manifest`, not yet committed/merged):

- `bash -n src/app/md2pdf.sh` and `bash -n src/tst/run.sh` (via `make verify`).
- `make verify` full run: template listing, `utl/check-templates.sh`, `utl/check-charset.sh`, and all golden JSON/LaTeX regression tests in `src/tst/run.sh` - all green, no regressions from the pre-existing baseline (verified by re-running the identical failing PDF-render smoke check against `git stash`ed original code: the `libpng`/`pdflatex` failure on `doc/exp/main.md`'s `assets/sample-diagram.png` is pre-existing and unrelated to this change).
- Manual acceptance-criteria checks for `--closure-manifest`: (1) two consecutive invocations produce byte-identical stdout (`diff` clean); (2) output is valid JSON (`python3 -m json.tool`); (3) `--template article-modern` changes `template.sha256`/`header_includes.sha256`; (4) reordering two entries in `src/lib/filters/manifest.sh` changes both `filters_manifest.sha256` and the `filters[]` array order/content; (5) temporarily removing a filter file referenced in the manifest yields exit code 1, empty stdout, and a clear stderr diagnostic; (6) `--list-templates` and normal rendering (`-- doc/exp/main.md -o ...`) still work; (7) `--list-templates --closure-manifest` together correctly reports mutual-exclusivity error with exit 1.
- Not yet run: `make -n install`/`make -n uninstall` dry-run re-check (no install-path changes were made, so low risk, but not explicitly re-verified this session).

# Decisions

- 2026-09-07: Command name is `--closure-manifest` (not `--renderer-manifest`), chosen by explicit user selection from four naming options; aligns with the issue's own "effective renderer closure" phrasing and Nix-style closure terminology. Source: explicit user choice via `ask_user`.
- 2026-09-07: Before finalizing implementation, two background AI agents were deliberately commissioned as design consultants per explicit user request ("externe AI Agenten als Berater hinzuziehen"): a `rubber-duck` critical review of the WIP Bash code/JSON design, and an independent `general-purpose` agent producing an unconstrained alternative lean JSON design for comparison. Both converged on removing `md2pdf.version`, `script_path`, `datadir.*`, `DATADIR_CONTRACT`, `template.selector`, and the `render` block, and flattening the JSON. Source: explicit user instruction; both agents' turn-0 responses.
- 2026-09-07: External tool version reporting is asymmetric by necessity: `pandoc`, `pdflatex`, and `pandoc-crossref` report `--version` strings; `pandoc-include` reports none (verified empirically in this environment - it crashes on `--version`/`--help` because it only implements the Pandoc JSON-filter stdin protocol). User explicitly chose "version where available" over omitting both or hashing binaries, after being shown this concrete blocker. Source: explicit user choice via `ask_user`; empirical tool probing this session.
- 2026-09-07: Rejected hashing external tool executables (`pandoc`, `pdflatex`, `pandoc-crossref`, `pandoc-include`) despite the rubber-duck agent's robustness argument (binary hash defeats same-version-different-binary attacks). User explicitly chose the leaner `version_only` approach for pandoc/pdflatex, reasoning that binary-supply-chain integrity is out of scope for a Markdown-to-PDF CLI and belongs at the OS/packaging layer. Source: explicit user choice via `ask_user`.
- 2026-09-07: Bundled-asset paths (filters, filter manifest, default/named templates and their `.icl` files) are reported relative to the canonicalized `datadir`, not as absolute paths, so the manifest is stable across install prefixes (`/usr/local` vs `$HOME/.local` vs source-tree). An explicit `--template /external/path.tex` outside datadir is reported with its resolved absolute path instead, since the path itself is then part of the effective selection. Source: consensus of both consulted agents.
- 2026-09-07: No version bump (`VERSION` in `md2pdf.sh`) and no CHANGELOG entry under a concrete version number; used `## Unreleased` instead, deferring version/tag/release decisions to an explicit later release step per existing safety rules on release actions.

# Open Decisions

- Whether to bump `VERSION` (e.g. to `0.3.0` as a minor feature addition) and cut a release now, or batch this with other pending work - not decided, needs explicit user approval per repository release conventions.
- Whether golden/automated tests should be added for `--closure-manifest` itself (issue #5 acceptance criteria call for "tests cover the unchanged, drifted, reordered, missing-input, and custom-template cases"); so far only manual verification in this session covers these cases, no test script/fixture was added to `src/tst/`.
- Whether `pandoc-include`'s absence from the manifest should eventually be revisited (e.g. if `pandoc-include` ever gains a `--version` flag upstream, or if a lockfile-based version pin becomes available).

# Risks And Unknowns

- No automated regression test exists yet for `--closure-manifest`'s own behavior (determinism, fail-closed paths, drift-sensitivity) - current verification is manual/interactive only from this session. A future agent or reviewer should not assume CI coverage for this feature.
- The PR/branch has not been pushed, opened, or reviewed yet; `git status` on `feat/closure-manifest` may still show `README.md`, `CHANGELOG.md`, `src/app/md2pdf.sh`, and the three `utl/completions/*` files as modified and uncommitted, depending on when this snapshot is read.
- `log_warn`/`log_error` now writing to stderr instead of stdout is a behavior change to the whole script, not just the new feature; any external tooling that scraped `md2pdf`'s stdout for warning/error text would need to switch to reading stderr. This was not present in `v0.2.4`.

# Immediate Next Action

Decide with the user whether to (a) add automated tests for `--closure-manifest` under `src/tst/` before opening a PR, (b) open a PR now and treat tests as a fast-follow, and/or (c) bump `VERSION`/`CHANGELOG` to a concrete release number. Then push `feat/closure-manifest` and open a PR against `trunk` (squash-merge per repository conventions), closing issue #5.

# Handoff

A future agent should read `.ai4x/BEHAVIOR.md`, `.ai4x/CONTEXT.md`, and this file, then run `git status --short --branch` on `feat/closure-manifest` before acting. If continuing this work, re-run `make verify` first to confirm the golden-test baseline is still green before making further changes.
