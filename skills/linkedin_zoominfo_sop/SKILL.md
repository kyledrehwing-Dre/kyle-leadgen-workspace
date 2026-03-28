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
7. Use explicit status columns; never infer status from row position.
8. If login is lost, captcha/checkpoint appears, or page context is uncertain:
 - stop and report

## Tab control policy
Only operate these tabs in this workflow:
1. `Daily Targets` (read targets + write company processing status)
2. `Updated Format` (write leads + enrichment + row status)

Do not read from or write to any other tab unless the user explicitly instructs it.
Before every write, verify spreadsheet ID and tab title.
If required tabs are missing, stop and report.

## Run identity rule
At run start, create `RUN_ID = YYYYMMDD-HHMMSS`.
Use the same RUN_ID for all rows touched in this run.

## Sheet structure and explicit status columns
Source tab:
- `Daily Targets`

Required columns in `Daily Targets`:
- A = Account
- B = Date Added
- C = Target Status
- D = Last Run ID
- E = Last Updated At
- F = Notes

Allowed values for `Daily Targets` column C (Target Status):
- `Pending`
- `In Progress`
- `Completed`
- `Blocked`
- `Skipped`

Destination tab:
- `Updated Format`

Required columns in `Updated Format`:
- A = Company Name
- B = Full Name
- C = Last Name
- D = First Name
- E = Job Title
- F = LinkedIn profile link
- G = Location
- H = Email address
- I = Mobile phone number
- J = LinkedIn Phase Status
- K = ZoomInfo Phase Status
- L = Last Updated At
- M = Run ID
- N = Notes

Allowed values for `Updated Format` column J (LinkedIn Phase Status):
- `Added`
- `Duplicate-Skipped`
- `Blocked`

Allowed values for `Updated Format` column K (ZoomInfo Phase Status):
- `Pending`
- `Enriched`
- `Not Found`
- `Blocked`

If these required status columns are missing or renamed, stop and report schema mismatch.

## How to determine which companies to process
### New companies
Process only companies from the most recent date visible in `Daily Targets` column B.

### Already processed rule
Use this order:
1. If `Daily Targets` column C has status, trust it.
2. Process only companies where status is blank, `Pending`, or `In Progress`.
3. Skip companies marked `Completed` or `Skipped` unless the user asks for re-run.
4. If status is missing but a company already exists in `Updated Format`, treat as previously processed and mark `Skipped` with a note.

Do not re-search older companies.
Do not duplicate previously added people.

## Phase 1 - LinkedIn capture

### Approved search terms (use with Sales Navigator)
Use ONLY these terms as keyword queries in Sales Navigator:
- operations
- Cloud Operations
- DevOps
- Infrastructure
- Enterprise Architecture
- Observability
- Site Reliability
- Change Management
- Incident Management
- AI

Do not use any other terms.

### LinkedIn session rules
- Use Chrome profile="user" for all LinkedIn/Sales Navigator navigation.
- Stay in the same LinkedIn session throughout the run.
- Do not open extra LinkedIn sessions or tabs.
- Reuse the same browser tab for every company.
- If browser times out or disconnects, restart with `browser(action=start, profile="user")`.
- **PREFERRED: Use LinkedIn Sales Navigator** - provides more results (100+ vs 10) and better pagination with connection degree info.

### LinkedIn Sales Navigator search path (RECOMMENDED)
For each target company and each approved term:

**Step 1: Find the company's LinkedIn page to get the company ID**
1. Navigate to `https://www.linkedin.com/company/<company-slug>/`
2. The company slug is the lowercase name with hyphens (e.g., "federal-home-loan-bank-of-new-york")
3. Confirm the company page loads correctly
4. Note the company ID from the URL or proceed to Step 2

**Step 2: Build the Sales Navigator search URL**
Build the URL using the company slug and the `FUNCTION:Information Technology` filter:
```
https://www.linkedin.com/sales/search/people?query=(filters%3AList((type%3ACURRENT_COMPANY%2Cvalues%3AList((id%3Aurn%253Ali%253Aorganization%253A<COMPANY_ID>%2Ctext%3A<COMPANY_SLUG>%2CselectionType%3AINCLUDED)))(type%3AFUNCTION%2Cvalues%3AList((id%3A13%2Ctext%3AInformation%2520Technology%2CselectionType%3AINCLUDED)))))&sessionId=<SESSION_ID>
```

