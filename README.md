# Skills Repository

This repository contains reusable Codex skills: small, focused instruction sets for common workflows such as Emacs debugging, project planning, repository summarization, and research support.

## Layout

- `emacs/` — Emacs-focused workflow plus helper code in `agent-skills-emacs.el`
- `project-plan/` — guidance for maintaining project plans in central org files
- `project-summary/` — instructions for generating repository summaries
- `research*/` — research, literature, review, and reporting workflows
- `.system/` — internal utility skills such as `openai-docs`, `skill-creator`, and `skill-installer`

Most skills are centered around a `SKILL.md` file. Some also include support directories such as `agents/`, `references/`, or `evals/`.

## Working With This Repo

- Read a skill’s `SKILL.md` first; it defines triggers, workflow, and constraints.
- Keep skill instructions concise, portable, and task-focused.
- Place reusable references beside the skill that uses them.
- Add helper code only when plain instructions are not enough.

## Quick Examples

- Inspect available skill files: `rg --files -g '*/SKILL.md'`
- Review recent changes: `git log --oneline`
- Explore the Emacs helper skill: `sed -n '1,120p' emacs/SKILL.md`

## Contributing

When adding a skill, create a dedicated directory with a `SKILL.md`, keep the scope narrow, and document any required helper files or references locally. Prefer simple Markdown instructions over tool- or platform-specific assumptions unless the skill is explicitly specialized.
