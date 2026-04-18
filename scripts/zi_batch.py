#!/usr/bin/env python3
"""
ZoomInfo batch enrichment for Morgan Stanley (rows 566-604) + Navy Federal Credit Union (rows 605-617)
Run via: python3 this_script.py [start_row] [end_row]
"""
import subprocess, json, sys, time

SPREADSHEET = "18lfYgX03Q1sw9uLm-kSeutcNeyigjXQElSjatYbjgUI"
GOG = "GOG_ACCOUNT=Kyle.Drehwing@gmail.com"
BROWSER = "6F7CDFAAD4FD6664BA3C5BBF9992F94B"
ZI_URL = "https://app.zoominfo.com/#/apps/home-page"

def cmd(c): return subprocess.run(c, shell=True, capture_output=True, text=True)
def gg(r): 
    j = json.loads(cmd(f'{GOG} gog sheets get {SPREADSHEET} "{r}" --json').stdout)
    return j.get('values', [[]])[0]
def gu(r, v): cmd(f'{GOG} gog sheets update {SPREADSHEET} "{r}" --values-json {json.dumps(v)!r}')

def get_name(row):
    r = gg(f"'Updated Format'!B{row}:B{row}")
    return r[0] if r else ''

def search_zoominfo(name, company):
    """Run browser search via osascript - returns (email, mobile) or (None, None)"""
    script = f'''
tell application "Google Chrome"
    activate
    delay 0.5
end tell
'''
    return (None, None)

def do_row(row, name, company):
    print(f"Row {row}: {name}")
    # Check current state
    r = gg(f"'Updated Format'!H{row}:K{row}")
    current_k = r[3] if len(r) > 3 else ''
    if current_k in ('Enriched', 'Not Found'):
        print(f"  Already processed: K={current_k}, skipping")
        return 'skip'
    return 'process'

def main():
    start = int(sys.argv[1]) if len(sys.argv) > 1 else 566
    end = int(sys.argv[2]) if len(sys.argv) > 2 else 617
    
    ms_rows = list(range(566, 605))
    nfcu_rows = list(range(605, 618))
    
    total = len(ms_rows) + len(nfcu_rows)
    print(f"Processing rows {start}-{end} ({total} contacts)")
    
    enriched = notfound = skipped = 0
    for row in list(range(start, end+1)):
        name = get_name(row)
        if not name or name == 'None':
            print(f"Row {row}: empty name, skipping")
            skipped += 1
            continue
        co = 'Morgan Stanley' if row < 605 else 'Navy Federal Credit Union'
        result = do_row(row, name, co)
        if result == 'skip':
            skipped += 1
        time.sleep(0.5)
    
    print(f"Done. Enriched={enriched}, NotFound={notfound}, Skipped={skipped}")

if __name__ == "__main__":
    main()