Where:
- `<COMPANY_ID>` = the numeric ID from the company's LinkedIn page (e.g., 30406 for FHLBNY)
- `<COMPANY_SLUG>` = the URL slug (e.g., "federal-home-loan-bank-of-new-york")
- `<SESSION_ID>` = the current Sales Navigator session ID (can be copied from the browser URL bar after logging in)

**Step 3: Navigate and verify**
1. Navigate to the built URL in Chrome (profile="user")
2. Confirm Sales Navigator loads with the company filter chip visible
3. Confirm the function filter "Information Technology" is active
4. Verify the result count (e.g., "59 results" for IT staff)

**Step 4: Collect contacts from search results**
1. Browse the results list - each entry shows: name, title, connection degree, company
2. Click on each contact to open their full Sales Navigator lead page
3. From the lead page, extract:
   - Full Name
   - Job Title (current role)
   - Location
   - LinkedIn profile URL (from the profile link)
   - Email (if visible in Sales Navigator contact info)
   - Years in role / years in company
4. Collect up to 20 contacts PER TERM from the search results

**Step 5: Navigate to next page**
1. Click the "Next" button to go to page 2, 3, etc.
2. Continue until:
   - 2 consecutive pages produce 0 new relevant contacts
   - OR 10 pages have been checked
   - OR LinkedIn shows no more results

**Step 6: Change keyword and repeat**
For each approved term, repeat Steps 3-5 with the new keyword in the search box.

### Alternative: Standard LinkedIn search path
For each target company and each approved term:
1. Navigate to the company's LinkedIn page: `https://www.linkedin.com/company/<company-slug>/people/`
2. Confirm domain is `www.linkedin.com` and user is logged in.
3. On the People tab, use the search box to filter by keyword (approved term).
4. Browse results and collect contacts.
5. Confirm company context is visible in each result card.
6. Page through results until exhausted.

Do not rely on loose global search without confirmed company context.

### Contact limit per term
- **20 contacts MAX per approved search term**
- If more than 20 contacts found for a term, take the top 20 most relevant (prioritize: 1st degree connections, then titles most closely matching the searched term)
- Stop collecting for this term once 20 contacts are collected or search results are exhausted

### Company status updates in Phase 1
For each company:
1. Before first term, set `Daily Targets` status (column C) to `In Progress`, set D=RUN_ID, set E=current timestamp.
2. After all 10 terms finish (or hard stop), update status to `Completed` or `Blocked`.
3. Write blocker reason in column F when status is `Blocked`.

### Extraction rule
For each contact opened from Sales Navigator search results, extract exactly:
- Full Name (from the profile header)
- Job Title (from "Current role" section)
- Location (from profile header)
- LinkedIn profile URL (from the profile link in the browser address bar or profile URL)
- Email (from Sales Navigator "Contact information" section - shown as "Name's email: xxx@xxx.com")

### Profile collection approach
1. From search results list, click on a person's name/link to open their Sales Navigator lead page
2. On the lead page, scroll through to collect:
   - **Full Name**: heading at top of page
   - **Title**: from "Current role" paragraph
   - **Location**: from profile header
   - **LinkedIn URL**: from browser address bar (format: `https://www.linkedin.com/in/username`)
   - **Email**: from "Contact information" section (may show personal email or "Add contact info" if not visible)
   - **Years in role/company**: from profile metadata
3. Navigate back to search results to continue collecting

### Title matching rule
Include a person only when:
- The person's title contains or relates to one of the approved search terms
- The person is confirmed at the target company (from the profile)

**Approved title keywords (any match is sufficient):**
- "operations", "Cloud", "DevOps", "Infrastructure", "Architecture", "Observability", "Site Reliability", "Change Management", "Incident", "AI", "SRE", "Security", "IT", "Systems", "Network", "Data", "Engineering", "Support", "Application"

**Blocked title keywords:**
- "IT Manager" (exact phrase - not approved)

If company context or title match cannot be verified, skip.

### Paging and stopping rule
For each of the 10 terms, continue paging or scrolling until one stop condition is met:
- 2 consecutive pages produce 0 new unique LinkedIn URLs
- OR 10 pages have been checked
- OR LinkedIn shows no results

Do not stop early just because a few names were found.

---

## MANDATORY COVERAGE ENFORCEMENT

### ⚠️ EARLY-EXIT PREVENTION RULES

**NEVER stop after finding X contacts.** X is NOT completion evidence.
- Finding 5, 10, 15, or any small number of contacts does NOT mean the search is done
- You MUST exhaust all 10 terms + full paging before marking any company as done

