# TOOLS.md - Tools & Methods

## Browser Automation
- **Tool:** `browser` (OpenClaw browser control)
- **Use for:** LinkedIn People search, ZoomInfo search
- **Profile:** Use Kyle's existing Chrome session (profile="chrome")

## gog (Google Sheets)
- **Tool:** `exec` → `gog` CLI
- **Auth:** Already configured for Kyle.Drehwing@gmail.com
- **Commands:**
  - `gog sheets get <id> "Range" --json` - read
  - `gog sheets update <id> "Range" --values-json '...'` - write
  - `gog sheets append <id> "Range" --values-json '...'` - add rows
  - `gog sheets metadata <id>` - get sheet tabs

### Finding the Correct Row (BEFORE writing)
1. Query last row: `gog sheets get <id> "'Updated Format'!A:A" --json | grep -c "Company"` or iterate to find last non-empty
2. Check existing: `gog sheets get <id> "'Updated Format'!F:F" --json | grep -c "linkedin.com/in/username"`
3. Verify empty: Read destination range BEFORE writing to confirm blank
4. NEVER assume high-numbered rows (3000+) are empty - they may contain data

## Data Merge
- **Tool:** Internal code/parsing
- **Process:** Merge LinkedIn + ZoomInfo fields, calculate quality_score

## Memory
- **Tool:** Write to `memory/YYYY-MM-DD.md`
- **Content:** Run summaries, blockers, what's next
