# Conversion and Repair Examples

## Inline Code Containing Equals

Bad:

```text
调用 =min_logN=4= 时返回错误。
```

Good:

```org
调用 ~min_logN=4~ 时返回错误。
```

Why: `=...=` is the Org verbatim delimiter. An internal equals sign makes the apparent boundary ambiguous; `~...~` is the native code form.

## Slash Next to Inline Code

Bad:

```text
评估 secure heap/~mlock~、core dump 和 swap 风险。
```

Good:

```org
评估 secure heap / ~mlock~ 、core dump 和 swap 风险。
```

Or rewrite the relationship:

```org
评估 ~mlock~ 、secure heap、core dump 和 swap 风险。
```

Why: `/` is not a valid left boundary for the following `~...~` object, and the CJK enumeration comma is not a valid right boundary. Org therefore leaves the tildes as literal text unless whitespace separates the code object from both.

## Bold Text

Bad:

```text
**影响范围**
```

Good:

```org
*影响范围*
```

Why: doubled asterisks are Markdown, not Org bold markup.

## Link

Bad:

```text
[实现位置](file:///tmp/example.cc)
```

Good:

```org
[[file:/tmp/example.cc][实现位置]]
```

## Plain-Text Link Description

Bad:

```text
[[file:/tmp/example.cc][~VerifyRandomizedSig~]]
```

Good:

```org
[[file:/tmp/example.cc][VerifyRandomizedSig]]
```

When the code styling matters, keep it outside the link:

```org
~VerifyRandomizedSig~（见 [[file:/tmp/example.cc][实现位置]]）
```

Why: although Org can parse inline objects in a link description, downstream Markdown and YMD converters may require the description to contain text nodes only.

## Source Block

Bad:

````text
```cpp
return Error("invalid input");
```
````

Good:

```org
#+begin_src cpp
return Error("invalid input");
#+end_src
```

## Literal Markup in Documentation

When teaching Markdown or showing malformed input, do not let the example masquerade as document markup:

```org
#+begin_example
**Markdown bold** and `Markdown code`
#+end_example
```

The checker intentionally ignores source and example block contents.

## Minimal Local Repair

Before:

```org
错误发生在 =factor=1= 的分支，详见 [代码](file:/tmp/a.cc)。
```

After:

```org
错误发生在 ~factor=1~ 的分支，详见 [[file:/tmp/a.cc][代码]]。
```

Do not rewrite the rest of the paragraph when only these constructs are malformed.