**NEVER require user nudges to continue valid work.** 
- If more valid search work exists within SOP constraints, continue autonomously
- Do not ask "should I continue" - just execute all 10 terms

### Term Completion Checklist
For each company, you MUST attempt ALL 10 terms:
1. IT operations
2. Cloud Operations
3. DevOps
4. Infrastructure
5. Enterprise Architecture
6. Observability
7. Site Reliability Engineer (SRE)
8. Change Management
9. Incident management
10. AI

**Before marking a company as `Completed`, verify:**
- [ ] All 10 approved terms were attempted
- [ ] Each term was paged until stop condition met (2 consecutive empty pages OR 10 pages)
- [ ] Dedupe against column F applied
- [ ] Did NOT stop just because "enough" contacts found

### Coverage Verification Script
Add this check before marking any company complete:

```bash
# Verify all 10 terms were attempted for company
verify_coverage() {
  local company=$1
  local terms_attempted=$(get_terms_attempted_count $company)
  local total_terms=10
  
  if [ "$terms_attempted" -lt "$total_terms" ]; then
    echo "ERROR: Only $terms_attempted/$total_terms terms completed for $company"
    echo "MUST complete all 10 terms before marking done"
    return 1
  fi
}
```

### Pre-Completion Audit
Before setting status to `Completed`, run audit:
- Query how many terms were searched for this company
- Query total unique contacts found
- If terms < 10 → BLOCK and explain
- If terms = 10 but paging incomplete → BLOCK and explain

### Dedupe rule
Before writing a result:
- check whether LinkedIn profile URL already exists in `Updated Format` column F
- if URL already exists, skip append
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
- H Email address = blank
- I Mobile phone number = blank
- J LinkedIn Phase Status = `Added`
- K ZoomInfo Phase Status = `Pending`
- L Last Updated At = timestamp
- M Run ID = RUN_ID
- N Notes = blank (or blocker note if needed)

### Name parsing rule
- Full Name = exactly as shown
- First Name / Last Name:
 - split on the last space where reasonable
 - if ambiguous, leave First Name blank and place the remaining value in Last Name
 - do not invent structure

### Company completion rule
Move to next company only after all 10 approved terms are completed for current company, or company is explicitly marked `Blocked`.

## Phase 2 - ZoomInfo enrichment

### ⚠️ CRITICAL: Search SOP Corrections (MUST FOLLOW)

**These rules fix the common failure mode of always returning "Not Found":**

1. **ALWAYS use Advanced Search** - Click "Advanced Search" button, NOT quick search
2. **ALWAYS click "Clear All" first** - Before entering any new name, clear ALL filters to prevent residual data contamination
3. **Check/adjust confidence score filter** - ZoomInfo defaults to 75-99% which EXCLUDES valid contacts. If contact is not found, try selecting "All contacts" (50-100%) or lower the minimum threshold
4. **Add Contact Name filter first** - Use the filter dropdown, NOT the quick search box
5. **Enter full name from column B** - Use the exact name from Google Sheets
6. **Then add Company Name filter** - Enter company from column A
7. **Execute search** - Look for results
8. **If multiple results**, find the best match by comparing job titles

**⚠️ COMMON MISTAKE: The confidence score filter is the #1 reason contacts are missed.** ZoomInfo shows "No Results Found" even when the contact exists, because their confidence score is below 75%. Always check the filter dropdown in the top-right corner and expand it to "All contacts" or adjust the minimum threshold before declaring a contact "Not Found".

### Job Configuration
- **Job Name:** zoominfo_google_sheet_enrichment
- **Google Sheet URL:** https://docs.google.com/spreadsheets/d/18lfYgX03Q1sw9uLm-kSeutcNeyigjXQElSjatYbjgUI/edit
- **Target Tab:** Updated Format (gid=1429580758)
- **ZoomInfo URL:** https://app.zoominfo.com

### Detailed ZoomInfo Search Steps (CORRECTED)

#### For each row in Updated Format where K = "Pending":

**Step 1: Prepare the search**
- Navigate to ZoomInfo Advanced Search
- **CLICK "Clear All"** to reset all filters (critical - prevents contamination from previous searches)
- Verify "0 active" filters shown

**Step 1b: Check confidence score filter (CRITICAL)**
- Look at the dropdown in the top-right corner (default: "75-99%")
- If set to "75-99%" or similar high threshold, CHANGE IT to "All contacts" or "50-100%"
- This is the #1 cause of false "Not Found" results - valid contacts are filtered out!
- The filter shows as "75%" or similar - click to expand and select "All contacts"

