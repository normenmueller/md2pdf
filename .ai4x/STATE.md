# Current Handoff

Snapshot: 2026-10-26. This is the single current handoff.
Start with [BEHAVIOR.md](BEHAVIOR.md), [CONTEXT.md](CONTEXT.md), and this file;
recheck Git before acting. Historical approvals are not new execution authority.

# Objective And Authorized Scope

The user requested creation of a GitHub issue, then an update and AI-readiness
review of `.ai4x/` before ending and deleting this CLI session.

Issue creation and the memory review are complete. The user subsequently
explicitly requested committing and pushing the current memory changes; this
is the scope of the direct commit to trunk containing this snapshot.
No product implementation, release, installation, or recovery action is
authorized. Issue #7 remains backlog work requiring a new implementation request.

# Repository Snapshot

- Observed branch: `trunk`.
- Base HEAD before memory publication: `71d80173dcd04b520b4840883612f9357f332366`
  (`Merge Pandoc image-alt fixture compatibility`).
- At review time, local `origin/trunk` equaled that base HEAD. Determine the
  publication commit with `git log -1`; recheck current local/remote refs on
  re-entry rather than treating the base revision as the current checkout.
- The worktree was clean before issue creation. The only pre-existing edit
  at the start of the memory review was this session's issue note in STATE.md.
- The publication commit contains only `.ai4x/BEHAVIOR.md`,
  `.ai4x/CONTEXT.md`, and `.ai4x/STATE.md`, all owned by this session.
  Product files and host-specific adapters were not changed. No branch change
  or release is part of this work.
- This snapshot is prepared before commit/push. Their outcome must be checked
  from Git and remote refs; the file does not claim an unobserved push result.

# Completed Work

- Created and confirmed open:
  [#7 - Explain each feature via example](https://github.com/normenmueller/md2pdf/issues/7).
  It requires an inventory linking every user-facing feature to a concise,
  reproducible example, including prerequisites, input, invocation, and expected
  result. Existing README/doc/exp examples should be reused or improved.
  Adding features or changing rendering behavior is out of scope.
- Reviewed README, example paths, filters/templates, existing issues, current
  CLI and test contracts, Git status/history, and all three memory files.
- Replaced competing historical handoffs and obsolete recovery instructions
  with this snapshot. Git retains the previous memory.
- Consolidated stable implementation facts in CONTEXT.md, including
  closure-manifest limitations and the boundary between goldens and PDF tests.
- Preserved the standing prohibition on Copilot co-author trailers in
  BEHAVIOR.md, and added task-specific checks and explicit memory handoff rules.

# Verification

Verified on 2026-10-26 for these memory-only changes:

- `git diff --check`: passed.
- `./utl/check-charset.sh`: passed.
- Repository paths referenced in CONTEXT.md and local Markdown links: checked.
- Fresh-agent dry-run (self-review) using the three memory files: startup, completed scope,
  constraints, relevant files, verification limits, unknowns, next action, and
  user briefing are identifiable without chat history.
- Final diff/status review: only the three intended memory files changed.

Runtime regressions, PDF compilation, and install/uninstall acceptance were
not run: product code, templates, filters, and golden fixtures were unchanged.
Current runtime/dependency health is UNVERIFIED; no historical green test run
is presented as a current result.

# Relevant Historical Caveats

- The base already includes the Pandoc 3.12.1 image-alt wrapping fixture correction
  in `src/tst/expected/main.tex` and `filters-callout.tex` (commit
  `4775358`, merged by `71d8017`). Do not repeat the old integration task.
- Earlier sessions recorded rewrites of published history/tags to remove
  Copilot co-author trailers. Those actions are historical, not instructions
  to repeat them. Recheck refs if an older clone reports divergence.
- Homebrew was assessed only; no packaging implementation was requested.
  Prior dependency-availability claims are stale and must be verified if that
  topic resumes. TeX policy and clean-machine acceptance remain UNKNOWN.
- Downstream recovery state belongs to the affected project. Its current
  installation/PDF acceptance is UNKNOWN here; old approval notes do not
  authorize recovery work from this checkout.
- Observed policy/checker discrepancy: BEHAVIOR.md allows required LaTeX math
  symbols, while the charset checker has no corresponding Unicode exception.
  CONTEXT.md records the implementation boundary. These memory edits use no
  such exception; the checker and user policy were not changed.

# Open Decisions And Next Action

No open decision or blocker remains for this session.

On re-entry, run the startup protocol and check worktree and publication refs.
Issue #7 exists and awaits an implementation request. Follow the user's next
task; do not start implementing the backlog automatically. The publication
authorization above applies only to this session's three memory files.

# Re-Entry Briefing

Issue #7 has been created. The memory is reviewed for use without this session,
and its commit/push was explicitly requested. Verify publication status from
Git. There is no active product task; await the user's next instruction.
