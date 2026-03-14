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
- Stay in the same LinkedIn session.
- Do not open extra LinkedIn sessions.
- Reuse the same LinkedIn page flow for every company.
- If Chrome relay is not attached to an active LinkedIn tab, stop and ask the user to attach the tab.

### Canonical LinkedIn search path
For each target company and each approved term:
1. Open `https://www.linkedin.com/search/results/people/`
2. Confirm domain is `www.linkedin.com` and user is logged in.
3. Ensure People search context is active.
4. Open All Filters.
5. Set `Current company = <target company>`.
6. Set keyword/title query to one approved term.
7. Apply filters.
8. Confirm current-company filter chip is visible before each page/scroll.

Do not rely on loose global search without confirmed company context.

### Company status updates in Phase 1
For each company:
1. Before first term, set `Daily Targets` status (column C) to `In Progress`, set D=RUN_ID, set E=current timestamp.
2. After all 13 terms finish (or hard stop), update status to `Completed` or `Blocked`.
3. Write blocker reason in column F when status is `Blocked`.

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
For each of the 13 terms, continue paging or scrolling until one stop condition is met:
- 2 consecutive pages produce 0 new unique LinkedIn URLs
- OR 10 pages have been checked
- OR LinkedIn shows no results

Do not stop early just because a few names were found.

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
Move to next company only after all 13 approved terms are completed for current company, or company is explicitly marked `Blocked`.

## Phase 2 - ZoomInfo enrichment

### Which rows to process
Process rows in `Updated Format` where:
- M (Run ID) = current RUN_ID
- and K (ZoomInfo Phase Status) = `Pending`

Do not process unrelated historical rows in this phase.

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
1. locate destination row by LinkedIn URL in column F
2. verify Company Name and Full Name still match intended record

Then write:
- Email address to column H
- Mobile phone number to column I
- ZoomInfo Phase Status to column K (`Enriched` or `Not Found`)
- Last Updated At to column L
- Run ID to column M (same RUN_ID)
- Notes to column N when blocked/ambiguous

### Missing-data rule
- If email is missing, write `No Email` in H
- If mobile phone is missing, write `No Phone` in I
- If contact cannot be found confidently, write `Not Found` in both H and I and set K=`Not Found`
- If at least one real contact field is found with confident match, set K=`Enriched`

### Post-write verification
After every write:
- re-locate the same row by LinkedIn URL
- re-read H, I, K
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

This patch strengthens execution standard, continuation behavior, and definition of completion.
All original schema, tab, status, row-identity, and safety constraints remain in force unless explicitly overridden below.

## 1. NON-NEGOTIABLE RULE: 10 CONTACTS IS NOT COMPLETION

If you find 10 contacts for a company, that is never by itself evidence of completion.

Treat any batch of 10 as a likely intermediate retrieval state unless you have strong evidence that:
- all 13 approved terms were fully run
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
- all 13 approved terms have been attempted
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
- run all 13 approved terms
- verify current company filter chip is visible for every search
- continue paging/scrolling for each term until the SOP stopping rule is actually met
- dedupe against existing LinkedIn URLs in Updated Format column F
- do not stop after the first useful term
- do not stop after the first page unless no-results is explicit
- do not collapse the remaining terms just because some overlap is expected

## 4. MANDATORY TERM-BY-TERM COMPLETION

For each company, all of the following approved terms must be attempted unless a hard blocker occurs:

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

## 8. FALSE-COMPLETION AUDIT BEFORE MARKING A COMPANY COMPLETED

Before changing a company in Daily Targets to Completed, you must internally verify all of the following:

- [ ] Did I run all 13 approved terms?
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
2. All 13 approved terms were attempted
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

## 11. REQUIRED PROGRESS TRANSPARENCY

After each company search cycle, report transparently:

- Company name
- RUN_ID
- Approved terms completed so far / 13
- Total unique LinkedIn URLs found so far for this company
- New unique URLs added in this cycle
- Terms attempted in this cycle
- Whether paging stop conditions were met for those terms
- Remaining approved terms not yet run
- Whether continuing or stopping, and why

**Example decision language:**
- "Continuing: 5 of 13 approved terms remain, and latest cycle added 7 new unique LinkedIn URLs"
- "Continuing: all terms run, but last term has not yet met 2 consecutive pages with 0 new URLs"
- "Stopping: all 13 terms completed, paging exhausted per SOP, later pages returned only duplicates/no new URLs"
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
