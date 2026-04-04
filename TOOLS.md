# TOOLS.md - Tools & Methods
SPEC_VERSION: leadgen-canonical-v3

## Browser Automation
- **Tool:** `browser` (OpenClaw browser control)
- **Use for:** LinkedIn, Sales Navigator, ZoomInfo
Browser session rule: try to attach to Kyle's existing logged-in Chrome session if available; otherwise spawn a dedicated agent-owned browser session/profile. Once a session is verified for the run, use that same verified session consistently for the run. Do not assume a profile name without verification.
- **Verification sequence:** confirm the attached session is already logged into LinkedIn, then confirm ZoomInfo login, then record the actual profile/session used in the execution ledger.
- **Preferred LinkedIn path:** verified LinkedIn / Sales Navigator path if session and filters work.
- **Fallback A:** standard LinkedIn company people path with verified company context.
- **Fallback B:** company-page / associated-members browsing when people-search returns false zero or is anti-automation blocked.
- **Rule:** False zero != no people.
- **Rule:** Company ambiguity is a blocker.
- **Rule:** Always open the full profile for every kept contact.
- **Rule:** Do not switch methods silently; log the exact reason when falling back.

## Two separate jobs
### Job 1 — LinkedIn capture
- Systems allowed: LinkedIn + Google Sheets
- Goal: discover contacts and write/refresh sheet rows
- Output state: `K=Pending`
- Do not do ZoomInfo enrichment here

### Job 2 — ZoomInfo enrichment
- Systems allowed: ZoomInfo + Google Sheets
- Goal: enrich existing sheet rows only by filling column `H` (work email) and column `I` (mobile phone)
- Input state: existing rows, preferably `K=Pending`
- Do not do LinkedIn discovery or append brand-new contacts here
- Execution mode only: do not stop mid-task, do not send progress updates, do not switch into explanation mode
- Continue until all targeted rows for the active company are completed or a real blocker occurs
- Before writing anything, confirm the matched ZoomInfo contact matches sheet column `B` (allowing approved nickname/full-name variants only)
- Before every write, re-check the destination row identity; after every write, verify the exact row and values immediately
- Final user-visible output should happen only at the end of the company/job unless blocked
- Execution Control Rules (MANDATORY — NO EXCEPTIONS): CONTINUATION IS REQUIRED once you begin; STOPPING IS A FAILURE unless all rows done, real blocker, or told to stop; NO INTERMEDIATE RESPONSES; SELF-CHECK before any reply (is job complete or blocked? if no, continue); COMPANY LOOP LOCK (finish all contacts for a company before stopping); EXECUTION MODE OVERRIDE (only Working or Finished states); FINAL OUTPUT ONLY (Job complete + rows updated, or blocker explanation); INCORPORATE-AND-CONTINUE RULE (when the user provides updated execution rules during an active job, incorporate them immediately and continue the active company/job without pausing for confirmation or row-by-row replies unless blocked); SPEED CONTROL (MANDATORY): wait 1–2s after ZoomInfo search, opening contact, copying email/phone, writing to sheet; wait 2s after each row; BATCH RULE: after every 10 rows pause 20–30s; COMPANY TRANSITION RULE: wait 3–5s before searching new company; RETRY RULE: if action fails wait 3–5s retry once only then treat as blocker; RATE LIMIT RULE: if "API rate limit reached" stop immediately wait 60–120s resume from last completed row at slower pace; WRITE ACCURACY RULE: confirm Column B matches before writing confirm correct row after writing fix mismatch immediately; MENTAL MODEL: work steadily do not stop do not talk finish the job

## gog (Google Sheets)
- **Tool:** `exec` -> `gog` CLI
- **Auth:** Already configured for Kyle.Drehwing@gmail.com
- **Commands:**
  - `gog sheets metadata <id>` - verify tabs
  - `gog sheets get <id> "Range" --json` - read
  - `gog sheets update <id> "Range" --values-json '...'` - targeted write
  - `gog sheets append <id> "Range" --values-json '...'` - append after verification

