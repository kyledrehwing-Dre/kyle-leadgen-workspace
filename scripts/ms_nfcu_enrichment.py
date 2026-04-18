#!/usr/bin/env python3
"""
ZoomInfo enrichment for Morgan Stanley + Navy Federal Credit Union
52 contacts: rows 566-604 (Morgan Stanley) + rows 605-617 (Navy Federal)
"""

import subprocess
import json
import time

SPREADSHEET = "18lfYgX03Q1sw9uLm-kSeutcNeyigjXQElSjatYbjgUI"
GOG_ACCOUNT = "Kyle.Drehwing@gmail.com"

def gog_get(range_str):
    result = subprocess.run(
        f'GOG_ACCOUNT={GOG_ACCOUNT} gog sheets get {SPREADSHEET} "{range_str}" --json',
        shell=True, capture_output=True, text=True
    )
    return json.loads(result.stdout)

def gog_update(range_str, values):
    result = subprocess.run(
        f'GOG_ACCOUNT={GOG_ACCOUNT} gog sheets update {SPREADSHEET} "{range_str}" --values-json {json.dumps(values)!r}',
        shell=True, capture_output=True, text=True
    )
    return result

def main():
    # Load all rows
    data = gog_get("'Updated Format'!A524:K2237")
    vals = data.get('values', [])
    
    # Find Morgan Stanley + Navy Federal rows
    targets = []
    for i, r in enumerate(vals):
        row = 524 + i
        if len(r) < 10: continue
        co = r[0] or ''
        k = r[9] or ''
        j = r[10] if len(r)>10 else ''
        if co in ('Morgan Stanley', 'Navy Federal Credit Union') and k == '' and j == 'Added':
            fn = r[1] or ''
            if fn and fn != 'None':
                targets.append((row, co, fn))
    
    print(f"Total contacts to process: {len(targets)}")
    for row, co, fn in targets:
        print(f"  Row {row}: {co} | {fn}")

if __name__ == "__main__":
    main()
