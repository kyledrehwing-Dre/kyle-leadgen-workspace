# ZoomInfo Batch Enrichment SOP (Phase 2)

## Purpose
This SOP covers Phase 2 of the lead generation workflow: enriching contact records in Google Sheets with ZoomInfo data (email, phone) using a batch search approach.

**Recommended Method: Option 2** - Search ZoomInfo by company + job titles, export batch, then update Google Sheet.

## When to Use This SOP
- Phase 1 (LinkedIn) is complete for a company
- Google Sheet `Updated Format` tab has contacts with `Pending` in column K (ZoomInfo Phase Status)
- You need to enrich email and mobile phone number fields

## Prerequisites
- [ ] Target company marked "In Progress" in Daily Targets
- [ ] LinkedIn Phase complete (column J = "Added")
- [ ] ZoomInfo account with credits
- [ ] Browser with ZoomInfo access (logged in)

## Run Identity
Create `RUN_ID = YYYYMMDD-HHMMSS` at start of each enrichment session.

---

## Step 1: Identify Rows Needing Enrichment

1. Open Google Sheet
2. Go to `Updated Format` tab
3. Filter/search for:
   - Column A = target company
   - Column K = "Pending" (or empty)

4. Extract the list of names to enrich:
   - Full Name (column B)
   - Job Title (column E)
   - Company Name (column A)
   - LinkedIn URL (column F) - for matching later

**Example extraction (save to temp file for reference):**
```
Row | Name | Title | LinkedIn URL
1458 | Sairam Peddineni | SRE | https://linkedin.com/in/...
1459 | Abbas Husain | DevOps | https://linkedin.com/in/...
```

---

## Step 2: Batch Search in ZoomInfo

### Method A: Company + Title Search (Recommended)

1. Open ZoomInfo: https://app.zoominfo.com/people-search
2. Click "Clear All" filters
3. Set Company filter = target company (e.g., "Intercontinental Exchange")
4. Set Title/Keyword filter = relevant title term
5. Click Search

**Search order by efficiency:**
1. Run one company search with multiple title keywords
2. Export results to CSV

### Method B: Name List Upload (If Available)

Some ZoomInfo tiers support bulk upload:
1. Look for "Bulk" or "Enrich" in ZoomInfo menu
2. Upload list of names + companies
3. Wait for processing
4. Download enriched results

---

## Step 3: Process Export Results

When you get a ZoomInfo export (CSV/Excel), it typically contains:
- Name
- Email
- Phone
- Direct Dial
- Company
- Title
- Location

**Matching Logic (Critical):**

Match ZoomInfo results to Sheet rows using:
1. **Primary:** Full Name (exact or close match) + Company Name (exact)
2. **Secondary:** Company + Job Title similarity
3. **Tertiary:** LinkedIn URL if available in export

**Match Priority:**
```
IF exact name + exact company = CONFIDENT MATCH
ELSE IF close name + exact company = VERIFY (check title/location)
ELSE = NO MATCH
```

---

## Step 4: Write-Back to Google Sheet

**CRITICAL: Never write by row number alone. Locate by LinkedIn URL first.**

### For Each Matched Contact:

1. **Find the row:**
   - In `Updated Format`, search column F for LinkedIn URL
   - OR search columns A+B for Company + Full Name
   
2. **Verify before writing:**
   - Confirm Company Name matches (column A)
   - Confirm Full Name matches (column B)
   - Only then write data

3. **Write these columns:**
   - Column H (Email): `{email from ZoomInfo}` or "No Email"
   - Column I (Mobile): `{phone from ZoomInfo}` or "No Phone"
   - Column K (ZoomInfo Phase Status): "Enriched"
   - Column L (Last Updated At): Current timestamp
   - Column M (Run ID): RUN_ID

### For Non-Matches:

1. **Find the row** by LinkedIn URL
2. Write:
   - Column H: "Not Found"
   - Column I: "Not Found"
   - Column K: "Not Found"
   - Column L: Current timestamp
   - Column M: RUN_ID

### For Ambiguous Matches:

If multiple ZoomInfo results could match one person:
1. Do NOT guess
2. Write "Ambiguous" in column N (Notes)
3. Set K = "Blocked"
4. Report to user for manual resolution

---

## Step 5: Post-Write Verification

After writing each contact:
1. Re-locate the row by LinkedIn URL
2. Verify columns H, I, K contain expected values
3. If mismatch, correct immediately

---

## Step 6: Complete Company

When all rows for company are enriched (K ≠ "Pending"):

1. Update `Daily Targets`:
   - Column C (Target Status): "Completed"
   - Column D (Run ID): RUN_ID
   - Column E (Last Updated At): timestamp
   - Column F (Notes): "Phase 2 complete - X enriched, Y not found"

---

## Error Handling

**STOP and REPORT if:**
- ZoomInfo not logged in
- Credits exhausted
- Export fails repeatedly
- Cannot locate destination row by LinkedIn URL
- 3 consecutive mismatches

**Do NOT:**
- Guess email/phone data
- Write to wrong row
- Skip verification step

---

## Completion Criteria

Phase 2 is complete when:
- [ ] All rows for company have K ≠ "Pending"
- [ ] Each row has H (Email) populated or marked appropriately
- [ ] Each row has I (Mobile) populated or marked appropriately
- [ ] Company marked "Completed" in Daily Targets
- [ ] Run summary written

---

## Run Summary Template

```
RUN_ID: 20260317-101500
Company: Intercontinental Exchange
Phase: 2 (ZoomInfo Enrichment)

Contacts Processed: 53
- Enriched: 12
- Not Found: 41
- Ambiguous/Blocked: 0

Time Start: 10:15 AM
Time End: 10:45 AM
Method: Batch company search + export match
```

---

## Quick Reference: Column Mapping

| Column | Field | Source |
|--------|-------|--------|
| A | Company Name | From LinkedIn |
| B | Full Name | From LinkedIn |
| C | Last Name | Parsed |
| D | First Name | Parsed |
| E | Job Title | From LinkedIn |
| F | LinkedIn URL | From LinkedIn |
| G | Location | From LinkedIn |
| H | Email address | **ZoomInfo** |
| I | Mobile phone | **ZoomInfo** |
| J | LinkedIn Phase Status | Already set |
| K | ZoomInfo Phase Status | **Set to Enriched/Not Found** |
| L | Last Updated At | Timestamp |
| M | Run ID | RUN_ID |
| N | Notes | If blocked/ambiguous |

---

## Alternative: Option 1 (Individual Extension Method)

If Option 2 not available, use this fallback:

1. Open Google Sheet
2. Click LinkedIn URL in column F → Opens LinkedIn profile
3. Look for ZoomInfo extension icon in browser toolbar
4. Click extension → Opens ZoomInfo record (if found)
5. Copy email/phone
6. Manually paste to columns H/I
7. Set K = "Enriched"
8. Repeat for each row

**Warning:** This is ~30 seconds per contact. Use only when batch method unavailable.
