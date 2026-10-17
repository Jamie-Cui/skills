---
name: org-authoring
description: Create, edit, convert, and review Emacs Org files using valid Org structure and native markup. Use when working on .org files, converting Markdown or prose to Org, fixing malformed Org markup, or checking an AI-generated Org document. Do not use for generic Emacs configuration or non-Org plain text.
---

# Org Authoring

Produce Org that Emacs parses as intended, not text that merely resembles Org.

## Workflow

1. Read the target region and nearby content before editing. Follow repository instructions and the file's existing conventions when they are valid Org.
2. Read [references/markup-rules.md](references/markup-rules.md) before authoring, converting, or reviewing markup.
3. Treat headings, drawers, lists, blocks, links, and inline objects as syntax with boundaries. Do not assemble them by visual analogy with Markdown.
4. Preserve the requested scope. Do not normalize unrelated parts of a document unless the user asks for a broader cleanup.
5. After editing, run:

   ```sh
   emacs --batch -Q -l scripts/check_org.el -- path/to/file.org
   ```

   If `emacs` is not on `PATH`, use the available Emacs executable. Resolve every diagnostic in the edited region. Explain any deliberately retained diagnostic.
6. When a live Emacs session is available and document behavior depends on runtime configuration, use the Emacs skill for an Org-aware inspection. The batch checker remains the portable baseline.

## Decisions That Commonly Matter

- Use `~text~` for code, identifiers, paths, flags, and expressions containing `=`. Reserve `=text=` for literal/verbatim text that does not itself contain `=`.
- Separate inline code from adjacent prose punctuation when Org does not recognize that punctuation as a valid markup boundary. In particular, do not write `heap/~mlock~、`; write `heap / ~mlock~ 、` or rewrite the phrase so whitespace surrounds the code object.
- Use `*bold*`, `/italic/`, `_underline_`, `+strike-through+`, `~code~`, and `=verbatim=`. Never emit Markdown `**bold**` or backtick code spans.
- Use `[[URL][description]]` or `[[URL]]` links. Never emit Markdown `[description](URL)` links.
- Keep link descriptions plain text. Do not nest `~code~`, `=verbatim=`, emphasis, or other inline markup inside `[[URL][description]]`; put any required markup outside the link.
- Use `#+begin_src LANGUAGE` and `#+end_src` for source blocks. Never emit fenced Markdown blocks.
- Use `\(...\)` for inline math and `\[...\]` for display math unless the surrounding file consistently uses another Org-supported form.
- Keep property drawers immediately below their heading (and planning line, if present). Close every drawer and block.
- Increase heading depth by at most one level at a time. Preserve valid intentional depth when editing an excerpt whose parent headings are outside the supplied region.
- Write literal Unicode whitespace as ordinary spaces. Do not leak HTML entities such as `&#x20;` into Org prose.

## Conversion and Diagnosis

Read [references/examples.md](references/examples.md) when converting Markdown to Org or explaining a malformed construct. State both the invalid form and the Org-native replacement. For an ambiguous construct, prefer the smallest local rewrite that parses unambiguously.

## Checker Contract

`scripts/check_org.el` combines Org's own linter with focused checks for recurring AI-output mistakes: Markdown emphasis, backticks, Markdown links, fenced blocks, HTML whitespace entities, ambiguous `=name=value=` spans, apparent `~code~` spans that Org leaves unparsed because of invalid boundaries, inline markup nested inside link descriptions, heading-level jumps, and unmatched Org blocks. It ignores literal block contents so examples and source code can contain these forms safely.
