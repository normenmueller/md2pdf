# Current Handoff

Snapshot: 2026-10-26. This is the single current handoff.
Start with [BEHAVIOR.md](BEHAVIOR.md), [CONTEXT.md](CONTEXT.md), and this file;
recheck Git before acting. Historical approvals are not new execution authority.

# Objective And Authorized Scope

The user requested work on issue #8, then integration into trunk, a new release,
local/remote fix-branch deletion, and replacement of the current system's old
installation. All product, release, cleanup, and installation work is complete.
The selected patch version is 0.2.6. Downstream project changes were not requested;
issue #7 remains unrelated backlog work.
The user subsequently explicitly approved committing and pushing only this final
STATE.md update directly on trunk. That approval is limited to this handoff.

# Repository And Publication Snapshot

- Product integration: [PR #9](https://github.com/normenmueller/md2pdf/pull/9),
  squash-merged into trunk at `2ded5ac8fa39e40a665fd6acf13e94fa58a9c2ee`.
- [Issue #8](https://github.com/normenmueller/md2pdf/issues/8) is confirmed
  closed as completed after the merge.
- Annotated tag `v0.2.6`: object `c5f89ae6bde09ae192da290efce45e253544b785`,
  resolves to the product integration commit above. Local and live remote tag
  refs were compared, including the dereferenced commit.
- [Release v0.2.6](https://github.com/normenmueller/md2pdf/releases/tag/v0.2.6)
  was published at 2026-10-26 21:46:13 UTC, is neither draft nor prerelease,
  and is confirmed as GitHub's Latest release. Release notes record the exact
  corrected revision and verification limits.
- `fix/inline-code-umlauts` was deleted locally and remotely after proving its
  tree identical to the squash merge. Live remote-ref lookup confirms absence.
- After product completion, local trunk and origin/trunk both equaled the
  release commit, and the worktree was clean. A fetch/live remote check was
  performed in this session; future freshness must be checked again.
- Current branch: trunk, at the release commit and equal to origin/trunk.
  At preparation time only STATE.md differs, owned by this session and approved
  for direct commit/push. This snapshot precedes its own publication; establish
  the resulting handoff commit, push outcome, and clean worktree from Git.
  No product files differ from the release. The temporary local
  `chore/v0.2.6-handoff` branch was removed; it was never pushed.

# Completed Correction

- Reproduced the reported minimal input: exit 43 and
  `Package Listings Error: lstinline ended by EOL`.
- Diagnosed Listings' scanner choice for Pandoc's pre-tokenized
  `\passthrough` argument. All six includes now locally select the argument
  scanner, preserving German text and code styling. Standalone raw Listings
  calls retain their normal behavior. See CONTEXT.md for the stable contract.
- Added `doc/exp/inline-code.md`, `src/tst/expected/inline-code.txt`, and
  `src/tst/inline-code-pdf.sh`: 36 PDF/text cases per template.
- Added and documented `make verify-pdf`; `make verify` additionally checks
  the new script's syntax. Existing goldens, filter order, template `.tex`
  files, installation recipes, and host adapters were unchanged.
- Version/changelog identify 0.2.6. CONTEXT.md records the integration and
  verification boundaries; BEHAVIOR.md required no changes.

# Verification

Executed locally on macOS with Pandoc 3.12.1, pandoc-crossref 0.3.26, and
pdfTeX 1.40.29 (TeX Live 2026):

- `make verify`: passed on the baseline and correction; rerun successfully
  after the 0.2.6 version bump. All AST/LaTeX goldens and closure tests pass.
- `make verify-pdf`: all 36 expected cases pass for all six templates,
  including after the version bump.
- Visual inspection: both default pages and the two-column page show readable
  umlauts, monospace code, punctuation, and the framed code block, without
  observed clipping or overlap.
- Negative control: the new fixture with original headers reproduces exit 43.
- Initial checker attempt with `pdftotext -layout` joined unrelated cases
  across columns; diagnosed and corrected to content-order extraction (`-raw`).
- `git diff --check`, charset, and script syntax checks passed. New files were
  explicitly checked before staging and included in the tracked charset check
  before commit.
- PR head and squash-merge trees were compared and found identical. GitHub
  returned no commit status checks; no Ubuntu CI result is claimed.
- Final memory review: all three files considered together, local Markdown
  links checked, whitespace/charset passed. Fresh-agent dry-run (self-review)
  identifies startup, completed scope, release/install evidence, constraints,
  limits, ownership, next action, and briefing without chat history.

# Local Installation Acceptance

- Previously installed 0.2.5 was found under `~/.local`. All 27 runtime and
  completion files matched tag v0.2.5; no extra runtime files were present.
- Inspected `make -n PREFIX=$HOME/.local install` and `uninstall`.
- Disposable-prefix 0.2.6 install/uninstall passed, including runtime byte
  comparison and removal of installed runtime/completion files.
- Ran `make PREFIX=$HOME/.local uninstall`; verified removal of the old binary,
  runtime data directory, and all three completions before reinstalling.
- Ran `make PREFIX=$HOME/.local install` from the exact tagged product tree.
- Active binary: `~/.local/bin/md2pdf`; `md2pdf --version` reports 0.2.6.
  All 27 installed runtime/completion files match tag v0.2.6 exactly, without
  stale runtime files. No other md2pdf binary was found on PATH.
- Without MD2PDF_DATADIR override, installed/source closure manifests match for
  all six templates. The installed renderer compiles the 36-case fixture and
  preserves every expected text line. Both installed PDF pages were visually
  checked successfully. Temporary test artifacts are not required for re-entry.

# Limits And Next Action

- Actual Ubuntu CI, older toolchain pairs reported in the issue, and complete
  downstream O2I PDF/project acceptance remain UNVERIFIED here.
- The repair uses Listings' existing internal scanner predicate; retain real
  PDF regression testing during future Listings upgrades.
- Issue #7, Homebrew packaging, and downstream recovery remain outside scope.
  Historical history/tag rewrites are not instructions to repeat them.
- The existing charset policy/checker discrepancy remains as documented in
  CONTEXT.md; this task needed no character-policy exception.
- No product decision or blocker remains. Automatic approval review rejected
  the additional memory commit/push: the release/installation authorization
  did not cover a separate post-completion handoff publication. The user then
  explicitly approved the requested direct trunk commit/push of only STATE.md,
  resolving that authorization blocker. Verify its publication from Git, then
  await the user's next task.

# Re-Entry Briefing

Issue #8 is fixed, merged, and published as stable Latest v0.2.6. The old 0.2.5
installation was removed and 0.2.6 installed and PDF-tested on this system.
The fix branch is gone locally/remotely. Product work is committed and published;
this final STATE.md update is explicitly approved for direct commit/push.
Check Git for its publication outcome and any remaining local changes.
Downstream project acceptance remains the downstream project's responsibility.