**Step 2: Add Contact Name filter**
- Click "Add filter" under Contacts section
- Click "Contact Name or Email" filter
- Type the FULL name from column B (e.g., "Jon Thompson")
- Press Enter to apply

**Step 3: Review results**
- Count the number of results shown:
  - **If 0 names appear:** Contact not found in ZoomInfo
    - Write "Not Found" in column H
    - Write "Not Found" in column I
    - Write "Not Found" to column K
    - Move to next row (Step 6)
  - **If 1 name appears:** Direct match found
    - Click to open the contact profile
    - Extract email [B] and mobile [M]
    - Write to columns H and I
    - Write "Enriched" to column K
    - Move to next row (Step 6)
  - **If multiple names appear:** Ambiguous match - proceed to Step 4

**Step 4: Add Company Name filter for disambiguation**
- Click "Add filter" under Companies section
- Click "Company Name" filter
- Type the company name from column A (e.g., "Barclays")
- Press Enter to apply

**Step 5: Review disambiguated results**
- Count the number of results shown:
  - **If 0 names appear:** No match found after company filter
    - Write "Multi-Not Found" in column H
    - Write "Multi-Not Found" in column I
    - Write "Not Found" to column K
  - **If 1+ names appear:** Take the first/best match
    - Click to open the contact profile
    - Extract email [B] and mobile [M]
    - Write to columns H and I
    - Write "Enriched" to column K

**Step 6: Write to Google Sheet**
- Locate row by LinkedIn profile URL (column F) - NEVER by row position
- Write email to column H
- Write phone to column I
- Write status to column K ("Enriched" or "Not Found")
- Verify write by re-reading

**Step 7: Move to next row**
- Repeat from Step 1 for next Pending row

### Variables
- `row_id` = ""
- `company` = ""
- `contact` = ""
- `email` = ""
- `phone` = ""
- `current_company` = ""
- `rows_updated` = 0
- `target_row` = null

### Execution Steps

#### Initialize
1. Switch to Google Sheets tab
2. Click on first data row (row 2, column B)
3. Set `rows_updated` = 0

#### Main Loop (while Column B is not empty)

**Step 1: READ CURRENT ROW**
- Read cell in column B (Contact Name) → save as `contact`
- Read cell in column A (Company Name) → save as `company`
- Read cell in column J (LinkedIn Phase Status) → save as `row_id`

**Step 2: ENSURE ROW ID**
- If `row_id` is empty:
  - Generate ID with format "ROW-{counter}"
  - Write to column J

**Step 3: SEARCH ZOOMINFO** (using CORRECTED SOP above)
- Switch to ZoomInfo tab
- Follow the Detailed ZoomInfo Search Steps (Steps 1-7 above)
- Use name from column B + company from column A

**Step 4: CHECK RESULT**
- If contact NOT found in results:
  - Set `email` = "Not Found"
  - Set `phone` = "Not Found"
- ELSE (contact found):
  - Click to open contact profile
  - **Extract Email:**
    - If [B] email exists → copy to `email`
    - ELSE → `email` = "No email"
  - **Extract Phone:**
    - If (M) mobile exists → copy to `phone`
    - ELSE → `phone` = "No phone"

**Step 5: WRITE BACK TO SHEET**
- Switch to Google Sheets tab
- Find row where column J = `row_id` → save as `target_row`
- Validate: read company from column A, confirm matches
- Write `email` to column H (offset -2 from row_id)
- Write `phone` to column I (offset -1 from row_id)
- Verify write by re-reading

**Step 6: COUNT & MOVE**
- Increment `rows_updated`
- Press ArrowDown to move to next row
- Repeat loop

#### Completion
- STOP when Column B (Contact Name) is empty
- Return: "Job complete", "Rows updated: [rows_updated]"

### Rules & Constraints
- **NEVER skip the "Clear All" step** - This is the #1 cause of false "Not Found" results
- **ALWAYS check the confidence score filter before declaring "Not Found"** - ZoomInfo defaults to 75-99% which filters out valid contacts. Change to "All contacts" (50-100%) before giving up
- Only use [B] email (business email)
- Only use (M) mobile phone
- Do NOT leave blanks in Column H or I
- Always write one of:
  - Valid data
  - "Not Found" (contact not in ZoomInfo)
  - "Multi-Not Found" (multiple matches, no confident result after company filter)
  - "No email"
  - "No phone"

