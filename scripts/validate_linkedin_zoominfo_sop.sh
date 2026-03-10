#!/usr/bin/env bash
set -euo pipefail

skill_file="skills/linkedin_zoominfo_sop/SKILL.md"

if [[ -f "$skill_file" ]] \
  && grep -Eq '^name:[[:space:]]*linkedin_zoominfo_sop[[:space:]]*$' "$skill_file" \
  && grep -Eq '^description:[[:space:]]*.+$' "$skill_file"; then
  echo "OK: linkedin_zoominfo_sop skill is present with valid frontmatter."
else
  echo "FAIL: linkedin_zoominfo_sop skill missing or frontmatter invalid." >&2
  exit 1
fi
