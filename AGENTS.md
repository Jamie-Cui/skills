# Repository Guidelines

## Source and layout

This repository is the source of truth for the skills under `skills/`.
Edit those sources rather than files through `~/.agents/skills`.
Each lowercase, hyphenated skill directory contains `SKILL.md`; keep its
scripts, references, assets, licenses, evals, and agent metadata beside it.
Preserve existing helper scripts' executable permissions and license notices.
Resolve resources relative to the owning skill, without hard-coded checkout
paths.  Repository metadata stays at the root and is not deployed.

The skills were migrated from `~/opt/dotfiles`.  Dotfiles no longer manages
their source or deployment.  The root `skills/` directory is one Stow package
containing all managed skills; the Makefile deploys them together.

## Deployment

Use the Makefile and GNU Stow; do not add a separate installer,
`npx skills add`, or publication machinery unless explicitly requested.
The default target is `~/.agents/skills`.  `TARGET` overrides the exact skills
directory; otherwise `DEPLOY_HOME` selects the home containing `.agents/skills`.
Keep target overrides consistent across preview, deployment, and removal.

- `make` or `make help`: show commands and the selected target directory.
- `make list`: list managed skills.
- `make dry-run`: preview deployment without modifying the target; a missing
  target is previewed in a temporary directory.
- `make stow` or `make bootstrap`: install managed links.
- `make restow`: refresh this repository's links.
- `make unstow`: remove all links owned by this repository.
- `make verify`: test the Stow lifecycle, independent skill preservation, and
  conflicting-file rejection in a temporary home.

Always run `make dry-run` before modifying a real installation.  Do not use
`stow --adopt` or overwrite independently installed skills.  Unstow while the
source still exists before removing, renaming, or relocating it; then preview
and restow the remaining skills.  Preserve user files and unrelated links.
Content edits through an existing directory link do not require restowing.

## Validation and documentation

After layout or Makefile changes, run `make verify`.  After adding, renaming,
or removing skills, update the README skill directory, run `make dry-run`, and
run `make restow`.  Deployment verification does not establish skill behavior.
For content changes, validate the changed frontmatter, resolve referenced
resources, inspect rendered Markdown, and check relevant helper behavior.
Preserve existing invocation policies unless the user asks to change them.
Do not rewrite skill instructions merely as part of moving files.

Keep `README.org` in native Org syntax and its command table consistent with
the Makefile.  Check the document from the repository root:

```sh
emacs --batch -Q -l skills/org-authoring/scripts/check_org.el -- README.org
```

If `emacs` is not on `PATH`, use an available executable's absolute path.
Validate local links, including each skill entrypoint in the directory table,
and inspect HTML export when changing document structure.  Documentation-only
changes need these checks rather than redeployment.

## Repository hygiene

Do not commit credentials, private keys, local state, compiled bytecode, or
caches.  Use concise Conventional Commit subjects.  Keep validation results
and any platform assumptions in change descriptions.  Preserve unrelated
working-tree changes.

When direct network access fails, retry through the local HTTP/HTTPS proxy at
`http://127.0.0.1:10808`; use it as a fallback rather than forcing all traffic
through it.
