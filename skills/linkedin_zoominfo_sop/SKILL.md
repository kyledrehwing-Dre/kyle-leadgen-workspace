---
name: linkedin_zoominfo_sop
description: Deterministic LinkedIn -> Google Sheets -> ZoomInfo workflow for Kyle/Evolven with a canonical 13-term search universe, verified company context, false-zero fallbacks, exact row-identity rules, and Phase 2 persistence. Use when collecting LinkedIn leads, resuming a leadgen run, repairing shallow completion, or enriching current-run rows without guessing.
---

# LinkedIn -> Google Sheets -> ZoomInfo SOP
SPEC_VERSION: leadgen-canonical-v3

## Non-negotiables
- Never guess or fabricate data.
- Never switch methods silently; log the exact reason.
- Never write by row number alone.
- Never overwrite verified data with weaker data.
- Never delete data.
- Never ask the user for permission to continue while valid work remains.
- 10 contacts is NOT completion.

## Browser session rule
Browser session rule: try to attach to Kyle's existing logged-in Chrome session if available; otherwise spawn a dedicated agent-owned browser session/profile. Once a session is verified for the run, use that same verified session consistently for the run. Do not assume a profile name without verification.

## Scope and tabs
Only operate these tabs: `Daily Targets` and `Updated Format`.
Datastore = Google Sheets only.

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

## LinkedIn collection order
1. Preferred: verified LinkedIn / Sales Navigator path if session and filters work.
2. Fallback A: standard LinkedIn company people path with verified company context.
3. Fallback B: company-page / associated-members browsing when people-search returns false zero or is anti-automation blocked.

False zero != no people.
Company ambiguity is a blocker.
Always verify company context before every search.
Always open the full profile for every kept contact.

## ZoomInfo Contact Profile Data Extraction
When a ZoomInfo Contact Profile page is open, extract data using the patterns below. The label `(B)`, `(M)`, `(D)`, `(HQ)` appears on the line AFTER the value, not before it.