### Performance Guidelines
- **Do NOT reuse search without clearing** - Always clear between searches
- Maintain same ZoomInfo session per company
- Prioritize exact matches (name + company)

### Failure Handling
- If ZoomInfo fails to load: Pause and retry
- If page errors persist: Skip row → mark "Not Found"
- If session logged out: Stop and report

### Which rows to process
Process rows in `Updated Format` where:
- K (ZoomInfo Phase Status) = `Pending`
- OR K is empty and H/I are empty (legacy data)

Do not process rows where K = `Enriched` or K = `Not Found`.

### Row identity rule
The row must be identified by LinkedIn profile URL in column F.
Do not trust visible row position alone.

### Missing-data rule
- If email is missing, write `No email` in H
- If mobile phone is missing, write `No phone` in I
- If contact cannot be found (0 results), write `Not Found` in both H and I
- If multiple results found but no confident match after company filter, write `Multi-Not Found` in both H and I
- **Before declaring "Not Found": ALWAYS check/adjust the confidence score filter** - try "All contacts" or lower the minimum threshold (50-100%) if contact appears missing. This is the most common reason valid contacts are missed.

### Post-write verification
After every write:
- re-locate the same row by LinkedIn URL
- re-read H, I
- confirm values match intended record

## Error handling and hard stop rules
Stop immediately and report if any of these occur:
- wrong site or wrong page context
- cannot verify current domain
- login lost
- captcha or checkpoint appears
- required tabs/columns are missing
- cannot locate destination row by LinkedIn URL
- page results fail to load after 2 retries
- 3 consecutive execution errors occur
- Chrome relay is not attached to the intended LinkedIn or ZoomInfo tab

Do not keep pushing through uncertain state.

## Completion rules
Phase 1 is complete when:
- every eligible company from the most recent `Daily Targets` date has status `Completed` or `Blocked`

Phase 2 is complete when:
- every row from this run (M=RUN_ID) has K not equal to `Pending`

## Run summary
At the end, report:
- RUN_ID
- number of companies processed
- number of companies `Completed`
- number of companies `Blocked`
- number of people added
- number of duplicate URLs skipped
- number of rows enriched (K=`Enriched`)
- number marked `Not Found`
- any blockers encountered

---

# STRENGTHENING PATCH - EXHAUSTIVE COVERAGE RULES

## 0. PURPOSE OF THIS PATCH

The current failure mode is shallow execution:
- stopping after a small batch
- treating a first pass as completion
- requiring user nudges to continue
- under-exploring query/result space within the approved SOP

**THIS PATCH'S PRIMARY OBJECTIVE: Never ask the user to continue. Finish the job autonomously.**

The SOP gives you everything you need to complete the work. Use it. When the SOP says "continue paging," continue. When it says "run all 10 terms," run them all. When it says "stop only when X," stop only when X.

If you finish properly, report the results. Do not ask for permission to continue working — that is a failure of execution, not a feature of collaboration.

## 1. NON-NEGOTIABLE RULE: 10 CONTACTS IS NOT COMPLETION

If you find 10 contacts for a company, that is never by itself evidence of completion.

Treat any batch of 10 as a likely intermediate retrieval state unless you have strong evidence that:
- all 10 approved terms were fully run
- paging/scrolling rules were followed per term
- dedupe was applied
- additional diversified searches within SOP constraints no longer produce meaningful new LinkedIn profile URLs

**Never stop because:**
- "10 seems like enough"
- "I found some names already"
- "results look decent"
- "the user didn't explicitly say continue"

If more reasonable search work remains inside the SOP, continue automatically.

## 2. THIS SOP MUST BE EXECUTED AS A LOOP, NOT A ONE-SHOT PASS

For each company, you must operate in repeated cycles:

**Cycle structure:**
1. Run approved LinkedIn search term(s)
2. Collect results
3. Deduplicate by LinkedIn profile URL
4. Assess coverage gaps
5. Continue with remaining approved terms and pages
6. Only after all approved angles are exhausted may you consider stopping

For each company, do not move on simply because one or two terms produced enough results.
The company is complete only when:
- all 10 approved terms have been attempted
- each term has been paged/scrolled according to SOP stop rules
- duplicate suppression has been applied
- additional yield has materially collapsed

## 3. APPROVED EXHAUSTIVENESS STANDARD WITHIN THIS SOP

You must remain strictly within the SOP's allowed search method.
That means:
- do not invent new title terms
- do not switch to a different sourcing workflow
- do not use unapproved tabs
- do not improvise alternate pipelines