## Sheet invariants
- Only operate these tabs: `Daily Targets` and `Updated Format`.
- Datastore = Google Sheets only.
- Dedupe key = LinkedIn URL.
- Locate writeback rows by LinkedIn URL first, then verify Company Name + Full Name.
- Never write ZoomInfo data by row number alone.
- Never assume end-of-sheet is empty.
- Verify destination row/range before append/update.
- Never overwrite verified data with weaker data.
- Never delete data.
- Post-write verification: re-locate the row by LinkedIn URL and confirm written values match.
Never ask the user for permission to continue while valid work remains.
Phase 2 remains incomplete while any current-run row has `K=Pending` and no real blocker exists.

## Status invariants
- `Daily Targets` column C: Pending | In Progress | Completed | Blocked | Skipped
- `Updated Format` column J: Added | Duplicate-Skipped | Blocked
- `Updated Format` column K: Pending | Enriched | Not Found | Blocked

## ZoomInfo method
- Primary: Advanced Search -> Clear All -> Contact Name or Email -> Company Name -> widen confidence to All contacts / 50-100 before declaring Not Found.
- Hard anti-improvisation rule: do not use Quick Search, raw result browsing, or profile hopping before completing the Advanced Search field sequence above. When company context is known, apply Company Name before evaluating any candidates.
- Validation gate: a lookup is not valid unless the working path includes all of: Advanced Search used, Clear All used, Contact Name or Email field applied, Company Name field applied when known, and profile opened only after narrowing.
- Required search ladder before `Not Found`:
  - exact full name + company
  - nickname/full-first-name swap
  - without middle initial
  - with middle initial / punctuation variant
- Fallback: company page -> Employees -> Information Technology department.
- Write rule on confident match: `K=Enriched`, `H=(B) or No Email`, `I=(M) or No Phone`.
- Write rule on no confident match after ladder + fallback: `K=Not Found`, `H=Not Found`, `I=Not Found`.
- Never use HQ `(HQ)` or direct `(D)` phone in place of mobile `(M)` for column `I`.
- Before writing `Not Found`, open any obvious ZoomInfo candidate that matches full name + company context. Do not declare `Not Found` while an obvious unopened candidate remains in results.
- Optional accelerator: batch export or bulk enrichment is allowed only when exact row mapping is proven by LinkedIn URL first, then Company Name + Full Name.

### ZoomInfo Contact Profile extraction — mobile-first verification
ZoomInfo innerText returns phone/email values on one line and their `(B)`, `(M)`, `(D)`, `(HQ)` labels on the next line. The `\n` IS present between the value and label.

**ZoomInfo phone section format (verbatim from browser):**
```
Phone numbers
(646) 447-6646
(D)
Call
(646) 447-5000
(HQ)
Call
(347) 504-5895
(M)
Call
```

**Mandatory mobile logic:** simply find the exact `(M)` in the Phone numbers block.

```javascript
const phoneSection = (txt.match(/Phone numbers[\s\S]{0,800}/i) || [''])[0];
const lines = phoneSection.split('\n').map(s => s.trim()).filter(Boolean);
let mobile = null;
for (let i = 0; i < lines.length; i++) {
  if (lines[i] === '(M)') {
    mobile = lines[i - 1] || null;
    break;
  }
}
```

Rules:
- Find the exact `(M)` line.
- Use the line immediately above `(M)` for column `I`.
- If there is no exact `(M)` anywhere in the full Phone numbers block, then write `No Phone`.
- Never use `(D)` or `(HQ)` as substitutes.

**Business Email (B):**
```javascript
txt.match(/([A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,})\s*\n\(B\)/i)
```

**Rejection rule:** If ZoomInfo returns a contact whose name does not match the sheet Full Name (ignoring middle initials and nicknames), reject the match entirely. Mark `K=Not Found` instead.

## Memory
- **Tool:** write to `memory/YYYY-MM-DD.md`
- **Content:** run summaries, blockers, repair notes, exact next action or stop reason
