# Stow each skill directory into the shared agent skills directory.
.DEFAULT_GOAL := help
.PHONY: help list dry-run bootstrap stow restow unstow verify _check-stow

STOW ?= stow
REPO_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
DEPLOY_HOME ?= $(HOME)
TARGET ?= $(DEPLOY_HOME)/.agents/skills
STOW_BASE = $(STOW) --dir="$(REPO_DIR)" --ignore='[.]elc$$' --ignore='[.]pyc$$' --ignore='__pycache__'

help:
	@echo "Targets: list dry-run bootstrap stow restow unstow verify"
	@echo "Target directory: $(TARGET)"
	@echo "Preview with make dry-run, then deploy with make restow."

list:
	@for skill in "$(REPO_DIR)"/skills/*; do \
		test ! -f "$$skill/SKILL.md" || basename "$$skill"; \
	done

dry-run: _check-stow
	@if [ -d "$(TARGET)" ]; then \
		$(STOW_BASE) --target="$(TARGET)" --simulate --verbose=2 skills; \
	elif [ -e "$(TARGET)" ] || [ -L "$(TARGET)" ]; then \
		echo "Target is not a directory: $(TARGET)" >&2; exit 1; \
	else \
		tmp=$$(mktemp -d); trap 'rm -rf "$$tmp"' EXIT HUP INT TERM; \
		echo "Would create $(TARGET); previewing links in $$tmp"; \
		$(STOW_BASE) --target="$$tmp" --simulate --verbose=2 skills; \
	fi

bootstrap: stow

stow: _check-stow
	@mkdir -p "$(TARGET)"
	@$(STOW_BASE) --target="$(TARGET)" --simulate skills
	@$(STOW_BASE) --target="$(TARGET)" skills

restow: _check-stow
	@mkdir -p "$(TARGET)"
	@$(STOW_BASE) --target="$(TARGET)" --restow --simulate skills
	@$(STOW_BASE) --target="$(TARGET)" --restow skills

unstow: _check-stow
	@if [ -d "$(TARGET)" ]; then \
		$(STOW_BASE) --target="$(TARGET)" --delete skills; \
	fi

verify: _check-stow
	@set -eu; tmp=$$(mktemp -d); trap 'rm -rf "$$tmp"' EXIT HUP INT TERM; \
	target="$$tmp/.agents/skills"; \
	mkdir -p "$$target/external-skill"; \
	printf '%s\n' 'external skill data' > "$$target/external-skill/SKILL.md"; \
	$(MAKE) --no-print-directory dry-run TARGET="$$target"; \
	test ! -L "$$target/emacs"; \
	$(MAKE) --no-print-directory stow TARGET="$$target"; \
	$(MAKE) --no-print-directory restow TARGET="$$target"; \
	for source in "$(REPO_DIR)"/skills/*; do \
		name=$${source##*/}; \
		test -L "$$target/$$name"; \
		cmp "$$source/SKILL.md" "$$target/$$name/SKILL.md"; \
	done; \
	$(MAKE) --no-print-directory unstow TARGET="$$target"; \
	test "$$(cat "$$target/external-skill/SKILL.md")" = 'external skill data'; \
	if find "$$target" -type l -print -quit | grep -q .; then \
		echo "Unstow left managed links behind" >&2; exit 1; \
	fi; \
	mkdir -p "$$target/emacs"; \
	printf '%s\n' 'existing local skill' > "$$target/emacs/SKILL.md"; \
	if $(MAKE) --no-print-directory dry-run TARGET="$$target" > "$$tmp/conflict.log" 2>&1; then \
		echo "Expected a conflict with an existing local skill" >&2; exit 1; \
	fi; \
	test "$$(cat "$$target/emacs/SKILL.md")" = 'existing local skill'; \
	echo "Verified stow/restow/unstow, external skill preservation, and conflict detection"

_check-stow:
	@command -v "$(STOW)" >/dev/null 2>&1 || { \
		echo "GNU Stow is required. Install it with your system package manager." >&2; \
		exit 2; \
	}