**But within those constraints, you must search exhaustively.**

That means for every eligible company:
- run all 10 approved terms
- verify current company filter chip is visible for every search
- continue paging/scrolling for each term until the SOP stopping rule is actually met
- dedupe against existing LinkedIn URLs in Updated Format column F
- do not stop after the first useful term
- do not stop after the first page unless no-results is explicit
- do not collapse the remaining terms just because some overlap is expected

## 4. MANDATORY TERM-BY-TERM COMPLETION

For each company, all of the following approved terms must be attempted unless a hard blocker occurs:

1. IT operations
2. Cloud Operations
3. DevOps
4. Infrastructure
5. Enterprise Architecture
6. Observability
7. Site Reliability Engineer (SRE)
8. Change Management
9. Incident management
10. AI

**Rules:**
- no term may be silently skipped
- no term may be assumed redundant
- overlapping titles do not justify skipping a term
- if a term produces zero results, that still counts as attempted only after verified search execution
- if LinkedIn blocks, captcha appears, login drops, or context becomes uncertain, stop and report blocker rather than pretending completion

## 5. DEEPER PAGING / STOPPING INTERPRETATION

The SOP already says for each term continue until:
- 2 consecutive pages produce 0 new unique LinkedIn URLs
- OR 10 pages have been checked
- OR LinkedIn shows no results

You must apply this literally and strictly.

**Interpretation rules:**
- do not stop a term after one page if page 1 had results
- do not stop because "results started looking repetitive" unless the 2-consecutive-pages-zero-new-URLs condition is actually met
- if exactly 10 or another suspiciously capped number of people were found for a term or company, assume more may exist and continue through remaining pages/terms
- page exhaustion is term-specific, not company-wide
- completion requires exhausting each term's search path, not just the company overall

## 6. COVERAGE-GAP ASSESSMENT IS REQUIRED

After each term, and again before marking a company Completed, assess whether coverage still looks thin.

**Examples of thin coverage:**
- only one department surfaced
- only one seniority band surfaced
- only generic infra titles surfaced
- only obvious executives surfaced
- only AI titles surfaced but no ops/SRE/DevOps people
- results are concentrated in one narrow phrasing

If coverage is still thin and unrun approved terms remain, continue.
If all approved terms were run and additional pages yield no new URLs, only then may you stop.

## 7. AUTONOMOUS CONTINUATION RULE

**Never wait for the user to say "continue."**

If:
- there are unrun approved terms
- pages remain under the SOP limits
- recent searches are still producing new unique LinkedIn URLs
- company status is still In Progress

Then continue autonomously.

User nudging is not part of successful execution.
Manual babysitting means you failed to finish the loop.

## 7.1. ZERO-TOLERANCE: NEVER ASK TO CONTINUE

**This is critical: You must NEVER ask the user to continue.**

表现形式包括但不包括：
- "Should I continue?"
- "Would you like me to keep going?"
- "Do you want me to proceed with more?"
- "Should I move on to the next term?"
- Any variation that seeks permission to continue working

**If you find yourself wanting to ask "should I continue" — that is a failure signal.**

Instead of asking, you MUST:
- Check if unrun approved terms remain → run them
- Check if paging limits haven't been hit → continue paging
- Check if more unique URLs are being found → keep collecting
- Only if ALL terms are exhausted AND paging is complete AND dedupe is applied → then consider stopping

**Any message that ends with a question asking permission to proceed is a violation of this SOP.**

If you complete all work properly, simply report the results. Do not ask if they want more.

## 8. FALSE-COMPLETION AUDIT BEFORE MARKING A COMPANY COMPLETED

Before changing a company in Daily Targets to Completed, you must internally verify all of the following:

- [ ] Did I run all 10 approved terms?
- [ ] Did I verify company filter context before each search?
- [ ] Did I continue paging/scrolling each term until SOP stop condition was met?
- [ ] Did I dedupe against Updated Format column F?
- [ ] Did I avoid relying on row position alone?
- [ ] Did I avoid stopping just because I had "enough" contacts?
- [ ] Did I avoid requiring the user to tell me to continue?

If any answer is no, do not mark Completed.
Continue the company loop or mark Blocked only if a real blocker exists.

## 9. UPDATED COMPANY COMPLETION STANDARD

A company may be marked Completed only when all of the following are true:

