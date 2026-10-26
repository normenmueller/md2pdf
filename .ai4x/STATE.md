# Current Handoff

Snapshot: 2026-10-26. This is the single current handoff.
Start with [BEHAVIOR.md](BEHAVIOR.md), [CONTEXT.md](CONTEXT.md), and this file;
recheck Git before acting. Historical approvals are not new execution authority.

# Objective And Authorized Scope

The user requested work on GitHub issue
[#8 - Inline code starting with ü fails with Listings EOL error](https://github.com/normenmueller/md2pdf/issues/8).
The implementation and local verification are complete. The user subsequently
requested integration into trunk, fix-branch cleanup locally/remotely, and a
new release. The selected patch version is 0.2.6. Publication, tag verification,
and installation of 0.2.6 on this system with removal of the previous version
are now authorized. Downstream project changes remain outside the scope.
Issue #7 remains unrelated backlog work.

# Repository Snapshot

- Branch: `fix/inline-code-umlauts`, created for this correction.
- Observed HEAD: `bc883a9da306a1f201a397a1f229b1096571e5d4`
  (`chore: refresh ai4x memory and session handoff`).
- Local `origin/trunk` equals that HEAD. Fetch and live remote-ref inspection
  confirmed the same trunk; neither the fix branch nor v0.2.6 exists remotely
  at this preparation step. The new branch has no upstream yet.
- Startup worktree was clean. All current edits and new files belong to this
  session and remain local and uncommitted. No commit, push, PR, issue update,
  tag, or release was performed.
- Modified: six `src/lib/templates/*.icl` files, Makefile, README.md,
  CHANGELOG.md, CONTEXT.md, and this snapshot.
- Added: `doc/exp/inline-code.md`, `src/tst/expected/inline-code.txt`, and
  `src/tst/inline-code-pdf.sh`. CLI code, filter order, existing goldens,
  installation recipes, template `.tex` files, and host adapters are unchanged.

# Diagnosis And Completed Work

- Read the issue and its empty comment list via the GitHub connector.
- Reproduced the issue's minimal input with the original source renderer:
  exit 43, `Package Listings Error: lstinline ended by EOL`.
- Inspected the installed Listings implementation. `\lstinline@` chooses
  `\lst@InlineM` or `\lst@InlineJ` through `\lst@IfNextCharActive`. An active
  UTF-8 first byte incorrectly selects direct input even though Pandoc's
  `\passthrough` argument has already tokenized the closing delimiter.
- All six bundled includes now locally select the argument scanner inside
  `\passthrough`. German content and the Listings backend are preserved;
  standalone raw Listings calls retain the original scanner selection.
- Added a 36-case PDF/text fixture covering the reported phrase, ASCII,
  leading/internal/isolated `äöüÄÖÜß`, punctuation, explicit code language,
  standalone raw inline listings, and a fenced code block.
- Added documented `make verify-pdf` as a separate compilation gate.
  `make verify` additionally syntax-checks the new test script and retains its
  existing non-PDF checks. Changelog and CLI version now prepare patch release
  0.2.6, dated 2026-10-26.
- Updated CONTEXT.md with the stable integration and verification boundaries.
  BEHAVIOR.md required no rule changes.

# Verification

Executed locally on macOS, with Pandoc 3.12.1, pandoc-crossref 0.3.26, and
pdfTeX 1.40.29 (TeX Live 2026):

- Baseline `make verify`: passed before editing.
- Corrected `make verify`: passed; all existing AST/LaTeX goldens and closure
  identity tests remain green without expected-output changes.
- `make verify-pdf`: passed, all 36 expected text cases in all six templates.
  Both gates were rerun successfully after the version bump to 0.2.6.
- Visual inspection of both default-template pages and the two-column page:
  readable umlauts, monospace code styling, punctuation, and framed code block;
  no clipping or overlap observed.
- Initial PDF checker attempt with `pdftotext -layout` incorrectly combined
  unrelated lines across the two-column template. Diagnosed as extraction
  layout, corrected to `-raw`, then reran all six templates successfully.
- Negative control with the new fixture and original HEAD's headers:
  reproduced exit 43 and `lstinline ended by EOL`.

- `git diff --check`, `./utl/check-charset.sh`, and new script syntax: passed.
  New untracked fixture/test files also passed explicit whitespace and charset
  checks, since the repository charset checker only visits tracked files.
- Reviewed all three memory files together; local Markdown links resolve.
  Fresh-agent re-entry dry-run (self-review): startup, objective, constraints,
  relevant files, verified commands, remaining limits, uncommitted ownership,
  next action, and a concise briefing are identifiable without chat history.
- Final diff review: only the listed task files and memory changes are present.
- Existing local installation: 0.2.5 under `~/.local`; all 27 runtime/completion
  files match tag v0.2.5 without extra runtime files. Install/uninstall dry runs
  with `PREFIX=$HOME/.local` were inspected. Actual replacement remains pending.

# Limits, Decisions, And Next Action

- Actual Ubuntu CI, older toolchain pairs reported in the issue, and complete
  downstream O2I PDF/project acceptance are UNVERIFIED here.
- The scoped repair depends on Listings' existing internal scanner predicate;
  real PDF regression tests should accompany future Listings upgrades.
- Publication and review remain pending. Verify tag target, published state,
  and Latest status after release creation. The exact corrected commit can
  only be recorded after a commit is made.
- Existing issue #7, Homebrew packaging, and downstream recovery are outside
  this task. Historical history/tag rewrites remain non-actionable caveats.
- The charset policy/checker discrepancy remains as recorded in CONTEXT.md;
  this correction uses only characters accepted by the current checker.

# Re-Entry Briefing

Issue #8 is locally corrected on `fix/inline-code-umlauts`; release 0.2.6 is
prepared. Complete release-version verification, commit/PR/integration, publish
and verify v0.2.6, remove the fix branch, then replace the old local installation
and verify an installed PDF render. Record observed results in this snapshot.
Downstream acceptance belongs to the downstream project.