### ZoomInfo phone/email section format (verbatim)
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
...
Email addresses
b_olk@emblemhealth.com
(B)
```
The mobile number is on its own line; the label `(M)` is on the next line. The email is on its own line; the label `(B)` is on the next line.

### Mandatory mobile-phone logic — simply find `(M)`
Once a confident contact match is open, do **not** write `No Phone` until the Phone numbers section has been checked for an exact `(M)` label.

Use this exact logic:
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
- Simply find the exact `(M)` line.
- Use the line immediately above `(M)` for column `I`.
- If no exact `(M)` exists in the full Phone numbers block, then write `No Phone`.
- Never use `(D)` or `(HQ)` as substitutes for mobile.

### Business Email (B) — correct extraction
```javascript
txt.match(/([A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,})\s*\n\(B\)/i)
// Returns email in match[1]
```

### Rejection rule for wrong-person matches
If ZoomInfo returns a contact whose name does not match the sheet Full Name (ignoring middle initials and nicknames), reject the match entirely. Do not use that email or phone. Mark `K=Not Found` instead.

### Mandatory obvious-result rule — open it before `Not Found`
If ZoomInfo search shows an obvious candidate that matches the sheet person and company context, open that contact profile before declaring `Not Found`.

Rules:
- If an exact full-name result appears for the target company, open it.
- If the title is strongly aligned and the company matches, open it.
- Do not declare `Not Found` while an obvious unopened candidate remains in search results.
- `Not Found` is allowed only after the best visible candidate has been opened and checked, or after the full search ladder and fallback produce no viable candidate.

This prevents false negatives like row 308, where the contact existed in plain view but was not opened deeply enough before writing `Not Found`.

### Write rules
- `K=Enriched`: confident match found
  - `H = (B) email` or exactly `No Email`
  - `I = (M) mobile` or exactly `No Phone`
- `K=Not Found`: no confident match after full search ladder + fallback
  - `H = Not Found`
  - `I = Not Found`
- Never use `(HQ)` or `(D)` in place of `(M)` for column I
- `No Phone` is allowed only after an explicit scan confirms there is no exact `(M)` entry on the matched contact profile

## ZoomInfo enrichment order
1. Advanced Search -> Clear All -> Full Name -> Company -> widen confidence to All contacts / 50-100 before declaring Not Found.
2. Fallback: company page -> Employees -> Information Technology department.
3. Optional accelerator: batch export or bulk enrichment is allowed only when exact row mapping is proven by LinkedIn URL first, then Company Name + Full Name.

Batch convenience must never weaken row-identity rules.

## Sheet invariants
Dedupe key = LinkedIn URL.
Locate writeback rows by LinkedIn URL first, then verify Company Name + Full Name.
Never write ZoomInfo data by row number alone.
Never assume end-of-sheet is empty.
Verify destination row/range before append/update.
Never overwrite verified data with weaker data.
Never delete data.
Post-write verification: re-locate the row by LinkedIn URL and confirm written values match.

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

## Preflight
1. Run `bash scripts/validate_linkedin_zoominfo_sop.sh`.
2. If validation fails, stop before any browser or sheet action.
3. Verify spreadsheet ID and required tabs.
4. Create `RUN_ID=YYYYMMDD-HHMMSS`.
5. Verify the browser/session that actually attaches to Kyle's logged-in Chrome session.
6. Verify LinkedIn login and ZoomInfo login.

## Phase 1 - LinkedIn capture
For each eligible company:
1. Set `Daily Targets` to `In Progress` with RUN_ID and timestamp.
2. Attempt all 13 canonical terms in order unless a real blocker stops execution.
3. For each term, use the preferred path first. If it fails because filters do not work, results are false zero, or anti-automation blocks the search, log the reason and step down through Fallback A then Fallback B.
4. For each term, stop only when one is true:
   - 2 consecutive pages produce 0 new unique LinkedIn URLs
   - OR 10 pages checked
   - OR explicit no-results
5. Keep only contacts whose company context is verified.
6. Open the full profile for every kept contact and capture all available fields needed for sheet writeback and later verification: Full Name, Job Title, Company, Location, LinkedIn URL, Headline, Summary, Experience, Education.
7. Dedupe against `Updated Format` column F before any append.
8. If the LinkedIn URL already exists, update only missing or weaker fields. Never append a duplicate.
9. If the LinkedIn URL is new, append only after verifying the destination range is truly empty.
10. Write linked rows with `J=Added` or `J=Duplicate-Skipped`, `K=Pending`, timestamp, RUN_ID, and notes as needed.
11. If the company entity is ambiguous, mark `Blocked`, record the reason, and stop that company.

## Safe append/update protocol
1. Read `Updated Format` to locate existing LinkedIn URLs in column F.
2. Find the true last populated row; never assume high row numbers are empty.
3. Verify the destination A:N range is blank before appending.
4. After append or update, run post-write verification immediately.

## Phase 2 - ZoomInfo enrichment
Default scope: current-run rows where `M=RUN_ID` and `K=Pending`.

For each pending row:
1. Locate writeback rows by LinkedIn URL first, then verify Company Name + Full Name.
2. Run ZoomInfo Advanced Search in this exact order:
   - Clear All
   - Contact Full Name
   - Company
   - widen confidence to All contacts / 50-100 before declaring Not Found
3. If a confident match is found, capture business email and mobile when available.
4. If Advanced Search fails or yields a false negative, use the company page -> Employees -> Information Technology department fallback.
5. If batch export or bulk enrichment is available and exact mapping is proven by LinkedIn URL first, then Company Name + Full Name, it may be used as an accelerator only.
6. If no confident match remains after the primary path and fallback, mark `K=Not Found`.
7. If a confident match exists but one field is missing, write `No email` or `No phone` as appropriate.
8. Write results safely, then run post-write verification.

Phase 2 remains incomplete while any current-run row has `K=Pending` and no real blocker exists.

## Blockers
Stop and report if any of these occur:
- browser/session cannot be verified
- LinkedIn or ZoomInfo login is lost
- captcha/checkpoint/anti-automation challenge appears
- wrong company context or ambiguous company scope
- required tabs or required columns are missing
- destination row cannot be located by LinkedIn URL
- post-write verification fails

## Completion invariant
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
