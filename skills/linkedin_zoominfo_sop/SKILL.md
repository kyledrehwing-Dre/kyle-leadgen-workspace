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
Primary order: Advanced Search -> Clear All -> Full Name -> Company -> widen confidence to All contacts / 50-100 before declaring Not Found.
Fallback: company page -> Employees -> Information Technology department.
Optional accelerator: batch export or bulk enrichment is allowed only when exact row mapping is proven by Company Name + Full Name.
Optional accelerator: batch export or bulk enrichment is allowed only when exact row mapping is proven by LinkedIn URL first, then Company Name + Full Name.

**⚠️ CRITICAL — Wrong order is the #1 cause of failure:**
- **ALWAYS search by Contact Name FIRST, then Company Name**
- Starting with company name returns hundreds of rows — wrong
- Starting with contact name often returns 1–5 rows — correct
- **NEVER use Quick Search** — it searches by company/keyword, not person
- **ALWAYS use Clear All** before applying filters so stale filters do not contaminate results
- **ALWAYS press Enter after typing each filter value** — typing alone does NOT apply the filter; you must confirm with Enter or by selecting an autocomplete value
- Before declaring `Not Found`, widen confidence/scope to **All contacts / 50-100** as required by the canonical flow

**The correct sequence (every single contact, no exceptions):**
1. Click **Advanced Search**
2. Click **Clear All**
3. Click **"Contact Name or Email"** filter → type **[PERSON'S FULL NAME]** ← this MUST come first
4. **Press Enter** to confirm the Contact Name filter — typing alone does NOT apply the filter
5. Click **"Add filter"** → **Company Name** → type **[COMPANY NAME]**
6. **Press Enter** to confirm the Company Name filter
7. Click **Search** to execute
8. Widen confidence/scope to **All contacts / 50-100** before declaring `Not Found`
9. Click the correct person's profile from the results
10. Extract email (B) and mobile (M)

**If the search returns 0 results:** run name variants (nickname, no middle initial, with middle initial) before declaring Not Found.
- exact full name + company
- nickname/full-first-name swap
- without middle initial
- with middle initial / punctuation variant

Fallback: company page -> Employees -> Information Technology department.
Optional accelerator: batch export or bulk enrichment is allowed only when exact row mapping is proven by Company Name + Full Name.

**ZoomInfo SPA browser note:** ZoomInfo's web app is client-side rendered. Browser navigation to search results URLs may redirect unexpectedly. If the direct URL approach fails, fall back to the UI-based Advanced Search sequence above. Once a company profile page is loaded (e.g. `/apps/profile/company/{id}/employees`), individual contact profile pages can be navigated to directly via `/apps/profile/person/{id}/contact-profile` and do render correctly.

Batch convenience must never weaken row-identity rules.

## Sheet invariants
Dedupe key = LinkedIn URL.
Dedupe key = LinkedIn URL (Job 1 — LinkedIn discovery).
Locate writeback rows by LinkedIn URL first, then verify Company Name + Full Name.
Locate writeback rows by Company Name + Full Name (Job 2 — ZoomInfo enrichment).
Never write ZoomInfo data by row number alone.
Never assume end-of-sheet is empty.
Verify destination row/range before append/update.
Never overwrite verified data with weaker data.
Never delete data.
Post-write verification: re-locate the row by LinkedIn URL and confirm written values match.
Post-write verification: re-locate the row by Company Name + Full Name and confirm written values match.

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

## Sub-agent browser initialization (required before any ZoomInfo work)
Every sub-agent session must initialize its own browser before doing any ZoomInfo work. Do not assume a parent session's browser is available or stable.

**Required steps at the start of every sub-agent task:**
1. Call `browser start profile=openclaw` to spawn a fresh browser session.
2. Call `browser open url=https://app.zoominfo.com` to navigate to ZoomInfo.
3. Call `browser snapshot` to verify the page loaded correctly.
4. If the snapshot shows a login page, checkpoint, or unexpected state, retry up to 3 times with a 5-second wait between attempts.
5. Proceed with searches only after confirmed ZoomInfo session is active.
6. If browser cannot be verified after 3 attempts, stop and report the blocker — do not attempt to continue with a broken browser session.

**For LinkedIn work:** initialize the same way with `browser open url=https://www.linkedin.com` and verify login state before searching.

**For ZoomInfo searches:** Always use Advanced Search → Contact Name → Company Name (described in Phase 2 below). Never use Quick Search.

## Preflight (run before any search or write)
1. Run `bash scripts/validate_linkedin_zoominfo_sop.sh`. Stop if validation fails.
2. Verify spreadsheet ID and required tabs (`Daily Targets`, `Updated Format`).
3. Create `RUN_ID=YYYYMMDD-HHMMSS`.
4. Verify LinkedIn login and ZoomInfo login in the initialized browser session.
5. Proceed only after all five steps pass.

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

**For every ZoomInfo lookup, you MUST use this exact Advanced Search sequence:**

### Step 1 — Advanced Search → Contact Name → Company Name (required for EVERY contact)
1. Click the **Advanced Search** button in ZoomInfo
2. In the filter panel, click **"Contact Name or Email"** filter button to expand it
3. **Type the person's FULL NAME** in the Contact Name textbox (ref=e37 or similar)
4. **Press Enter** to confirm the Contact Name filter — typing alone does NOT apply the filter
5. Click **"Add filter"** or scroll to **Company Name** section and expand it
6. **Type the company name** in the Company Name textbox
7. **Press Enter** to confirm the Company Name filter
8. Click **Search** to execute
9. Results will appear below — find the correct person at the correct company, click their profile, extract email (B) and mobile (M)

**IMPORTANT: Always enter the person's full name FIRST, then the company name. Always press Enter after each filter value. Typing alone does NOT apply the filter. Do NOT use Quick Search.**

### Step 2 — If no match found
Run the name-variant ladder:
- exact full name + company
- nickname/full-first-name swap (e.g. "Bob" ↔ "Robert")
- without middle initial
- with middle initial / punctuation variant

### Step 3 — Fallback
Company page → Employees → Information Technology department.

### Step 4 — Write results
- K=Enriched + email (B) + mobile (M) if found
- K=Not Found if no confident match after full ladder + fallback
- K=Enriched + No Email / No Phone if profile found but contact data missing

### Step 5 — Post-write verification
Re-locate the row by Company Name + Full Name and confirm written values match.

**Never skip steps 1–3. Never use Quick Search. Never declare Not Found while an obvious candidate remains unopened.**

Phase 2 remains incomplete while any current-run row has `K=Pending` and no real blocker exists.

## Blockers
Stop and report if any of these occur:
- browser/session cannot be verified
- LinkedIn or ZoomInfo login is lost
- captcha/checkpoint/anti-automation challenge appears
- wrong company context or ambiguous company scope
- required tabs or required columns are missing
- destination row cannot be located by Company Name + Full Name
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
