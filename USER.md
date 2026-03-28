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
Browser session rule: use the profile that verifiably attaches to Kyle's already logged-in Chrome session; do not assume a profile name.
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

### Status Invariants
- **Daily Targets / column C:** Pending | In Progress | Completed | Blocked | Skipped
- **Updated Format / column J:** Added | Duplicate-Skipped | Blocked
- **Updated Format / column K:** Pending | Enriched | Not Found | Blocked

### ZoomInfo Access
- Browser-based (logged in)
- Canonical order: Advanced Search -> Clear All -> Full Name -> Company -> widen confidence to All contacts / 50-100 before declaring Not Found.
- Fallback: company page -> Employees -> Information Technology department.
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
