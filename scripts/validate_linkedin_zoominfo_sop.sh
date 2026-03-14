#!/usr/bin/env bash
set -euo pipefail

skill_file="skills/linkedin_zoominfo_sop/SKILL.md"
agents_file="AGENTS.md"
user_file="USER.md"
errors=0

pass() {
  echo "PASS: $1"
}

fail() {
  echo "FAIL: $1" >&2
  errors=$((errors + 1))
}

require_file() {
  local file="$1"
  if [[ -f "$file" ]]; then
    pass "file exists: $file"
  else
    fail "missing file: $file"
  fi
}

require_fixed() {
  local file="$1"
  local needle="$2"
  local label="$3"
  if grep -Fq "$needle" "$file"; then
    pass "$label"
  else
    fail "$label"
  fi
}

require_regex() {
  local file="$1"
  local pattern="$2"
  local label="$3"
  if grep -Eq "$pattern" "$file"; then
    pass "$label"
  else
    fail "$label"
  fi
}

require_file "$skill_file"
require_file "$agents_file"
require_file "$user_file"

if [[ -f "$skill_file" ]]; then
  require_regex "$skill_file" '^name:[[:space:]]*linkedin_zoominfo_sop[[:space:]]*$' "skill name frontmatter is correct"
  require_regex "$skill_file" '^description:[[:space:]]*.+$' "skill description frontmatter exists"

  require_fixed "$skill_file" "Only operate these tabs in this workflow:" "skill enforces strict tab control"
  require_fixed "$skill_file" 'Allowed values for `Daily Targets` column C (Target Status):' "skill defines Daily Targets explicit statuses"
  require_fixed "$skill_file" 'Allowed values for `Updated Format` column J (LinkedIn Phase Status):' "skill defines LinkedIn phase status column"
  require_fixed "$skill_file" 'Allowed values for `Updated Format` column K (ZoomInfo Phase Status):' "skill defines ZoomInfo phase status column"
  require_fixed "$skill_file" "Canonical LinkedIn search path" "skill defines canonical LinkedIn search path"
  require_fixed "$skill_file" "Current company = <target company>" "skill requires company filter on LinkedIn"
  require_fixed "$skill_file" "Never write ZoomInfo data by row number alone." "skill forbids row-number-only ZoomInfo writes"
  require_fixed "$skill_file" "The row must be identified by LinkedIn profile URL in column F." "skill enforces LinkedIn URL row identity"
  require_fixed "$skill_file" "2 consecutive pages produce 0 new unique LinkedIn URLs" "skill enforces deterministic paging stop rule"
  require_fixed "$skill_file" "3 consecutive execution errors occur" "skill defines hard error stop rule"
  require_fixed "$skill_file" "10 CONTACTS IS NOT COMPLETION" "skill includes exhaustive coverage patch"
  require_fixed "$skill_file" "THIS SOP MUST BE EXECUTED AS A LOOP" "skill enforces loop execution"
  require_fixed "$skill_file" "MANDATORY TERM-BY-TERM COMPLETION" "skill enforces all 13 terms"
  require_fixed "$skill_file" "PHASE 2 PERSISTENCE RULE" "skill enforces Phase 2 persistence"
  require_fixed "$skill_file" "AUTONOMOUS CONTINUATION RULE" "skill enforces autonomous continuation"
fi

if [[ -f "$agents_file" ]]; then
  require_fixed "$agents_file" 'always load and follow the `linkedin_zoominfo_sop` skill' "AGENTS routes LinkedIn/ZoomInfo tasks to skill"
  require_fixed "$agents_file" 'bash scripts/validate_linkedin_zoominfo_sop.sh' "AGENTS requires startup validation check"
  require_fixed "$agents_file" 'Status columns are mandatory:' "AGENTS enforces explicit status columns"
  require_fixed "$agents_file" 'Never write ZoomInfo data by row number alone.' "AGENTS forbids row-number-only ZoomInfo writes"
  require_fixed "$agents_file" 'Locate destination row by LinkedIn profile URL' "AGENTS enforces LinkedIn URL row lookup"
fi

if [[ -f "$user_file" ]]; then
  require_fixed "$user_file" '**Source Tab:** Daily Targets' "USER config points to Daily Targets source tab"
  require_fixed "$user_file" '**Destination Tab:** Updated Format' "USER config points to Updated Format destination tab"
  require_fixed "$user_file" 'Enterprise Architecture' "USER title list aligned to Enterprise Architecture"
fi

if [[ "$errors" -eq 0 ]]; then
  echo "OK: linkedin_zoominfo_sop setup validation passed."
else
  echo "Validation failed with $errors issue(s)." >&2
  exit 1
fi
