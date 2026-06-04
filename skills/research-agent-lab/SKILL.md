---
name: research-agent-lab
description: Use when Codex should apply a lightweight Agent Laboratory-style workflow: literature review, experiment planning, data/code preparation, experiment execution, result interpretation, report writing, and reviewer self-check. Trigger when the user asks to simplify AgentLaboratory into a Codex skill or wants an end-to-end research experiment workflow. Do not use for ordinary code fixes or generic repository maintenance.
metadata:
  short-description: Agent Laboratory workflow summarized for Codex
---

# Research Agent Lab

Summarize the Agent Laboratory process as a Codex-native research workflow. Use Codex as the coordinator instead of simulating separate PhD, postdoc, professor, ML engineer, and reviewer agents.

## When To Use

- Use for turning a research idea into a small, reproducible experimental artifact.
- Use for projects that need a staged path from literature review to report.
- Use when replacing Agent Laboratory-style multi-agent dialogue with direct Codex actions.
- Do not use for normal code edits, bug fixes, refactors, or reviews unless the user explicitly wants the research workflow.

## Inputs

- Required: research topic, objective, or hypothesis.
- Useful: notes on datasets, models, metrics, compute limits, language, report format, and whether web search is allowed.
- Optional: existing YAML configs, prior papers, starter code, API keys already set in environment variables.
- If the topic or expected artifact is missing, ask one concise clarification before proceeding.

## Workflow

1. Frame the objective: restate the research goal, expected deliverables, constraints, and success criteria.
2. Literature pass: inspect local docs first; search external sources only when requested or needed. Summarize related work, methods, datasets, and implementation details.
3. Plan formulation: propose a simple experiment with dataset, baseline, method, metrics, expected outputs, and risks.
4. Data preparation: write or adapt data loading code using real datasets. Prefer existing project patterns and keep generated scripts small.
5. Experiment execution: implement the experiment, run it, capture commands and logs, and iterate only on concrete failures or weak results.
6. Results interpretation: report metrics, compare against the plan, explain failures, and separate measured results from speculation.
7. Report writing: produce a concise report or README with background, method, setup, results, limitations, and reproduction commands.
8. Review loop: self-check novelty, soundness, reproducibility, claim support, missing citations, ethical concerns, and whether another experiment pass is justified.

## Output Rules

- Do not recreate the original multi-agent dialogue protocol or markdown command blocks such as `DIALOGUE`, `PLAN`, or `SUBMIT_CODE`.
- Use Codex tools directly for reading files, editing code, running commands, and validating outputs.
- Prefer concrete artifacts over discussion when the user asks for implementation.
- Do not commit or print real API keys. Prefer `OPENAI_API_KEY`, `DEEPSEEK_API_KEY`, `ANTHROPIC_API_KEY`, or `GEMINI_API_KEY` from the environment.
- Do not claim experimental success unless commands were run or the limitation is clearly stated.
- Keep generated research outputs in an explicit project directory, for example `research_dir/`, `reports/`, or the user-provided path.

## Good Patterns

- "Turn this AgentLaboratory repo into a Codex skill" -> summarize the staged workflow and omit framework code.
- "Run a small research experiment on this idea" -> create a plan, implement the minimal experiment, run it, and write results.
- "Write the final report from these logs" -> extract measured outcomes, cite paths and commands, and avoid unsupported claims.
