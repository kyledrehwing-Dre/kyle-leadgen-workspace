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
Browser session rule: try to attach to Kyle's existing logged-in Chrome session if available; otherwise spawn a dedicated agent-owned browser session/profile. Once a session is verified for the run, use that same verified session consistently for the run. Do not assume a profile name without verification.

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

## Search order
1. Advanced Search -> Clear All -> Full Name -> Company -> widen confidence to All contacts / 50-100 before declaring Not Found.
2. Name-variant ladder: exact full name + company, nickname/full-first-name swap, without middle initial, with middle initial/punctuation variant.
3. Fallback: company page -> Employees -> Information Technology department. **⚠️ HARD STOP — This fallback is mandatory before any Not Found declaration.** It is not optional and it is not a last resort. Only after the IT-department browse produces no candidate may `K=Not Found` be written.
4. Optional accelerator: batch export or bulk enrichment is allowed only when exact row mapping is proven by LinkedIn URL first, then Company Name + Full Name.

## Recommended execution pattern
1. Run `bash scripts/validate_linkedin_zoominfo_sop.sh` first.
2. Default scope = current-run rows where `M=RUN_ID` and `K=Pending`.
3. For each row, locate it by LinkedIn URL first, then verify Company Name + Full Name.
4. **⚠️ HARD STOP — Partial name contacts:** Any contact with a partial name in column B (e.g. "Brian H.", "Luis G.") must have the LinkedIn URL (column F) opened first to extract the verified full first name. Search ZoomInfo using the full name from LinkedIn — not the partial name from the sheet.
5. Try Advanced Search first (Full Name + Company Name, with Enter confirmation after each filter value).
6. If the name-variant ladder produces 0 results: **do not write Not Found** — immediately go to company page -> Employees -> IT department. Browse and open every candidate matching name and role before declaring Not Found.
7. **⚠️ HARD STOP — Profile verification required before write:** After clicking a search result, open the ZoomInfo profile and confirm: (a) name matches sheet Full Name (allowing nickname/full-name variants only), (b) title is consistent with sheet Job Title, (c) company is the target company. Writing without this verification is a process violation — the write must be redone.
8. If export/bulk is available, use it only when every exported record can be mapped back deterministically before writeback.
9. If a match is ambiguous, do not guess. Mark `K=Blocked`, note the ambiguity, and report it.
10. After every write, run post-write verification.

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