1. Company status was first set to In Progress with RUN_ID and timestamp
2. All 10 approved terms were attempted
3. Each term was paged/scrolled until:
   - 2 consecutive pages produced 0 new unique LinkedIn URLs
   - OR 10 pages were checked
   - OR LinkedIn explicitly showed no results
4. All discovered people were deduped by LinkedIn URL
5. All new valid people were appended correctly to Updated Format
6. No unresolved page-context, login, relay, or schema uncertainty exists

**Otherwise:**
- keep status as In Progress while work remains
- OR mark Blocked with reason if a hard stop condition occurs

## 10. UPDATED DEFINITION OF FAILURE

The following are failures:

- stopping after a single shallow search pass
- finding around 10 contacts and acting like the company is done
- running only a subset of approved terms without blocker justification
- not paging until SOP stop conditions are met
- waiting for user nudges when more approved search work exists
- treating first-page results as exhaustive coverage
- marking Completed due to inertia rather than evidence
- **asking the user "should I continue?" or any variation seeking permission to proceed**
- **outputting any question that pauses execution waiting for user input**

## 11. REQUIRED PROGRESS TRANSPARENCY

After each company search cycle, report transparently:

- Company name
- RUN_ID
- Approved terms completed so far / 11
- Total unique LinkedIn URLs found so far for this company
- New unique URLs added in this cycle
- Terms attempted in this cycle
- Whether paging stop conditions were met for those terms
- Remaining approved terms not yet run
- Whether continuing or stopping, and why

**Example decision language:**
- "Continuing: 5 of 10 approved terms remain, and latest cycle added 7 new unique LinkedIn URLs"
- "Continuing: all terms run, but last term has not yet met 2 consecutive pages with 0 new URLs"
- "Stopping: all 10 terms completed, paging exhausted per SOP, later pages returned only duplicates/no new URLs"
- "Blocked: LinkedIn session lost after term 8; company left Blocked with reason"

## 12. PHASE 2 PERSISTENCE RULE

This same persistence principle applies to ZoomInfo enrichment, while preserving all row-identity rules.

For rows in current RUN_ID where K = Pending:
- do not stop enrichment early because some rows were enriched
- continue until every eligible row from this RUN_ID has K not equal to Pending
- never trust row position alone
- always locate by LinkedIn profile URL in column F
- verify company name and full name before write-back
- if ambiguous, mark appropriately instead of guessing
- if no confident match is found, use the SOP Not Found handling exactly

**Phase 2 is incomplete while any current-run row still has K = Pending unless a blocker stops execution.**

## 13. DO NOT REWIRE AWAY FROM THE SOP — REWIRE INTO IT

Important:
- You are NOT authorized to abandon the SOP.
- You are authorized and required to execute it more rigorously.

That means:
- preserve two-phase structure
- preserve allowed tabs
- preserve schema and status values
- preserve dedupe key = LinkedIn profile URL
- preserve row identity rules
- preserve approved search terms only
- preserve blocker handling
- strengthen persistence
- strengthen completion standards
- strengthen continuation behavior

## 14. EXECUTION PRINCIPLE

Optimize for thoroughness, determinism, and autonomous continuation.

**Your standard is NOT:**
"Did I get a handful of names?"

**Your standard IS:**
"Did I fully execute the allowed SOP search space for this company before stopping?"

If not, continue.

Apply this to every company in the run.

---

## ZOOMINFO: IT DEPARTMENT FILTER METHOD (CRITICAL DISCOVERY)

The standard name-based search in ZoomInfo frequently fails even when contacts exist. The following method is more reliable and was used to find contacts that name searches missed (Jeff Christiano, Rimsha Malik, Michael Radziemski, Lin Connors, Stuart Eichenbaum, Helen Horan at FHLB NY).

### The Method: Company Page → Employees → IT Department Filter

**Step 1: Navigate to the company in ZoomInfo**
- Go to `https://app.zoominfo.com/#/apps/profile/company/{companyId}`
- Or search for the company name in ZoomInfo and click through to the company page
- The company ID for FHLB NY is `53119149`

**Step 2: Click the Employees tab**
- On the company profile page, click "Employees" tab
- This shows all employees ZoomInfo has indexed for that company

**Step 3: Filter by Information Technology department (CRITICAL)**
- Look for a department filter/pill on the employees list
- Click to expand department options
- Select "Information Technology" 
- This narrows to the IT staff most relevant for SRE/DevOps/Infrastructure/Observability targeting
- For FHLB NY, this yielded 59 IT contacts vs. hundreds of total employees

