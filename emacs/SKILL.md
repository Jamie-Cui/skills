---
name: emacs
description: "Use this skill proactively for Emacs-related tasks, especially Emacs package development and debugging: reproducing package load failures, inspecting backtraces and *Messages*, reloading edited elisp, byte-compiling files, running ERT tests, exploring configuration, or interacting with a running Emacs instance via emacsclient."
---

# Emacs Operations

Assume the user has an Emacs server running. Use `emacsclient` for all Emacs interactions so the workflow stays portable across agents and operating systems and operates on the user's live session.

Prefer `emacsclient --eval` plus the helper functions in `agent-skills-emacs.el`. Do not rely on OS-specific paths, GUI automation, or agent-specific Emacs integrations.

Use this skill for two broad task types:
- Interactive inspection: inspect functions, variables, minibuffer state, current buffer state, and evaluate expressions in the live session.
- Package development/debugging: reload files, byte-compile files, run ERT tests, inspect `*Messages*`, `*Warnings*`, and `*Backtrace*`, toggle `debug-on-error`, and check whether a feature or symbol is loaded as expected.

## Resource Layout

- `agent-skills-emacs.el`: helper functions loaded into the running Emacs instance
- `references/package-debug.md`: portable debugging workflow for Emacs package development

Locate `agent-skills-emacs.el` relative to this skill file's directory before calling any helper.

## Standard Invocation Pattern

```sh
emacsclient --eval '
(progn
  (load "/path/to/skills/emacs/agent-skills-emacs.el" nil t)
  (agent-skills/FUNCTION ...))'
```

Use absolute paths when loading the helper file.

## Common Operations

### Inspect interactive commands by prefix

```sh
emacsclient --eval '
(progn
  (load "/path/to/skills/emacs/agent-skills-emacs.el" nil t)
  (agent-skills/list-functions "PREFIX"))'
```

### Describe a function

```sh
emacsclient --eval '
(progn
  (load "/path/to/skills/emacs/agent-skills-emacs.el" nil t)
  (agent-skills/describe-function "FUNCTION-NAME"))'
```

### Evaluate an expression in the live session

```sh
emacsclient --eval '
(progn
  (load "/path/to/skills/emacs/agent-skills-emacs.el" nil t)
  (agent-skills/eval-expression "EXPRESSION"))'
```

### Simulate keystrokes

```sh
emacsclient --eval '
(progn
  (load "/path/to/skills/emacs/agent-skills-emacs.el" nil t)
  (agent-skills/execute-keys "KEYS"))'
```

`KEYS` uses `kbd` format.

### Reload an edited elisp file

```sh
emacsclient --eval '
(progn
  (load "/path/to/skills/emacs/agent-skills-emacs.el" nil t)
  (agent-skills/load-file "/abs/path/to/file.el"))'
```

### Byte-compile a file

```sh
emacsclient --eval '
(progn
  (load "/path/to/skills/emacs/agent-skills-emacs.el" nil t)
  (agent-skills/byte-compile-file "/abs/path/to/file.el"))'
```

### Run ERT tests

```sh
emacsclient --eval '
(progn
  (load "/path/to/skills/emacs/agent-skills-emacs.el" nil t)
  (agent-skills/run-ert "prefix-or-regexp"))'
```

### Inspect debug buffers

```sh
emacsclient --eval '
(progn
  (load "/path/to/skills/emacs/agent-skills-emacs.el" nil t)
  (agent-skills/special-buffer "*Messages*" 4000))'
```

Useful names include `*Messages*`, `*Warnings*`, and `*Backtrace*`.

### Toggle debug-on-error

```sh
emacsclient --eval '
(progn
  (load "/path/to/skills/emacs/agent-skills-emacs.el" nil t)
  (agent-skills/toggle-debug-on-error t))'
```

## Package Debug Workflow

For package development problems, follow this order unless the user asks for something narrower:
1. Reproduce the issue in the running Emacs session.
2. Enable `debug-on-error` when failures are not already producing a backtrace.
3. Reload the edited file or feature.
4. Inspect `*Messages*`, `*Warnings*`, and `*Backtrace*`.
5. Byte-compile the changed file to catch warnings and macro/load issues.
6. Run relevant ERT tests if the package has them.
7. Check feature state, symbol bindings, hooks, keymaps, or minor mode state as needed.

Read `references/package-debug.md` when the task is specifically about package development or regression debugging.

## Rules

- Keep the workflow portable: use `emacsclient` and standard Emacs Lisp only.
- Do not assume a specific shell, path separator style, package manager, or init framework.
- Prefer helper functions over raw ad hoc elisp when a helper exists.
- If a helper does not exist for a repeated workflow, use `agent-skills/eval-expression` first and then consider extending the helper file.
- When driving interactive commands, inspect minibuffer and buffer state between key sequences.
- If `emacsclient` cannot reach a running server, report that clearly instead of falling back to `emacs --batch`; batch mode changes semantics for package debugging.
- Present results in a readable summary and quote the most relevant warnings, errors, and backtrace frames.
