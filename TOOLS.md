# TOOLS.md - Tools & Methods
SPEC_VERSION: leadgen-canonical-v3

## Browser Automation
- **Tool:** `browser` (OpenClaw browser control)
- **Use for:** LinkedIn, Sales Navigator, ZoomInfo
Browser session rule: try to attach to Kyle's existing logged-in Chrome session if available; otherwise spawn a dedicated agent-owned browser session/profile. Once a session is verified for the run, use that same verified session consistently for the run. Do not assume a profile name without verification.
- **Verification sequence:** confirm the attached session is already logged into LinkedIn, then confirm ZoomInfo login, then record the actual profile/session used in the execution ledger.
- **Preferred LinkedIn path:** verified LinkedIn / Sales Navigator path if session and filters work.
- **Fallback A:** standard LinkedIn company people path with verified company context.
- **Fallback B:** company-page / associated-members browsing when people-search returns false zero or is anti-automation blocked.
- **Rule:** False zero != no people.
- **Rule:** Company ambiguity is a blocker.
- **Rule:** Always open the full profile for every kept contact.
- **Rule:** Do not switch methods silently; log the exact reason when falling back.

## Two separate jobs
### Job 1 — LinkedIn capture
- Systems allowed: LinkedIn + Google Sheets
- Goal: discover contacts and write/refresh sheet rows
- Output state: `K=Pending`
- Do not do ZoomInfo enrichment here

### Job 2 — ZoomInfo enrichment
- Systems allowed: ZoomInfo + Google Sheets
- Goal: enrich existing sheet rows only
- Input state: existing rows, preferably `K=Pending`
- Do not do LinkedIn discovery or append brand-new contacts here

## gog (Google Sheets)
- **Tool:** `exec` -> `gog` CLI
- **Auth:** Already configured for Kyle.Drehwing@gmail.com
- **Commands:**
  - `gog sheets metadata <id>` - verify tabs
  - `gog sheets get <id> "Range" --json` - read
  - `gog sheets update <id> "Range" --values-json '...'` - targeted write
  - `gog sheets append <id> "Range" --values-json '...'` - append after verification

## Sheet invariants
- Only operate these tabs: `Daily Targets` and `Updated Format`.
- Datastore = Google Sheets only.
- Dedupe key = LinkedIn URL.
- Locate writeback rows by LinkedIn URL first, then verify Company Name + Full Name.
- Never write ZoomInfo data by row number alone.
- Never assume end-of-sheet is empty.
- Verify destination row/range before append/update.
- Never overwrite verified data with weaker data.
- Never delete data.
- Post-write verification: re-locate the row by LinkedIn URL and confirm written values match.
Never ask the user for permission to continue while valid work remains.
Phase 2 remains incomplete while any current-run row has `K=Pending` and no real blocker exists.

## Status invariants
- `Daily Targets` column C: Pending | In Progress | Completed | Blocked | Skipped
- `Updated Format` column J: Added | Duplicate-Skipped | Blocked
- `Updated Format` column K: Pending | Enriched | Not Found | Blocked

## ZoomInfo method
- Primary: Advanced Search -> Clear All -> Full Name -> Company -> widen confidence to All contacts / 50-100 before declaring Not Found.
- Required search ladder before `Not Found`:
  - exact full name + company
  - nickname/full-first-name swap
  - without middle initial
  - with middle initial / punctuation variant
- Fallback: company page -> Employees -> Information Technology department.
- Write rule on confident match: `K=Enriched`, `H=(B) or No Email`, `I=(M) or No Phone`.
- Write rule on no confident match after ladder + fallback: `K=Not Found`, `H=Not Found`, `I=Not Found`.
- Never use HQ `(HQ)` or direct `(D)` phone in place of mobile `(M)` for column `I`.
- Optional accelerator: batch export or bulk enrichment is allowed only when exact row mapping is proven by LinkedIn URL first, then Company Name + Full Name.

## Memory
- **Tool:** write to `memory/YYYY-MM-DD.md`
- **Content:** run summaries, blockers, repair notes, exact next action or stop reason
