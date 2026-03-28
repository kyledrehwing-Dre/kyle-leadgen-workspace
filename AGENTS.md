# AGENTS.md - Pipeline Definition

## Core Pipeline: Onboard → Collect → Match → Merge → Upsert → Log → Resume

### Onboarding
- Ask Q1: Target companies
- Ask Q2: Target titles/keywords
- Ask Q3: ZoomInfo access mode
- Ask Q4: LinkedIn session method
- Ask Q5: Google Sheets URL/ID
- Verify sheet access

### Collect (LinkedIn)
- Use browser with Kyle's logged-in session
- Search People by company × fixed title list
- Title list (always use these): IT operations, SRE, Cloud Operations, DevOps, Infrastructure, Enterprise Architecture, Application Support, Production Support, Observability, Site Reliability Engineer, Change Management, Incident management, AI
- **ALWAYS open FULL profile** to capture: Name, Title, Company, Location, LinkedIn URL, Headline, Summary, Experience, Education
- Collect all available fields from profile
- **NEVER ask "should I continue"** - Continue autonomously until all 10 terms are exhausted AND paging stops yielding new results
- **Blocker response:** Stop, explain, ask Kyle

### ⚠️ MANDATORY COVERAGE (NEVER SKIP)
**For each company, you MUST run ALL 10 terms:**
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

**Completion = ALL 10 terms attempted + paging exhausted.**
- 10 contacts is NOT completion
- "Enough contacts found" is NOT completion
- You must mark company done only after all 10 terms searched with proper paging (2 consecutive empty pages OR 10 pages)

### Match (ZoomInfo)
- Search ZoomInfo by name + company
- Extract: Email, Phone, Direct Dial, ZoomInfo URL, Company Domain, Industry, Size, Revenue
- Assign match_confidence (0-100)
- **If not found:** Mark as "Not found in ZoomInfo" — proceed with LinkedIn data

### Merge
- Single record per person
- Add: linkedin_collected_at, zoominfo_enriched_at, match_confidence, quality_score

### Upsert to Google Sheets
- **Unique key:** LinkedIn URL
- IF exists → update missing/weaker fields only
- IF new → append row
- **Never delete data, never overwrite verified data**

### Run Summary
- Write to `memory/YYYY-MM-DD.md` (NOT to a spreadsheet tab)

### Dedupe Rule
- LinkedIn URL is unique key

### Row Finding Safety Rules (CRITICAL)
Before adding ANY new contacts to Updated Format, ALWAYS follow these steps:

1. **Find last row with data FIRST**
   - Query column A (Company Name) to find the last non-empty row
   - Do NOT assume the sheet ends at a specific row number
   - The sheet may have data at high row numbers (e.g., row 3210+)

2. **Check for existing company contacts**
   - Before adding, search column F (LinkedIn URL) for any existing contacts from the same company
   - If company already has contacts, append after the last one for that company

3. **Verify destination row is empty**
   - Read the destination range BEFORE writing to confirm it's truly empty
   - Check all columns (A through N) are blank

4. **Never assume end of sheet is empty**
   - Rows beyond 3000 may contain data from previous runs
   - Always query to find actual last row

5. **Validate before write**
   - Confirm row number is sequential to last existing data
   - Verify Company Name and LinkedIn URL columns are blank

If destination row cannot be verified as empty, STOP and report to Kyle instead of guessing.

### Done Definition
A company is Completed ONLY when ALL of:
- [ ] All 10 approved terms were attempted for the company
- [ ] Each term was paged until stop condition met (2 consecutive pages with 0 new URLs, OR 10 pages)
- [ ] All discovered people were deduplicated by LinkedIn URL
- [ ] All new valid people were appended to Updated Format with correct status
- [ ] Company status in Daily Targets set to `Completed` with RUN_ID and timestamp
- [ ] Phase 2 completed: all K=Pending rows from this run resolved to Enriched or Not Found
- [ ] Run summary written to `memory/YYYY-MM-DD.md`

**NEVER stop after finding a handful of contacts. 10 contacts is NOT completion evidence.**

### Target Persona Context (Evolven)
- **Ideal Persona:** IT executives (VP Engineering, Director, CTO, CIO, CISO) who care about:
  - Organizational risk
  - Security
  - Audit
  - Configuration management
  - IT operations reliability
- **Pain Point:** 90%+ of outages, incidents, breaches caused by config changes/misconfigs
- **Value Prop:** Evolven collects every config in IT estate, reports every change

## LinkedIn / ZoomInfo workflow rule

When a task involves LinkedIn -> Google Sheet -> ZoomInfo enrichment, always load and follow the `linkedin_zoominfo_sop` skill.

**IMPORTANT:** Also load and follow the EXHAUSTIVE COVERAGE PATCH embedded in the skill (Sections 0-14). This patch enforces:
- 10 contacts is NOT completion
- Loop execution (not one-shot pass)
- Mandatory term-by-term completion (all 10 terms)
- Strict paging rules
- Coverage-gap assessment
- Autonomous continuation (no user nudges)
- False-completion audit before marking done
- Phase 2 persistence rule

Validation check (run at start of each LinkedIn/ZoomInfo task):
- `bash scripts/validate_linkedin_zoominfo_sop.sh`
- if validation fails, stop and report before doing any browser or sheet actions

Do not improvise or switch methods mid-run.
Use two phases only:
1. LinkedIn + Google Sheet
2. ZoomInfo + Google Sheet

Tab control is strict:
- only use `Daily Targets` and `Updated Format`
- do not read/write any other tab unless user explicitly asks

Status columns are mandatory:
- `Daily Targets` column C = Target Status (`Pending|In Progress|Completed|Blocked|Skipped`)
- `Updated Format` column J = LinkedIn Phase Status
- `Updated Format` column K = ZoomInfo Phase Status

Never write ZoomInfo data by row number alone.
Locate destination row by LinkedIn profile URL, then verify Company Name and Full Name before writing.

Use canonical LinkedIn people-search with `Current company = <target company>` always applied.
Do not open unnecessary tabs or sessions.
Do not duplicate LinkedIn profile URLs.

If page context, login state, Chrome relay attachment, required tabs/columns, or destination row identity cannot be verified, stop and report instead of guessing.
