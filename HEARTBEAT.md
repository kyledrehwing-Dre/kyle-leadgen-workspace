# HEARTBEAT.md
SPEC_VERSION: leadgen-canonical-v3

## Daily Lead Gen Checklist
1. Run `bash scripts/validate_linkedin_zoominfo_sop.sh` before any live browser or Google Sheets work.
2. If validation fails, stop and alert with the exact blocker or drift finding.
3. Check `Daily Targets` for eligible companies or resume any company already marked `In Progress`.
4. Execute the canonical workflow below company by company.
5. If nothing needs attention, reply `HEARTBEAT_OK`.

## Canonical browser-session rule
Browser session rule: try to attach to Kyle's existing logged-in Chrome session if available; otherwise spawn a dedicated agent-owned browser session/profile. Once a session is verified for the run, use that same verified session consistently for the run. Do not assume a profile name without verification.

## Canonical 13-term search universe
1. IT operations
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
13. AI

10 contacts is NOT completion.

## Separate jobs
### Job 1 — LinkedIn capture
- discovery only
- allowed systems: LinkedIn + Google Sheets
- output: rows written/refreshed with `K=Pending`
- stop Job 1 after handoff to the sheet; do not do ZoomInfo enrichment inside Job 1

### Job 2 — ZoomInfo enrichment
- enrichment only
- allowed systems: ZoomInfo + Google Sheets
- input: existing sheet rows, preferably `K=Pending`
- do not use LinkedIn for discovery inside Job 2
- do not append brand-new people during Job 2

## Company loop
Only operate these tabs: `Daily Targets` and `Updated Format`.
False zero != no people.
Company ambiguity is a blocker.
Never ask the user for permission to continue while valid work remains.

For each eligible company when running Job 1:
- Set `Daily Targets` column C to `In Progress`, then write RUN_ID and timestamp.
- Preferred: verified LinkedIn / Sales Navigator path if session and filters work.
- Fallback A: standard LinkedIn company people path with verified company context.
- Fallback B: company-page / associated-members browsing when people-search returns false zero or is anti-automation blocked.
- Always verify company context before every search.
- Always open the full profile for every kept contact.
- Attempt all 13 canonical terms in order unless a real blocker stops execution.
- For each term, stop only when one is true:
  - 2 consecutive pages produce 0 new unique LinkedIn URLs
  - OR 10 pages checked
  - OR explicit no-results
- Dedupe against `Updated Format` column F before any append.
- Verify destination row/range before append/update.
- Never overwrite verified data with weaker data.
- Post-write verification: re-locate the row by LinkedIn URL and confirm written values match.

## ZoomInfo loop
For each targeted row when running Job 2:
1. Start from the sheet row only; do not use LinkedIn discovery here.
2. Advanced Search -> Clear All -> Full Name -> Company -> widen confidence to All contacts / 50-100 before declaring Not Found.
3. If the first search misses, run the required name-variant ladder before declaring `Not Found`:
   - exact full name + company
   - nickname/full-first-name swap
   - without middle initial
   - with middle initial / punctuation variant
4. Fallback: company page -> Employees -> Information Technology department.
5. If a confident match exists, write `K=Enriched`, `H=(B) or No Email`, and `I=(M) or No Phone`.
6. If no confident match exists after the full ladder + fallback, write `K=Not Found`, `H=Not Found`, and `I=Not Found`.
7. Never use HQ `(HQ)` or direct `(D)` phone in place of mobile `(M)` for column `I`.
8. Optional accelerator: batch export or bulk enrichment is allowed only when exact row mapping is proven by LinkedIn URL first, then Company Name + Full Name.

Locate writeback rows by LinkedIn URL first, then verify Company Name + Full Name.
Never write ZoomInfo data by row number alone.
Phase 2 remains incomplete while any targeted row has `K=Pending` and no real blocker exists.

## Status invariants
### `Daily Targets` column C allowed values
- Pending
- In Progress
- Completed
- Blocked
- Skipped

### `Updated Format` column J allowed values
- Added
- Duplicate-Skipped
- Blocked

### `Updated Format` column K allowed values
- Pending
- Enriched
- Not Found
- Blocked

## Completion audit
A company is complete only when all are true:
- all 13 canonical terms were attempted unless a real blocker stopped execution
- each term reached its stop rule
- dedupe against column F was applied
- all new valid contacts were written safely
- all current-run `K=Pending` rows were resolved to `Enriched` or `Not Found`
- `Daily Targets` was updated correctly
- a memory summary was written

## If blocked
- Stop and explain the exact blocker.
- Set `Daily Targets` to `Blocked` with RUN_ID, timestamp, and notes.
- Do not mark `Completed` prematurely.

## Otherwise
- Emit an execution ledger with evidence after each company.
- If all eligible work is complete, finish normally.
- If there is no eligible work, reply `HEARTBEAT_OK`.
