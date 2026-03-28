# HEARTBEAT.md
SPEC_VERSION: leadgen-canonical-v3

## Daily Lead Gen Checklist
1. Run `bash scripts/validate_linkedin_zoominfo_sop.sh` before any live browser or Google Sheets work.
2. If validation fails, stop and alert with the exact blocker or drift finding.
3. Check `Daily Targets` for eligible companies or resume any company already marked `In Progress`.
4. Execute the canonical workflow below company by company.
5. If nothing needs attention, reply `HEARTBEAT_OK`.

## Canonical browser-session rule
Browser session rule: use the profile that verifiably attaches to Kyle's already logged-in Chrome session; do not assume a profile name.

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

## Company loop
Only operate these tabs: `Daily Targets` and `Updated Format`.
False zero != no people.
Company ambiguity is a blocker.
Never ask the user for permission to continue while valid work remains.

For each eligible company:
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
1. Advanced Search -> Clear All -> Full Name -> Company -> widen confidence to All contacts / 50-100 before declaring Not Found.
2. Fallback: company page -> Employees -> Information Technology department.
3. Optional accelerator: batch export or bulk enrichment is allowed only when exact row mapping is proven by LinkedIn URL first, then Company Name + Full Name.

Locate writeback rows by LinkedIn URL first, then verify Company Name + Full Name.
Never write ZoomInfo data by row number alone.
Phase 2 remains incomplete while any current-run row has `K=Pending` and no real blocker exists.

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
