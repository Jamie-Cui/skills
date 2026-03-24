---
name: research-add
description: Add items or field definitions to an existing research outline stored in outline.yaml and fields.yaml. Use when expanding a structured research project and keep the workflow portable across agents by preferring concise text questions over agent-specific UI forms.
---

# Research Add - Supplement Items or Fields

## Trigger
`/research-add`

## Workflow

### Step 1: Auto-locate Files
Find `*/outline.yaml` and `*/fields.yaml` in current working directory, auto-read both.

### Step 2: Determine What to Supplement
If the user already specified the target, proceed directly.
Otherwise ask a short plain-text question:
- add items
- add fields
- both

---

## A. Add Items

### A1: Get Supplement Sources
Ask the user for the target items or names if missing.
If the user asks for broader discovery or recent literature, use web search; otherwise stay local.

### A2: Merge and Update
- Append new items to outline.yaml
- Display to user for confirmation
- Avoid duplicates
- Save updated outline

---

## B. Add Fields

### B1: Get Supplement Source
If the user already named the fields, use them directly.
If the user asks for suggestions, derive common fields from the local outline or use web search when recent domain practice matters.

### B2: Display and Confirm
- Display suggested new fields list in terminal
- Ask the user which fields to add if that is still ambiguous
- Ask for category and detail level only when they are not inferable from existing fields.yaml

### B3: Save Update
Append confirmed fields to fields.yaml, save file.

---

## Output
- Updated `{topic}/outline.yaml` (if items added)
- Updated `{topic}/fields.yaml` (if fields added)
