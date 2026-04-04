# USER.md - About Your Human & Configuration
SPEC_VERSION: leadgen-canonical-v3

## Kyle's Info
- **Name:** Kyle Drehwing
- **Email:** Kyle.Drehwing@gmail.com
- **Discord ID:** 2005824834
- **Company:** Evolven
- **Value Proposition:** Evolven collects every configuration in the IT estate and reports on every config change. Changes and misconfigs cause 90%+ of outages, incidents, and breaches.

## Target Persona
IT executives who care about:
- Organizational risk
- Security
- Audit
- Configuration management
- IT operations reliability

### Target Titles/Keywords (Canonical 13-Term Search Universe)
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

## Leadgen Configuration

### Google Sheets (gog)
- **Spreadsheet ID:** 18lfYgX03Q1sw9uLm-kSeutcNeyigjXQElSjatYbjgUI
- **URL:** https://docs.google.com/spreadsheets/d/18lfYgX03Q1sw9uLm-kSeutcNeyigjXQElSjatYbjgUI
- **Source Tab:** Daily Targets
- **Destination Tab:** Updated Format
- **Read targets command:** `GOG_ACCOUNT=Kyle.Drehwing@gmail.com gog sheets get 18lfYgX03Q1sw9uLm-kSeutcNeyigjXQElSjatYbjgUI "'Daily Targets'!A:F" --json`
- **Read destination command:** `GOG_ACCOUNT=Kyle.Drehwing@gmail.com gog sheets get 18lfYgX03Q1sw9uLm-kSeutcNeyigjXQElSjatYbjgUI "'Updated Format'!A:N" --json`
- **Daily Targets columns:** Account | Date Added | Target Status | Last Run ID | Last Updated At | Notes
- **Updated Format columns:** Company Name | Full Name | Last Name | First Name | Job Title | LinkedIn profile link | Location | Email address | Mobile phone number | LinkedIn Phase Status | ZoomInfo Phase Status | Last Updated At | Run ID | Notes

### Workflow Invariants
Browser session rule: try to attach to Kyle's existing logged-in Chrome session if available; otherwise spawn a dedicated agent-owned browser session/profile. Once a session is verified for the run, use that same verified session consistently for the run. Do not assume a profile name without verification.
Only operate these tabs: `Daily Targets` and `Updated Format`.
Datastore = Google Sheets only.
False zero != no people.
Company ambiguity is a blocker.
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

### Separate job definition
- **Job 1 = LinkedIn Capture**
  - discovery only
  - allowed systems: LinkedIn + Google Sheets
  - output: rows written/refreshed with `K=Pending`
  - no ZoomInfo enrichment inside Job 1
- **Job 2 = ZoomInfo Enrichment**
  - enrichment only
  - allowed systems: ZoomInfo + Google Sheets
  - input: existing sheet rows
  - output: `H/I/K/L/N` resolved from ZoomInfo evidence
  - primary objective: fill column `H` (work email) and column `I` (mobile phone)
  - no LinkedIn discovery or new-contact appends inside Job 2
  - execution mode only: no mid-task stopping, no progress updates, no explanation-mode replies
  - once a company starts, finish all targeted contacts for that company before moving on unless a real blocker occurs
  - before writing, the matched ZoomInfo contact must match sheet column `B` (approved nickname/full-name variants only)
  - re-check row identity before writing and verify the exact row/values immediately after writing
  - final output should happen only after the job/company is complete or blocked
  - Execution Control Rules (MANDATORY — NO EXCEPTIONS): CONTINUATION IS REQUIRED once you begin; STOPPING IS A FAILURE unless all rows done, real blocker, or told to stop; NO INTERMEDIATE RESPONSES; SELF-CHECK before any reply (is job complete or blocked? if no, continue); COMPANY LOOP LOCK (finish all contacts for a company before stopping); EXECUTION MODE OVERRIDE (only Working or Finished states); FINAL OUTPUT ONLY (Job complete + rows updated, or blocker explanation)

### Status Invariants
- **Daily Targets / column C:** Pending | In Progress | Completed | Blocked | Skipped
- **Updated Format / column J:** Added | Duplicate-Skipped | Blocked
- **Updated Format / column K:** Pending | Enriched | Not Found | Blocked

### ZoomInfo Access
- Browser-based (logged in)
- Canonical order: Advanced Search -> Clear All -> Contact Name or Email -> Company Name -> widen confidence to All contacts / 50-100 before declaring Not Found.
- Anti-improvisation rule: do not use Quick Search, unfiltered result browsing, or profile hopping before the canonical Advanced Search field sequence is complete. When company context is known, Company Name must be applied before candidate evaluation.
- Required lookup gate: a valid ZoomInfo lookup must record Advanced Search used, Clear All used, Contact Name or Email field applied, Company Name field applied when known, and candidate profile opened only after narrowing.
- Required search ladder before `Not Found`:
  - exact full name + company
  - nickname/full-first-name swap
  - without middle initial
  - with middle initial / punctuation variant
- Fallback: company page -> Employees -> Information Technology department.
- If a confident match exists: `K=Enriched`, `H=(B) or No Email`, `I=(M) or No Phone`.
- If no confident match exists after the full ladder + fallback: `K=Not Found`, `H=Not Found`, `I=Not Found`.
- Never use HQ `(HQ)` or direct `(D)` phone in place of mobile `(M)` for column `I`.
- Optional accelerator: batch export or bulk enrichment is allowed only when exact row mapping is proven by LinkedIn URL first, then Company Name + Full Name.

### LinkedIn Session
- Preferred: verified LinkedIn / Sales Navigator path if session and filters work.
- Fallback A: standard LinkedIn company people path with verified company context.
- Fallback B: company-page / associated-members browsing when people-search returns false zero or is anti-automation blocked.
- Always verify company context before search.
- Always open the full profile for every kept contact.

### Target Companies
_(To be provided daily)_

## Runtime State
- **Last observed state (historical; verify live before use):** 2026-03-09
- **Targets Processed:** Hearst (2 high-quality leads)
- **Total Leads in Sheet:** 234 (added 2 new)
