# AGENTS.md - Pipeline Definition
SPEC_VERSION: leadgen-canonical-v3

## Core Pipeline
Validate -> Verify browser/session -> Select eligible targets -> Job 1 LinkedIn capture -> Handoff rows with `K=Pending` -> Job 2 ZoomInfo enrichment -> Memory log -> Resume

## Two-job operating model
### Job 1 — LinkedIn capture
Purpose: discover contacts and write base rows into Google Sheets.
- Inputs: eligible companies from `Daily Targets`
- Systems allowed: LinkedIn + Google Sheets
- Outputs: rows in `Updated Format` with profile fields populated and `K=Pending`
- Must do: discovery, company-context verification, dedupe, append/update, post-write verification
- Must NOT do: ZoomInfo lookup, email/phone enrichment, final `H/I` resolution
- Exit condition: all valid discovered contacts are written and handed off as `K=Pending`

### Job 2 — ZoomInfo enrichment
Purpose: enrich existing sheet rows only.
- Inputs: existing rows in `Updated Format`
- Systems allowed: ZoomInfo + Google Sheets
- Outputs: `H`, `I`, `K`, `L`, and `N` resolved from ZoomInfo evidence
- Must do: search by sheet identity, run the ZoomInfo search ladder, write enrichment results, post-write verification
- Must NOT do: LinkedIn people discovery, append brand-new contacts from browsing, change row identity rules
- Exit condition: every targeted row is resolved to `K=Enriched` or `K=Not Found`

## Job handoff rule
- Job 1 creates or refreshes rows and leaves them at `K=Pending`.
- Job 2 starts from existing sheet rows and never depends on LinkedIn search for discovery.
- If a person is missing from the sheet, that is Job 1 work.
- If a person is already in the sheet and needs `H/I/K` resolution, that is Job 2 work.

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
2. If the first search misses, run the required name-variant ladder before declaring `Not Found`:
   - exact full name + company
   - nickname/full-first-name swap (for example `Doug` <-> `Douglas`)
   - without middle initial
   - with middle initial / punctuation variant
3. Fallback: company page -> Employees -> Information Technology department.
4. Optional accelerator: batch export or bulk enrichment is allowed only when exact row mapping is proven by LinkedIn URL first, then Company Name + Full Name.

Batch convenience must never weaken row-identity rules.

## ZoomInfo write rules
- If a confident ZoomInfo contact match exists:
  - set `K=Enriched`
  - write column `H` from business email `(B)` or exactly `No Email`
  - write column `I` from mobile `(M)` or exactly `No Phone`
- If no confident ZoomInfo contact match exists after the full search ladder and fallback:
  - set `K=Not Found`
  - write column `H` exactly `Not Found`
  - write column `I` exactly `Not Found`
- Never use HQ `(HQ)` or direct `(D)` phone as a substitute for mobile `(M)` in column `I`.
- Before writing `Not Found`, open any obvious ZoomInfo candidate that matches full name + company context. Do not declare `Not Found` while an obvious unopened candidate remains in results.

### ZoomInfo Contact Profile extraction — mobile-first verification
ZoomInfo innerText returns phone/email values on one line and their `(B)`, `(M)`, `(D)`, `(HQ)` labels on the next line. The `\n` IS present between the value and label.

**ZoomInfo phone section format (verbatim from browser):**
```
Phone numbers
(646) 447-6646
(D)
Call
(646) 447-5000
(HQ)
Call
(347) 504-5895
(M)
Call
```

**Mandatory mobile logic:** simply find the exact `(M)` in the Phone numbers block.

```javascript
const phoneSection = (txt.match(/Phone numbers[\s\S]{0,800}/i) || [''])[0];
const lines = phoneSection.split('\n').map(s => s.trim()).filter(Boolean);
let mobile = null;
for (let i = 0; i < lines.length; i++) {
  if (lines[i] === '(M)') {
    mobile = lines[i - 1] || null;
    break;
  }
}
```

Rules:
- Find the exact `(M)` line.
- Use the line immediately above `(M)` for column `I`.
- If there is no exact `(M)` anywhere in the full Phone numbers block, then write `No Phone`.
- Never use `(D)` or `(HQ)` as substitutes.

**Business Email (B):**
```javascript
txt.match(/([A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,})\s*\n\(B\)/i)
```

**Rejection rule:** If ZoomInfo returns a contact whose name does not match the sheet Full Name (ignoring middle initials and nicknames), reject the match entirely. Mark `K=Not Found` instead.

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
11. Stop Job 1 after the sheet handoff is complete. Do not perform ZoomInfo enrichment inside Job 1.

## Phase 2 - ZoomInfo enrichment
For current-run rows where `M=RUN_ID` and `K=Pending`:
1. Start from existing sheet rows only. Do not use LinkedIn for discovery in Job 2.
2. Locate the row by LinkedIn URL first, then verify Company Name + Full Name.
3. Run the ZoomInfo order above without guessing.
4. If the first ZoomInfo search misses, complete the full name-variant ladder before treating the row as a miss.
5. If a confident match exists, set `K=Enriched` and write:
   - `H=<business email (B)>` or exactly `No Email`
   - `I=<mobile (M)>` or exactly `No Phone`
6. If no confident match exists after the full search ladder and the company IT-department fallback, set:
   - `K=Not Found`
   - `H=Not Found`
   - `I=Not Found`
7. Before finalizing a company, recheck every provisional `Not Found` row once with broader name variants.
8. Never append a brand-new person during Job 2. Missing people belong to Job 1.
9. Keep going until every targeted `K=Pending` row is resolved or a real blocker stops execution.

Phase 2 remains incomplete while any current-run row has `K=Pending` and no real blocker exists.
Phase 2 remains incomplete while any targeted row has `K=Pending` and no real blocker exists.

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
