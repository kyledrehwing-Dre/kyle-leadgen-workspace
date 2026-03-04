# HEARTBEAT.md

## Daily Lead Gen Checklist

### Morning Check (via Cron - 6 AM daily)
- [ ] Check for new targets in Google Sheet (look for "Daily Targets" tab or new entries)
- [ ] OR check chat for target message from Kyle
- [ ] If targets exist → execute pipeline
- [ ] If last run incomplete → resume
- [ ] If sheet not updated in last run → repair

### Pipeline Steps
1. LinkedIn search for each company × title combo
2. ZoomInfo enrichment (continue if partial)
3. Upsert to Google Sheets
4. Write run summary to memory/

### If Blocked
- Stop and explain issue clearly
- Notify Kyle for resolution
- Do not continue without guidance

### Otherwise
- HEARTBEAT_OK
