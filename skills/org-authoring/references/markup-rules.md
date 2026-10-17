# Org Markup Rules

Use this reference as the correctness baseline. Local style may choose among valid Org forms, but it must not replace them with Markdown syntax.

## Document Structure

- A heading begins at column zero with one or more stars followed by a space: `* Heading`.
- Do not skip from level N to a level greater than N+1 within a complete document.
- Put planning lines and a property drawer directly beneath the owning heading.
- Close drawers with `:END:`.
- Use `-`, `+`, or `*` for unordered lists, and `1.` or `1)` for ordered lists. Indent child items consistently under their parent.
- Put a blank line around blocks when it improves separation; never insert blank lines inside a property drawer.

## Inline Markup

| Meaning | Org form | Avoid |
|---|---|---|
| Bold | `*important*` | `**important**` |
| Italic | `/term/` | `*term*` used as Markdown italic |
| Code | `~min_logN=4~` | `` `min_logN=4` `` |
| Verbatim | `=literal=` | `=name=value=` |
| Link | `[[https://example.com][example]]` | `[example](https://example.com)` |
| Inline math | `\(x + y\)` | `$x + y$` when the file does not establish that convention |

Markup needs valid boundaries. Do not place punctuation or word characters so close to delimiters that Org treats them as ordinary text. If nesting becomes hard to read, rewrite the sentence or use a block instead of stacking delimiters.

A slash is not a safe left boundary for code or verbatim markup, and punctuation outside Org's configured post-boundary set—including common CJK punctuation—is not a safe right boundary. For example, Org does not parse the intended code object in `secure heap/~mlock~、`; the tildes remain literal. Add spacing on both sides (`secure heap / ~mlock~ 、`) or rewrite the prose so whitespace surrounds the code object. Do not assume punctuation that looks like a separator to a reader is also an Org markup boundary.

Use `~...~` for programming tokens and any token containing `=`. In `=min_logN=4=`, Org can close the verbatim object at the second `=`, so the intended token is not represented reliably. Write `~min_logN=4~`.

## Links

- File link: `[[file:/absolute/path/to/file.org::42][description]]`
- Relative file link: `[[file:../notes/design.org][design note]]`
- Web link: `[[https://example.com][example]]`
- Bare target: `[[https://example.com]]`

Keep link descriptions plain text for predictable export. Do not write forms such as `[[file:/tmp/a.cc][~Verify~]]` or `[[https://example.com][*important*]]`; nested inline objects can become unsupported child nodes in downstream Markdown/YMD converters. Use `[[file:/tmp/a.cc][Verify]]`, or keep the marked-up token outside the link, as in `~Verify~（见 [[file:/tmp/a.cc][实现位置]]）`.

Use a search option or line locator only when it will remain meaningful. Verify file links after moving or renaming files. Do not escape underscores inside Org links merely because Markdown or LaTeX would require it.

## Blocks

Use matching, case-insensitive block delimiters:

```org
#+begin_src cpp
auto ok = verify(input);
#+end_src

#+begin_quote
Quoted prose.
#+end_quote

#+begin_example
Literal example text.
#+end_example
```

Content inside source and example blocks is literal for the purposes of this skill. Markdown syntax shown there is not an Org-markup defect.

## Escaping and Export

- Prefer literal UTF-8 characters in prose.
- Use Org export snippets only when the target backend requires them and the file already depends on that backend.
- Do not paste HTML character entities for whitespace. Replace `&#x20;`, `&nbsp;`, and similar artifacts with real whitespace where appropriate.
- Protect literal markup demonstrations with an example or source block instead of increasingly complex inline escaping.

## Editing Discipline

- Preserve TODO keywords, priorities, tags, IDs, timestamps, drawers, and link targets unless the request changes them.
- Do not reflow tables, source blocks, or cryptographic/math expressions as ordinary prose.
- Avoid repository-wide cleanup during a local correction.
- Re-open or parse the changed file after editing; visual inspection alone is insufficient.
