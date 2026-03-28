# AGENTS.md - Pipeline Definition
SPEC_VERSION: leadgen-canonical-v3

## Core Pipeline
Validate -> Verify browser/session -> Select eligible targets -> Phase 1 LinkedIn capture -> Phase 2 ZoomInfo enrichment -> Safe Google Sheets upsert -> Memory log -> Resume

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

## LinkedIn collection order
1. Preferred: verified LinkedIn / Sales Navigator path if session and filters work.
2. Fallback A: standard LinkedIn company people path with verified company context.
3. Fallback B: company-page / associated-members browsing when people-search returns false zero or is anti-automation blocked.

False zero != no people.
Company ambiguity is a blocker.
Always verify company context before every search.
Always open the full profile for every kept contact.
Do not switch methods silently; log the exact reason when falling back.

## ZoomInfo enrichment order
1. Advanced Search -> Clear All -> Full Name -> Company -> widen confidence to All contacts / 50-100 before declaring Not Found.
2. Fallback: company page -> Employees -> Information Technology department.
3. Optional accelerator: batch export or bulk enrichment is allowed only when exact row mapping is proven by LinkedIn URL first, then Company Name + Full Name.

Batch convenience must never weaken row-identity rules.

## Sheets invariants
Only operate these tabs: `Daily Targets` and `Updated Format`.
Datastore = Google Sheets only.
Dedupe key = LinkedIn URL.
Locate writeback rows by LinkedIn URL first, then verify Company Name + Full Name.
Never write ZoomInfo data by row number alone.
Never assume end-of-sheet is empty.
Verify destination row/range before append/update.
Never overwrite verified data with weaker data.
Never delete data.
Post-write verification: re-locate the row by LinkedIn URL and confirm written values match.

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

## Phase 1 - LinkedIn capture
For each eligible company:
1. Run `bash scripts/validate_linkedin_zoominfo_sop.sh` before any browser or sheet action.
2. Set `RUN_ID=YYYYMMDD-HHMMSS`.
3. Set `Daily Targets` status to `In Progress` with RUN_ID and timestamp.
4. Attempt all 13 canonical terms in order unless a real blocker stops execution.
5. For each term, stop only when one is true:
   - 2 consecutive pages produce 0 new unique LinkedIn URLs
   - OR 10 pages checked
   - OR explicit no-results
6. Dedupe against `Updated Format` column F before any append.
7. Safe-append new contacts only after verifying the destination range is truly empty.
8. If a LinkedIn URL already exists, update only missing/weaker fields and do not append a duplicate row.
9. Write `J=Added` or `J=Duplicate-Skipped`, `K=Pending`, timestamp, RUN_ID, and notes as needed.
10. If company scope/entity is ambiguous, mark `Blocked` and stop that company instead of spraying across the wrong org.

## Phase 2 - ZoomInfo enrichment
For current-run rows where `M=RUN_ID` and `K=Pending`:
1. Locate the row by LinkedIn URL first, then verify Company Name + Full Name.
2. Run the ZoomInfo order above without guessing.
3. If no confident match after Advanced Search and the company IT-department fallback, mark `K=Not Found`.
4. If a confident match lacks one field, write `No email` or `No phone` as appropriate.
5. If no confident match exists, write `Not Found` values consistently and verify the write.
6. Keep going until every current-run `K=Pending` row is resolved or a real blocker stops execution.

Phase 2 remains incomplete while any current-run row has `K=Pending` and no real blocker exists.

## Completion invariants
A company is complete only when all are true:
- all 13 canonical terms were attempted unless a real blocker stopped execution
- each term reached its stop rule
- dedupe against column F was applied
- all new valid contacts were written safely
- all current-run `K=Pending` rows were resolved to `Enriched` or `Not Found`
- `Daily Targets` was updated correctly
- a memory summary was written

## Continuation invariant
Never ask the user for permission to continue while valid work remains.
If unrun terms remain, paging is incomplete, or current-run `K=Pending` remains, continue autonomously.

## Reporting invariant
After each company, emit an execution ledger with evidence:
- company
- run_id
- profile/session used
- terms attempted
- pages checked by term
- new URLs found by term
- duplicates skipped
- rows touched
- ZoomInfo enriched count
- Not Found count
- blocker/anomaly list
- exact next action or exact stop reason

## Workflow routing
When a task involves LinkedIn -> Google Sheets -> ZoomInfo, always load and follow the `linkedin_zoominfo_sop` skill.
When Phase 2 uses company-level browsing or export-backed acceleration, also follow `zoominfo_batch_enrichment_sop`.
Do not improvise or switch methods mid-run.
If switching between the preferred LinkedIn path and a fallback, log why.

## Target Persona Context (Evolven)
- Ideal persona: IT executives and senior operators in risk, security, audit, SRE, DevOps, infrastructure, architecture, support, observability, and AI-adjacent operations roles
- Pain point: 90%+ of outages, incidents, and breaches trace back to config change or misconfiguration risk
- Value prop: Evolven collects every configuration in the IT estate and reports every change
