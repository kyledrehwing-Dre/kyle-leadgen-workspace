---
name: zoominfo_batch_enrichment_sop
description: Deterministic Phase 2 ZoomInfo enrichment accelerator for current-run Google Sheets rows, using Advanced Search, company IT-department fallback, and optional export-backed matching without row-number writes or guessing. Use only after the primary linkedin_zoominfo_sop validation passes and when company-level browsing or batch acceleration can preserve exact row identity.
---

# ZoomInfo Batch Enrichment SOP (Phase 2 Accelerator)
SPEC_VERSION: leadgen-canonical-v3

## Scope
This skill accelerates Phase 2 only.
It does not replace the primary workflow.
It may speed up enrichment, but it may never weaken row identity, status rules, or completion rules.

## Browser session rule
Browser session rule: use the profile that verifiably attaches to Kyle's already logged-in Chrome session; do not assume a profile name.

## Inherited company-complete rule
Do not mark a company complete until the primary workflow has attempted the canonical 13-term search universe:
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

## Phase 2 invariants
Only operate these tabs: `Daily Targets` and `Updated Format`.
Dedupe key = LinkedIn URL.
Locate writeback rows by LinkedIn URL first, then verify Company Name + Full Name.
Never write ZoomInfo data by row number alone.
Never assume end-of-sheet is empty.
Verify destination row/range before append/update.
Never overwrite verified data with weaker data.
Never delete data.
Post-write verification: re-locate the row by LinkedIn URL and confirm written values match.
Never ask the user for permission to continue while valid work remains.
Phase 2 remains incomplete while any current-run row has `K=Pending` and no real blocker exists.

## Explicit status values
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

## Search order
1. Advanced Search -> Clear All -> Full Name -> Company -> widen confidence to All contacts / 50-100 before declaring Not Found.
2. Fallback: company page -> Employees -> Information Technology department.
3. Optional accelerator: batch export or bulk enrichment is allowed only when exact row mapping is proven by LinkedIn URL first, then Company Name + Full Name.

## Recommended execution pattern
1. Run `bash scripts/validate_linkedin_zoominfo_sop.sh` first.
2. Default scope = current-run rows where `M=RUN_ID` and `K=Pending`.
3. For each row, locate it by LinkedIn URL first, then verify Company Name + Full Name.
4. Try Advanced Search first.
5. If Advanced Search misses a contact that should still be in scope, use company page -> Employees -> Information Technology department.
6. If export/bulk is available, use it only when every exported record can be mapped back deterministically before writeback.
7. If a match is ambiguous, do not guess. Mark `K=Blocked`, note the ambiguity, and report it.
8. If no confident match exists after primary search and fallback, mark `K=Not Found`.
9. After every write, run post-write verification.

## Reporting
For each company or batch slice, report:
- company
- run_id
- browser profile/session used
- rows considered
- rows enriched
- rows marked `Not Found`
- rows marked `Blocked`
- export/batch method used or not used
- exact next action or exact stop reason
