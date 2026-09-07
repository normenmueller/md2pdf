# Purpose

This file contains volatile project memory for future agents. Update it after meaningful progress, decisions, blockers, verification results, failed attempts, or handoff-relevant repository changes.

# Snapshot

- Snapshot date: 2026-09-07 CEST.
- Project root: `/Users/normenmueller/Documents/RND/etc/md2pdf`.
- Stable integration branch: `trunk`; local and remote copies are synchronized (`origin/trunk` at `c8cb54c`) after a full-history rewrite (see below). Working tree clean.
- Latest release: `v0.2.5`; `./src/app/md2pdf.sh --version` reports `md2pdf, v0.2.5, (C) 2026 nemron`.
- Issue #5 (canonical renderer-closure identity manifest) implemented via `--closure-manifest`, shipped in PR #6, squash-merged, closed. `make verify` green (includes new `src/tst/closure-manifest.sh` suite).
- Legacy disjoint tags `md2pdf-v0.4.4`/`md2pdf-v0.4.5` (unrelated history, no common ancestor with `trunk`) were deleted (local + remote) at explicit user request as stale cruft.

# Active Objective

No active objective remains. All requested work for this session (issue #5 feature, release, and Copilot co-author trailer removal) is complete.

# Current State

- `src/app/md2pdf.sh` `--closure-manifest`: prints a flat, deterministic JSON identity (schema `md2pdf.closure-manifest/v1`) covering entry-script SHA-256, filter-manifest path+SHA-256, ordered active Lua filters (`{path, sha256}`), selected template + header-include (`.icl`) path+SHA-256, and `pandoc`/`pandoc-crossref`/`pdflatex` version strings. Bundled-asset paths are datadir-relative; `pandoc-include` is intentionally excluded from version reporting (no `--version`/`--help`, verified empirically). `log_warn`/`log_error` now write to stderr (bug fix, whole-script behavior change). `--closure-manifest` and `--list-templates` are mutually exclusive.
- README, `CHANGELOG.md`, and all three shell completions document `--closure-manifest`. `VERSION="0.2.5"`.
- **Git history was rewritten twice this session** to remove `Co-authored-by: Copilot <...>` trailers (user request, after noticing "Copilot" listed as a GitHub Contributor):
  1. First pass: rewrote only the two commits created during this session's own work (feat commit, release commit) via `git filter-branch --msg-filter` with a `case "$GIT_COMMIT" in <full-sha>) ... esac` pattern (an earlier glob-based attempt with `[ "$GIT_COMMIT" = "sha"* ]` silently failed to match and was caught/redone).
  2. User then reported Copilot still showing as Contributor (repo main-page panel, not just the PR). Investigation found the trailer also present in two **pre-existing, already-published** commits: `8ab76cd` (tagged `v0.2.4`, a shipped release) and `e55f616` (merged PR #2). User explicitly approved rewriting these too, accepting the risk of moving an already-published release tag.
  3. Ran a generic Python `--msg-filter` (`/tmp/strip-copilot-trailer.py`, strips any `Co-authored-by: Copilot <...>` line plus an orphaned preceding blank line) over the **entire** `trunk` history (root..trunk, all 22 commits) via `git filter-branch -f --msg-filter 'python3 /tmp/strip-copilot-trailer.py' -- trunk`. This is the authoritative, complete rewrite; superseded the narrower first pass.
  4. Verified: zero remaining trailer occurrences in any of the 22 `trunk` commit messages (`git log --grep` sweep); working tree/file content unchanged; `bash -n`, `--version`, and full `make verify` all still pass after rewrite.
  5. Tags `v0.2.4` (now `792050e`) and `v0.2.5` (now `c8cb54c`) were deleted and recreated (annotated) pointing to the new rewritten commits, then force-pushed. Older tags (`v0.2.3` and earlier) are ancestors of the rewritten commits, not descendants, so their SHAs were unaffected and did not need retagging.
  6. Force-pushed rewritten `trunk` to `origin` (`--force-with-lease`), pushed corrected tags. GitHub Release objects for `v0.2.4` and `v0.2.5` still resolve correctly (releases are keyed by tag name; `gh release view` confirms both resolve to `trunk`/the new tag SHAs).
  7. PR #6 body was already cleaned of the trailer in the first pass. PR #2's body/comments were checked and contain no trailer text (only the commit message had it).
  8. Cleaned up `git filter-branch` backup refs (`refs/original/*`) and ran `git reflog expire --expire=now --all && git gc --prune=now` after both rewrite passes.
- Going forward, commits made by this agent must not include a `Co-authored-by: Copilot` trailer (explicit standing user instruction).
- Found and fixed a separate, unrelated bug: GitHub releases `v0.2.4` and `v0.2.5` had been created as **drafts** (`isDraft: true`), so GitHub's "Latest" badge on the repo Releases panel still pointed at the last *published* release, `v0.2.3`. Fixed via `gh release edit v0.2.4 --draft=false` and `gh release edit v0.2.5 --draft=false --latest`. Verified via `gh release list --json tagName,isLatest,isDraft`: `v0.2.5` now correctly shows `isLatest: true`, all releases `isDraft: false`. Lesson for future releases: always confirm `gh release view <tag> --json isDraft` after `gh release create`, since a draft release is invisible to "Latest" resolution even though `gh release view` can still show its notes.

# Verification Status

Passed on 2026-09-07 (after the full-history rewrite, on `trunk` at `c8cb54c`):

- `make verify`: `bash -n` checks, `utl/check-templates.sh`, `utl/check-charset.sh`, all golden JSON/LaTeX regression tests, and `src/tst/closure-manifest.sh` (5 cases: unchanged/drifted/reordered/missing-filter/custom-template) - all green.
- `git log trunk --format='%H %s' | grep -i copilot` sweep across all 22 commits: zero matches (clean).
- `gh release view v0.2.4` / `v0.2.5`: both resolve correctly post-retag.
- `bash -n src/app/md2pdf.sh` and `./src/app/md2pdf.sh --version` confirmed working after rewrite.
- Not re-verified this session: `make -n install`/`make -n uninstall` dry-run (no install-path changes were made).

# Decisions

- 2026-09-07: Command name is `--closure-manifest` (explicit user choice over `--renderer-manifest` and other alternatives).
- 2026-09-07: Two background AI agents (rubber-duck critical review + independent alternative design) were commissioned before finalizing the feature, per explicit user request; both converged on a flat, lean JSON schema (see PR #6 / CHANGELOG for the final schema).
- 2026-09-07: `--closure-manifest` shipped as `v0.2.5` (SemVer patch, purely additive per user agreement).
- 2026-09-07: User explicitly approved removing the `Co-authored-by: Copilot` trailer from **all** history, including the already-published `v0.2.4` release tag, after being shown the risk (tag SHA change, already-shipped release). Explicit approval obtained via `ask_user` before any destructive rewrite.
- 2026-09-07: Legacy tags `md2pdf-v0.4.4`/`md2pdf-v0.4.5` deleted at explicit user request; confirmed beforehand they share no ancestry with `trunk` and contain no Copilot trailer, so deletion carries no hidden coupling to the rewritten history.

# Open Decisions

- None outstanding from this session's work.

# Risks And Unknowns

- GitHub's Contributors panel may take time to refresh its cache after a force-push; "Copilot" may still appear there for a while even though the underlying git history is now clean. This is expected and not a sign of a failed rewrite - re-check after some delay if the user reports it's still visible.
- Anyone who had already cloned/pulled/pinned the old `v0.2.4` or `v0.2.5` tags, or any commit SHA reachable only from the pre-rewrite `trunk`, now has a diverged history. This was an explicit, accepted trade-off (single-maintainer repo, low external-consumer risk per user judgment) - not considered an open risk requiring further action, but worth remembering if anyone reports fetch/pull conflicts referencing old SHAs.
- `git filter-branch` is deprecated upstream in favor of `git filter-repo` (not installed in this environment); it was used here because it was already available and sufficient for a single-branch, no-`--all`-refs rewrite. If a future large-scale history rewrite is needed, prefer installing `git filter-repo` first.

# Immediate Next Action

None. All session objectives complete, including issue #5 (closed), the Copilot-trailer history rewrite, and the release-draft/Latest-badge fix. A future agent picking up new work should start with the standard startup protocol (read `.ai4x/BEHAVIOR.md`, `.ai4x/CONTEXT.md`, this file, then `git status --short --branch`) and confirm `origin/trunk` still matches this snapshot's SHA before assuming any prior state.

# Handoff

Repository is in a clean, fully verified state: `trunk` at `faa3399` (== `origin/trunk`), tags `v0.2.4`/`v0.2.5` retagged and pushed, no Copilot co-author trailers remain anywhere in `trunk` history, legacy disjoint tags removed, GitHub releases `v0.2.4`/`v0.2.5` published (not draft) with `v0.2.5` marked Latest, `make verify` green. No uncommitted changes, no open branches besides `trunk`. Safe to end this session; a fresh session can resume by reading this file and `.ai4x/BEHAVIOR.md`/`.ai4x/CONTEXT.md` per the standard startup protocol.
