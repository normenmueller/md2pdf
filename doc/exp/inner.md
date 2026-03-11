---
kind: Note
status: draft
title: "Obsidian Callout Torture Test"
shorttitle: "Short Title"
subtitle: "A sub-title"
author: md2pdf contributors
date: 2025-01-01
version: "0.1"
toc: true
toc-depth: 2
tags:
  - sys
---

# Section 1 - Basic Structure

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras vitae **bold text** magna, sed *italic text* mi. Aenean `inline-code` vel sapien non, volutpat [an external link](https://example.com). Lorem ipsum [Project Brief](<docs/project-brief.pdf>) dolor [an internal link](<docs/project-brief.pdf>) sit amet, [Project Brief](<docs/project-brief.pdf>) consectetur adipiscing elit.[^base-note]

- [an external link](https://example.com)
- [Project Brief](<docs/project-brief.pdf>)
- [an internal link](<docs/project-brief.pdf>)
- [Project Brief](<docs/project-brief.pdf>)

Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.

> [!tldr]- tl;dr
> ![Sample Diagram](<assets/sample-diagram.png>)

Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam

> [!tldr]- tl;dr
> ![Sample Diagram](<assets/sample-diagram.png>)

## Subsection 1.1 - Lists

Paragraph before a bullet list.

- Bullet one with some lorem ipsum dolor sit amet, consectetur adipiscing elit.
- Bullet two
  - Nested bullet A
  - Nested bullet B
- Bullet three with `inline-code` and **bold**.

Paragraph before an ordered list:

1. First item
2. Second item with *emphasis*
3. Third item with a nested list:
   - Sub bullet one
   - Sub bullet two

### Subsubsection 1.1.1 - Normal Blockquote

> This is a **normal blockquote**, not a callout.
> It starts with `>` but has no `[!tag]`, so the Lua filter must ignore it.

---

# Section 2 - Simple Callouts

## Callout with title and body (single paragraph)

> [!note] A simple NOTE callout
> This is the body of the note. It contains **bold**, *italic*, `code`, and a [link](https://example.com).

## Callout with title and multi-paragraph body

> [!info] Info with multi-paragraph body
> First paragraph of the INFO body. Lorem ipsum dolor sit amet, consectetur adipiscing elit.
>
> Second paragraph of the INFO body, with some more text.

## Callout with title-only (no body)

> [!tip] Only a title

This paragraph is outside the TIP callout and should not be inside the box.

## Callout without explicit title, with body

> [!warning]-
> This WARNING callout has no explicit title. The filter should use the default title "Warning".
>
> Second paragraph of the WARNING body with **bold text**.

---

# Section 3 - Fold markers and variants

## Collapsed state marker `-` and explicit title

> [!abstract]- Abstract with fold marker
> Body of the ABSTRACT callout. The `-` fold marker should be ignored by the Lua filter.

## Expanded state marker `+` and explicit title

> [!success]+ Title with plus marker
> Body of the SUCCESS callout. The `+` fold marker must be ignored.

## Fold marker attached to tag

> [!todo]-
> This TODO callout has the fold state attached directly to the marker.

---

# Section 4 - Callouts with Markdown-rich bodies

## Body with list and code block

> [!note] NOTE with list and code
> This NOTE contains a list:
>
> - Item one
> - Item two
>   - Sub item A
>   - Sub item B
>
> And a fenced code block:
>
> ````bash
> #!/usr/bin/env bash
> echo "Hello from inside a NOTE callout"
> ````

## Mixed inline formatting in title

> [!quote] A **Markdown** *formatted* title
> Body paragraph for the QUOTE callout. The title must be rendered with bold and italic formatting in LaTeX.

---

# Section 5 - Nested Callouts

## Two-level nesting (NOTE contains WARNING)

> [!note] Outer NOTE title
> This is the outer NOTE body, first paragraph.
>
> > [!warning]- Inner WARNING title
> > This is the inner WARNING body, with a list:
> >
> > - Inner item one
> > - Inner item two
> >   - Nested inner bullet
> >
> > Final inner paragraph with **bold** and *italic*.

Paragraph after the nested callouts. This must be outside all boxes.

## Three-level nesting (ABSTRACT -> TIP -> DANGER)

> [!abstract]- Level 1 - Abstract
> Level-1 body, first paragraph.
>
> > [!tip] Level 2 - Tip
> > Level-2 body paragraph with *italic* and **bold**.
> >
> > > [!danger]-
> > > Level-3 DANGER body only, no explicit title, using default "Danger".
> > >
> > > ````python
> > > def nested(level: int) -> str:
> > >     return f"Level {level}"
> > >
> > > print(nested(3))
> > > ````

---

# Section 6 - Edge Cases

## Only marker, no title, no body

> [!bug]-

This paragraph is outside the BUG callout and should not be inside the box.

## Marker plus inline title on next line (SoftBreak case)

> [!definition]-
> Definition title on next line
>
> Body paragraph of the DEFINITION callout. The first line after the marker should be treated as title, not body.

## Marker with inline title and immediate body

> [!caution] Caution title
> This is the CAUTION body, first paragraph.
>
> Second paragraph of the CAUTION body.

---

# Section 7 - Mixed Content with Footnotes

Lorem ipsum dolor sit amet, consectetur adipiscing elit.[^outer] Phasellus fermentum nunc at **arcu** placerat.

> [!definition]- Definition with footnote
> This is a DEFINITION-like callout with a footnote inside.[^def]

> [!todo]- TODO with inline code
> Remember to check `obsidian-callouts.lua` and update the style mappings if new tags are introduced.

[^base-note]: Footnote in normal text in Section 1.
[^outer]: Footnote in normal text in Section 7.
[^def]: Footnote inside a callout body in Section 7.

