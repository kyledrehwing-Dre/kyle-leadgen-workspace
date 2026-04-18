#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

SPEC_VERSION="leadgen-canonical-v3"
errors=0

tmp_reject="${TMPDIR:-/tmp}/leadgen_validator_reject.$$"
trap 'rm -f "$tmp_reject"' EXIT

required_files=(
  "AGENTS.md"
  "HEARTBEAT.md"
  "USER.md"
  "SOUL.md"
  "TOOLS.md"
  "skills/linkedin_zoominfo_sop/SKILL.md"
  "skills/zoominfo_batch_enrichment_sop/SKILL.md"
  "scripts/validate_linkedin_zoominfo_sop.sh"
)

live_files=(
  "AGENTS.md"
  "HEARTBEAT.md"
  "USER.md"
  "SOUL.md"
  "TOOLS.md"
  "skills/linkedin_zoominfo_sop/SKILL.md"
  "skills/zoominfo_batch_enrichment_sop/SKILL.md"
)

term_files=(
  "AGENTS.md"
  "HEARTBEAT.md"
  "USER.md"
  "skills/linkedin_zoominfo_sop/SKILL.md"
  "skills/zoominfo_batch_enrichment_sop/SKILL.md"
)

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
  # Use regex match to accept pattern variants (old exact vs new HARD STOP wording)
  if grep -Eq -- "$needle" "$file" 2>/dev/null; then
    pass "$label"
  else
    fail "$label"
  fi
}

require_regex() {
  local file="$1"
  local pattern="$2"
  local label="$3"
  if grep -Eq -- "$pattern" "$file"; then
    pass "$label"
  else
    fail "$label"
  fi
}

reject_regex_in_live_files() {
  local pattern="$1"
  local label="$2"
  if grep -Ein -- "$pattern" "${live_files[@]}" >"$tmp_reject" 2>/dev/null; then
    echo "REJECT MATCHES for $label:" >&2
    cat "$tmp_reject" >&2
    fail "$label"
  else
    pass "$label"
  fi
  : >"$tmp_reject"
}

CANONICAL_TERMS=$'1. IT operations
2. SRE
3. Cloud Operations
4. DevOps
5. Infrastructure
6. Enterprise Architecture
7. Application Support
8. Production Support
9. Observability
10. Site Reliability Engineer
11. Change Management
12. Incident management
13. AI'
BROWSER_RULE="Browser session rule: try to attach to Kyle's existing logged-in Chrome session if available; otherwise spawn a dedicated agent-owned browser session/profile. Once a session is verified for the run, use that same verified session consistently for the run. Do not assume a profile name without verification."
TAB_RULE=$'Only operate these tabs: `Daily Targets` and `Updated Format`.'
DEDUPE_RULE=$'Dedupe key = LinkedIn URL.'
ROW_RULE=$'Locate writeback rows by LinkedIn URL first, then verify Company Name + Full Name.'
ROW_NUMBER_RULE=$'Never write ZoomInfo data by row number alone.'
FALSE_ZERO_RULE=$'False zero != no people.'
AMBIGUITY_RULE=$'Company ambiguity is a blocker.'
ZOOMINFO_PRIMARY=$'Advanced Search -> Clear All -> Full Name -> Company -> widen confidence to All contacts / 50-100 before declaring Not Found.'
ZOOMINFO_FALLBACK=$'Fallback: company page -> Employees -> Information Technology department.'
OPTIONAL_ACCELERATOR=$'Optional accelerator: batch export or bulk enrichment is allowed only when exact row mapping is proven by LinkedIn URL first, then Company Name + Full Name.'
CONTINUE_RULE=$'Never ask the user for permission to continue while valid work remains.'
PHASE2_RULE=$'Phase 2 remains incomplete while any current-run row has `K=Pending` and no real blocker exists.'
POST_VERIFY_RULE=$'Post-write verification: re-locate the row by LinkedIn URL and confirm written values match.'

for file in "${required_files[@]}"; do
  require_file "$file"
done

for file in "${live_files[@]}"; do
  require_fixed "$file" "SPEC_VERSION: ${SPEC_VERSION}" "$file carries ${SPEC_VERSION}"
done

require_regex "skills/linkedin_zoominfo_sop/SKILL.md" '^name:[[:space:]]*linkedin_zoominfo_sop[[:space:]]*$' "primary skill frontmatter name is correct"
require_regex "skills/linkedin_zoominfo_sop/SKILL.md" '^description:[[:space:]]*.+$' "primary skill frontmatter description exists"
require_regex "skills/zoominfo_batch_enrichment_sop/SKILL.md" '^name:[[:space:]]*zoominfo_batch_enrichment_sop[[:space:]]*$' "phase 2 skill frontmatter name is correct"
require_regex "skills/zoominfo_batch_enrichment_sop/SKILL.md" '^description:[[:space:]]*.+$' "phase 2 skill frontmatter description exists"

for file in "${term_files[@]}"; do
  require_fixed "$file" "$CANONICAL_TERMS" "$file contains the exact canonical 13-term block"
done

for file in AGENTS.md HEARTBEAT.md USER.md SOUL.md TOOLS.md skills/linkedin_zoominfo_sop/SKILL.md skills/zoominfo_batch_enrichment_sop/SKILL.md; do
  require_fixed "$file" "$BROWSER_RULE" "$file agrees on browser-session rule"
done

EXISTING_SESSION_RULE=$'existing logged-in Chrome session if available'
DEDICATED_SESSION_RULE=$'dedicated agent-owned browser session/profile'
SAME_SESSION_RULE=$'use that same verified session consistently for the run'
NO_ASSUME_RULE=$'Do not assume a profile name without verification.'

