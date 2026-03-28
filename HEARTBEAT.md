# HEARTBEAT.md

## Daily Lead Gen Checklist

### Morning Check (via Cron - 6 AM daily)
- [ ] Check for new targets in Google Sheet (look for "Daily Targets" tab or new entries)
- [ ] OR check chat for target message from Kyle
- [ ] If targets exist → execute pipeline following linkedin_zoominfo_sop skill + exhaustive coverage patch
- [ ] If last run incomplete → resume from where it left off (check Daily Targets status)
- [ ] If sheet not updated in last run → repair

### Pipeline Steps (MUST FOLLOW EXHAUSTIVELY)
1. **Validation:** Run `bash scripts/validate_linkedin_zoominfo_sop.sh` before starting
2. **Company Loop:** For each target company:
   - Set Daily Targets status to `In Progress` with RUN_ID and timestamp
   - Run ALL 10 approved terms in order:
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
   - For EACH term: page until 2 consecutive pages produce 0 new unique LinkedIn URLs, OR 10 pages checked
   - Dedupe against existing LinkedIn URLs in Updated Format column F
   - Continue until ALL 10 terms are attempted AND paging exhausted
   - **STOP ONLY WHEN:** all terms run + paging exhausted + no new URLs emerging
   - Mark company `Completed` only after meeting completion audit criteria
3. **Phase 2:** ZoomInfo enrichment for all rows where K = Pending from this run
   - Continue until ALL K = Pending rows are resolved (Enriched or Not Found)
4. **Write run summary** to `memory/YYYY-MM-DD.md`

### Completion Audit (MUST PASS BEFORE MARKING DONE)
For each company, verify ALL of:
- [ ] All 10 approved terms were attempted
- [ ] Company filter chip verified before each search
- [ ] Each term paged until stop condition met
- [ ] Dedupe against column F applied
- [ ] No reliance on row position
- [ ] Did NOT stop just because "enough" contacts found
- [ ] Did NOT require user nudges to continue

### If Blocked
- Stop and explain issue clearly
- Set Daily Targets status to `Blocked` with reason in Notes column
- Do NOT mark Completed prematurely

### Otherwise
- If all targets processed and completion audit passed → normal completion
- If no targets found → HEARTBEAT_OK
