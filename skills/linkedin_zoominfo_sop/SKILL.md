---
name: linkedin_zoominfo_sop
description: Deterministic SOP for LinkedIn title-search -> Google Sheet write -> ZoomInfo enrichment (no wrong tab/row, no guessing).
---

# LinkedIn -> Sheet -> ZoomInfo SOP

## Purpose
Use this workflow when the task is:
- finding people on LinkedIn for target companies using approved title terms
- writing those people into Google Sheets
- enriching those same rows in ZoomInfo with email and mobile data

Follow this SOP exactly. Do not improvise, generalize, or switch methods mid-run.

## Compliance and handling
- Use only with appropriate permission and in line with platform terms.
- Never guess missing data.
- Never fabricate titles, companies, names, emails, phone numbers, or locations.
- If a page cannot be verified, stop and report the blocker.

## Global rules
1. Work in TWO PHASES only:
 - Phase 1: LinkedIn + Google Sheet
 - Phase 2: ZoomInfo + Google Sheet
2. Before every click, paste, or type:
 - verify the current domain and page are correct
3. Do not rely on active-tab assumptions.
4. Do not open unnecessary tabs or sessions.
5. Never write ZoomInfo data by row number alone.
6. Canonical dedupe key = LinkedIn profile URL.
7. If login is lost, captcha/checkpoint appears, or the page context is uncertain:
 - stop and report

## Sheet structure
Source tab:
- `Daily Targets`

Destination tab:
- `Updated Format`

Expected columns in `Updated Format`:
- A = Company Name
- B = Full Name
- C = Last Name
- D = First Name
- E = Job Title
- F = LinkedIn profile link
- G = Location
- H = Email address
- I = Mobile phone number

## How to determine which companies to process
### New companies
Process only companies from the most recent date visible in the `Daily Targets` date column.

### Already processed rule
Use this order:
1. If `Daily Targets` has a status or processed marker, trust that.
2. Otherwise, treat a company as already processed if at least one row already exists in `Updated Format` with the same Company Name.

Do not re-search older companies.
Do not duplicate previously added people.

## Phase 1 - LinkedIn capture

### Approved search terms
Use ONLY these 13 terms:
- IT operations
- SRE
- Cloud Operations
- DevOps
- Infrastructure
- Enterprise Architecture
- Application Support
- Production Support
- Observability
- Site Reliability Engineer
- Change Management
- Incident management
- AI

Do not use any other terms.

### LinkedIn session rules
- Stay in the same LinkedIn session
- Do not open extra LinkedIn sessions
- Reuse the same LinkedIn page flow for every company

### Canonical search method
For each target company:
1. Confirm LinkedIn is open and logged in
2. Use a people-search path that enforces current company
3. Apply `Current company = <target company>`
4. Search one approved title term at a time
5. Keep the company filter applied at all times

Do not rely on loose global search without confirming company context.

### Extraction rule
For each matching result, extract exactly:
- Full Name
- Job Title or headline
- Location
- LinkedIn profile URL

### Matching rule
Include a person only when:
- the result is clearly associated with the target company
- the visible title/headline is relevant to the searched term

If company context cannot be verified, skip.

### Paging and stopping rule
For each of the 13 terms:
- continue paging or scrolling until:
 - 2 consecutive pages produce 0 new unique LinkedIn URLs
 - OR 10 pages have been checked
 - OR LinkedIn shows no results

Do not stop early just because a few names were found.

### Dedupe rule
Before writing a result:
- check whether the LinkedIn profile URL already exists in `Updated Format`
- if it already exists, skip it
- never duplicate a LinkedIn URL

### Write rule for LinkedIn data
Append each new person after the last filled row in `Updated Format` with:
- A Company Name
- B Full Name
- C Last Name
- D First Name
- E Job Title
- F LinkedIn profile link
- G Location

Leave H and I blank during Phase 1.

### Name parsing rule
- Full Name = exactly as shown
- First Name / Last Name:
 - split on the last space where reasonable
 - if ambiguous, leave First Name blank and place the remaining value in Last Name
 - do not invent structure

### Company completion rule
Only move to the next company after all 13 approved title terms are completed for the current company.

## Phase 2 - ZoomInfo enrichment

### Which rows to process
Process rows in `Updated Format` where H or I is blank.

### Row identity rule
The row must be identified by LinkedIn profile URL in column F.
Do not trust visible row position alone.

### ZoomInfo search method
For each row needing enrichment:
1. Copy Full Name from column B
2. Open ZoomInfo Advanced Search
3. Click `Clear All`
4. Paste Full Name into `Contact Name or Email`
5. Confirm the selection
6. Copy Company Name from column A
7. Paste Company Name into `Company Name/URL/Ticker`
8. Confirm the selection
9. Search thoroughly

### Match selection rule
When multiple contacts appear, choose the best match in this order:
1. exact company match
2. closest job title match to column E
3. closest location match to column G

If still ambiguous, do not guess.

### Write-back rule
Before writing:
1. locate the destination row again by LinkedIn URL in column F
2. verify Company Name and Full Name still match the intended record

Then write:
- Email address to column H
- Mobile phone number to column I

### Missing-data rule
- If email is missing, write `No Email` in H
- If mobile phone is missing, write `No Phone` in I
- If the contact cannot be found confidently, write `Not Found` in both H and I

### Post-write verification
After every write:
- re-read H and I
- confirm the values match the intended record

## Error handling
Stop and report if any of these happen:
- wrong site or wrong page context
- cannot verify current domain
- write fails
- login lost
- captcha or checkpoint appears
- results repeatedly fail to load
- 3 consecutive execution errors occur

Do not keep pushing through uncertain state.

## Completion rules
Phase 1 is complete when:
- every eligible company from the most recent `Daily Targets` date has been processed across all 13 terms

Phase 2 is complete when:
- every newly added row from this run has H and I filled
- or placeholder values have been written

## Run summary
At the end, report:
- number of companies processed
- number of people added
- number of rows enriched
- number marked `Not Found`
- any blockers encountered
