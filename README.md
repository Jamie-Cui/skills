# Skills Repository

This repository contains reusable Codex skills: small, focused instruction sets for common workflows such as Emacs debugging, project planning, repository summarization, and research support.

## Layout

- `skills/emacs/` — Emacs-focused workflow plus helper code in `agent-skills-emacs.el`
- `skills/project-plan/` — guidance for maintaining project plans in central org files
- `skills/project-summary/` — instructions for generating repository summaries
- `skills/research*/` — research, literature, review, and reporting workflows
- `.system/` — local/internal utility skills; this directory is ignored by git

Most skills are centered around a `SKILL.md` file. Some also include support directories such as `agents/`, `references/`, or `evals/`.

## Installation

Install from GitHub with the Skills CLI:

```sh
npx skills add jamie-cui/skills
```

Useful variants:

```sh
npx skills add jamie-cui/skills --list
npx skills add jamie-cui/skills --all
npx skills add jamie-cui/skills --skill emacs
```

## Working With This Repo

- Read a skill’s `SKILL.md` first; it defines triggers, workflow, and constraints.
- Keep skill instructions concise, portable, and task-focused.
- Place reusable references beside the skill that uses them.
- Add helper code only when plain instructions are not enough.

## Quick Examples

- Inspect available skill files: `rg --files -g 'SKILL.md' skills`
- Review recent changes: `git log --oneline`
- Explore the Emacs helper skill: `sed -n '1,120p' skills/emacs/SKILL.md`

## Contributing

When adding a skill, create a dedicated directory under `skills/` with a `SKILL.md`, keep the scope narrow, and document any required helper files or references locally. Prefer simple Markdown instructions over tool- or platform-specific assumptions unless the skill is explicitly specialized.
