---
name: skill-name
description: Use when Codex should [perform the specific workflow]. Trigger when the user asks for [task, artifact, or domain], mentions `$skill-name`, or needs [specialized context/tooling]. Do not use for [nearby task that belongs elsewhere].
metadata:
  short-description: Short human-facing summary
---

# Skill Title

One-sentence purpose statement. Keep the skill narrow and state what outcome Codex should produce.

## When To Use

- Use for [primary trigger or workflow].
- Use for [secondary trigger or related workflow].
- Do not use for [out-of-scope task]; use [other skill/tool] instead.

## Inputs

- Required: [files, prompt details, API keys, project context, or other prerequisites].
- Optional: [configuration, examples, references, user preferences].
- If required input is missing, ask for [specific minimal clarification] before proceeding.

## Workflow

1. Inspect [the relevant project files, documents, metadata, or environment].
2. Choose [mode/path] based on [decision criteria].
3. Load only the needed bundled resources:
   - `references/[topic].md` for [when to read it].
   - `scripts/[tool].py` for [when to run it].
   - `assets/[asset]` for [when to reuse it].
4. Execute the task using the repo's existing patterns and the user's constraints.
5. Validate the result with [specific command, parser, linter, test, or manual check].
6. Report what changed, validation performed, and any remaining caveats.

## Output Rules

- Prefer direct edits or concrete artifacts when the user asks for implementation.
- Keep prose concise and task-focused.
- Cite file paths and commands when relevant.
- Write files only when the user requested an artifact or the workflow requires it.
- Do not commit credentials, private paths, transcripts, or generated runtime state.

## Good Patterns

- [Example of a good user request] -> [expected behavior].
- [Example of a second good request] -> [expected behavior].
- [Example of an ambiguous request] -> ask [one concrete question] or choose [safe default].

## Optional Directory Layout

Use only the files that the skill actually needs.

```text
skill-name/
├── SKILL.md
├── agents/
│   └── openai.yaml
├── references/
│   └── topic.md
├── scripts/
│   └── helper.py
└── assets/
    └── template.ext
```

## Optional `agents/openai.yaml`

```yaml
interface:
  display_name: "Skill Display Name"
  short_description: "One short UI-facing description"
  default_prompt: "Use $skill-name to [perform the common task]."
```