**Step 4: Browse the filtered list**
- The filtered list view shows contact cards with:
  - Name and title
  - Email button (green ✅ = has email, grey = no email)
  - Direct Phone button (green ✅ = has direct phone)
  - Mobile button (green ✅ = has mobile)
- Scan for target contacts by name and title
- Click any contact card to open their profile

**Step 5: Extract contact data from profile**
- Navigate to `https://app.zoominfo.com/#/apps/profile/person/{profileId}/contact-profile`
- The profile ID is visible in the URL when you click a contact in the list
- Contact profile shows:
  - Emails section: [B] business email, [S] personal/social email
  - Phone section: (D) direct, (HQ) main office, (M) mobile
  - Notice Provided Date: watch for this — indicates if person is leaving

### Why This Works When Name Searches Fail

| Approach | Problem |
|----------|---------|
| Quick search by name | Returns wrong people with same name; sometimes no results even when contact exists |
| Advanced search with name + company | Confidence filter (75-99%) excludes valid contacts; company name mismatch causes false negatives |
| Company → Employees → IT department filter | Shows all IT staff at once; contact data visible in list; bypasses name search entirely |

### Profile ID Navigation Trick

Once you see a contact in search results, note their profile ID from the URL:
- Click the contact to open their profile
- The URL will be: `https://app.zoominfo.com/#/apps/profile/person/{profileId}`
- You can navigate directly to `https://app.zoominfo.com/#/apps/profile/person/{profileId}/contact-profile`
- This is more reliable than the ZoomInfo SPA's own navigation

### Key Profile IDs for FHLB NY (for reference)
These were confirmed in the March 27 session:
- Adam C. Houhoulis: `3134663802`
- Bernard A. DeSiena: `1679293651`
- Stuart Eichenbaum: `10408509088`
- Helen Horan: `1911380781`
- Lin Li Connors: `2377013795`
- Michael L. Radziemski: `1240318826`
- Mahlon H. Greene: `1931319905`
- Jeff Christiano: `2881375345`
- Rimsha Malik: `2187062842`

### Departure/Notice Flags
ZoomInfo profiles show "Notice Provided Date" — contacts with recent notice dates are leaving:
- Jason Kannenberg: Opt Out → likely already left
- Michael Radziemski: Notice April 16, 2024 → working under notice for ~2 years (still employed)
- Lin Connors: Notice January 11, 2024 → over 2 years under notice
- Mahlon Greene: Notice January 2026
- Rimsha Malik: Notice January 2026
- Adam Houhoulis: Notice February 2026
- Helen Horan: Notice March 2024 → still employed over 1 year later

When enriching, note these in column N (Notes) if relevant to the campaign.

### Integration with SOP

This IT-department-filter method supplements (not replaces) the name-based search in Phase 2. Use it when:
- Name search returns no results for a contact that should exist
- You want a comprehensive scan of all IT staff at a target company
- The contact has a common name that returns wrong matches

**Always try BOTH methods before marking a contact "Not Found":**
1. First: name-based Advanced Search with confidence filter set to "All contacts"
2. Then: company → Employees → IT department filter to find by browsing
3. Only if BOTH methods fail → mark "Not Found"

---

## QUICK REFERENCE: INSTEAD OF ASKING "SHOULD I CONTINUE?"

| ❌ DON'T SAY | ✅ INSTEAD DO |
|-------------|---------------|
| "Should I continue with more terms?" | Run the next unrun term from the 11-term list |
| "Would you like me to keep going?" | Check if paging limits hit; if not, continue paging |
| "Do you want me to proceed?" | Check remaining approved terms, then continue autonomously |
| "Should I move to the next company?" | Verify all 10 terms exhausted per SOP completion rules first |
| "Can I stop here?" | Only stop after meeting explicit SOP stop conditions |

**The only valid stopping conditions are:**
1. All 10 approved terms run AND paging exhausted (2 consecutive pages with 0 new URLs OR 10 pages)
2. A hard blocker (login lost, captcha, schema mismatch, etc.)
3. Company explicitly marked as Blocked

**ZoomInfo confidence score filter warning:**
- If ZoomInfo shows "No Results Found" but the contact should exist, CHECK THE CONFIDENCE SCORE FILTER
- Default is 75-99% which EXCLUDES valid contacts with lower confidence
- Switch to "All contacts" (50-100%) before declaring "Not Found"
- This is the #1 reason valid contacts are missed

**When in doubt, keep going. The SOP has you covered.**