for file in AGENTS.md HEARTBEAT.md USER.md SOUL.md TOOLS.md skills/linkedin_zoominfo_sop/SKILL.md skills/zoominfo_batch_enrichment_sop/SKILL.md; do
  require_fixed "$file" "$EXISTING_SESSION_RULE" "$file requires existing-session attach when available"
  require_fixed "$file" "$DEDICATED_SESSION_RULE" "$file defines dedicated agent-owned browser fallback"
  require_fixed "$file" "$SAME_SESSION_RULE" "$file requires same verified session for the run"
  require_fixed "$file" "$NO_ASSUME_RULE" "$file forbids profile-name assumptions without verification"
done

for file in AGENTS.md HEARTBEAT.md USER.md TOOLS.md skills/linkedin_zoominfo_sop/SKILL.md skills/zoominfo_batch_enrichment_sop/SKILL.md; do
  require_fixed "$file" "$TAB_RULE" "$file enforces strict tab control"
  require_fixed "$file" "Locate.*writeback.*rows.*by.*LinkedIn.*URL" "$file enforces LinkedIn URL-first row identity"
  require_fixed "$file" "$ROW_NUMBER_RULE" "$file forbids row-number-only ZoomInfo writes"
  require_fixed "$file" "$POST_VERIFY_RULE" "$file requires post-write verification"
done

for file in AGENTS.md HEARTBEAT.md USER.md SOUL.md TOOLS.md skills/linkedin_zoominfo_sop/SKILL.md; do
  require_fixed "$file" "$FALSE_ZERO_RULE" "$file defines the LinkedIn false-zero rule"
  require_fixed "$file" "$AMBIGUITY_RULE" "$file defines company ambiguity as a blocker"
  require_fixed "$file" "$CONTINUE_RULE" "$file enforces autonomous continuation"
  require_fixed "$file" "$PHASE2_RULE" "$file enforces Phase 2 persistence"
done

for file in AGENTS.md HEARTBEAT.md USER.md TOOLS.md skills/linkedin_zoominfo_sop/SKILL.md skills/zoominfo_batch_enrichment_sop/SKILL.md; do
  require_fixed "$file" "$ZOOMINFO_PRIMARY" "$file defines ZoomInfo primary search order"
  require_fixed "$file" "Fallback.*company.*page.*Employees.*Information Technology department" "$file defines ZoomInfo company IT fallback"
  require_fixed "$file" "Optional accelerator.*batch export.*bulk enrichment" "$file defines batch/export as optional accelerator"
done

for file in AGENTS.md USER.md TOOLS.md skills/linkedin_zoominfo_sop/SKILL.md skills/zoominfo_batch_enrichment_sop/SKILL.md; do
  require_fixed "$file" "$DEDUPE_RULE" "$file defines LinkedIn URL as dedupe key"
done

for file in AGENTS.md HEARTBEAT.md skills/linkedin_zoominfo_sop/SKILL.md skills/zoominfo_batch_enrichment_sop/SKILL.md; do
  require_fixed "$file" '### `Daily Targets` column C allowed values' "$file defines Daily Targets status heading"
  require_fixed "$file" '### `Updated Format` column J allowed values' "$file defines LinkedIn status heading"
  require_fixed "$file" '### `Updated Format` column K allowed values' "$file defines ZoomInfo status heading"
  require_fixed "$file" '- Pending' "$file includes Pending status"
  require_fixed "$file" '- In Progress' "$file includes In Progress status"
  require_fixed "$file" '- Completed' "$file includes Completed status"
  require_fixed "$file" '- Blocked' "$file includes Blocked status"
  require_fixed "$file" '- Skipped' "$file includes Skipped status"
  require_fixed "$file" '- Added' "$file includes Added status"
  require_fixed "$file" '- Duplicate-Skipped' "$file includes Duplicate-Skipped status"
  require_fixed "$file" '- Enriched' "$file includes Enriched status"
  require_fixed "$file" '- Not Found' "$file includes Not Found status"
done

require_fixed "AGENTS.md" 'After each company, emit an execution ledger with evidence:' "AGENTS requires evidence-based execution ledger"
require_fixed "skills/linkedin_zoominfo_sop/SKILL.md" 'After each company, emit an execution ledger with evidence:' "primary skill requires evidence-based execution ledger"

reject_regex_in_live_files 'all 10 approved terms' 'no stale all-10-approved-terms wording remains'
reject_regex_in_live_files 'all 10 terms' 'no stale all-10-terms wording remains'
reject_regex_in_live_files 'all 11 terms' 'no stale all-11-terms wording remains'
reject_regex_in_live_files '11-term' 'no stale 11-term wording remains'
reject_regex_in_live_files '/ 11' 'no stale slash-11 progress wording remains'
reject_regex_in_live_files 'Site Reliability Engineer \(SRE\)' 'no stale combined SRE term wording remains'
reject_regex_in_live_files 'profile="user"' 'no hardcoded profile="user" remains'
reject_regex_in_live_files 'profile="chrome"' 'no hardcoded profile="chrome" remains'
reject_regex_in_live_files '[Ss]hould I continue|[Ss]hould i continue' 'no stale permission-to-continue wording remains'
reject_regex_in_live_files '[Ww]ould you like me to keep going' 'no stale keep-going wording remains'
reject_regex_in_live_files '[Dd]o you want me to proceed' 'no stale proceed wording remains'

if [[ "$errors" -eq 0 ]]; then
  echo "OK: leadgen canonical validation passed (${SPEC_VERSION})."
else
  echo "Validation failed with $errors issue(s)." >&2
  exit 1
fi
