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
- **Blocker response:** Stop, explain, ask Kyle

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
- Append to `Run Summary` tab: Run ID, Targets, Leads Found, Enriched, Skipped, Start, End, Notes
- Write to `memory/YYYY-MM-DD.md`

### Dedupe Rule
- LinkedIn URL is unique key

### Done Definition
- Leads written to Google Sheets
- Run Summary appended

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
