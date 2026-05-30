# Repository Guidelines

## Project Structure & Module Organization

This repository contains reusable Codex skills. Each skill lives under `skills/` and should be narrow and centered on a `SKILL.md` file with YAML front matter (`name`, `description`) followed by actionable Markdown instructions.

- `skills/emacs/` contains the Emacs skill, helper Elisp in `agent-skills-emacs.el`, and package-debug references.
- `skills/project-plan/` and `skills/project-summary/` contain project workflow skills.
- `skills/research*/` directories contain research, literature, review, report, and outline workflows.
- Optional support files live beside the skill that uses them, such as `agents/openai.yaml`, `references/`, `evals/`, or scripts.

Do not commit local runtime state such as `.agent-shell/` or private/internal `.system/` skill copies.

## Build, Test, and Development Commands

There is no central build step. Use lightweight validation commands:

- `npx skills add jamie-cui/skills --list` checks GitHub skill discovery after changes are pushed.
- `rg --files -g 'SKILL.md' skills` lists local skill entrypoints.
- `python3 -m py_compile skills/research/validate_json.py` checks the Python helper for syntax errors.
- `python3 skills/research/validate_json.py --fields fields.yaml --dir results` validates research JSON outputs when working inside a project that provides those files.
- `git diff --check` catches trailing whitespace and patch formatting issues before commit.

For Emacs helper changes, byte-compile or load the changed file through the user’s running Emacs session when possible.

## Coding Style & Naming Conventions

Keep skill prose concise, portable, and task-focused. Prefer imperative instructions and concrete examples over broad policy. Use lowercase, hyphenated directories under `skills/`, with `SKILL.md` as the required entrypoint. Use 2-space indentation for YAML and 4-space indentation for Python. Keep helper code local to the skill that needs it.

## Testing Guidelines

This repo has no formal test suite yet. Validate the specific artifact you changed: read rendered Markdown for clarity, parse YAML-bearing files with a YAML-aware tool when edited, compile Python helpers, and run relevant Emacs byte-compilation for Elisp. Add focused fixtures or eval data under the owning skill directory when a workflow becomes repeatable.

## Commit & Pull Request Guidelines

Recent history uses Conventional Commit style, for example `docs: add initial README with skills layout and usage` and `feat(skills): add Emacs, project, research, and summary skills`. Keep commits scoped to one logical change.

Pull requests should describe the skill or workflow affected, list validation performed, and call out new helper files, references, or agent configs. Include screenshots only for UI-facing documentation changes.

## Security & Configuration Tips

Avoid committing credentials, local transcripts, private paths, or generated workspace state. Keep agent configs generic and document any external assumptions directly in the relevant `SKILL.md`.
