# Continuation: 79 remaining rows needing ZoomInfo enrichment

## Context
- Spreadsheet: 18lfYgX03Q1sw9uLm-kSeutcNeyigjXQElSjatYbjgUI
- ZoomInfo browser session: `6F7CDFAAD4FD6664BA3C5BBF9992F94B`
- All rows have K=Added/Collected/LinkedIn Collected in col K (index 10)
- Target: resolve each to Enriched or Not Found

## 79 rows to process
```
744,747,748,752,753,756,757,758,760,762,763,766,767,769,771,772,773,774,776,779,780,781,784,786,787,788,789,790,792,794,797,798,799,802,806,807,808,809,811,813,816,817,820,821,822,823,825,828,831,832,833,835,837,841,842,843,845,855,856,857,858,859,860,861,862,863,864,865,866,867,868,869,870,871,872,873,874,875,876
```

## Companies
- Vanguard: 23 rows (806-845)
- Wyndham Hotels: 22 rows (855-876)
- All others: Vanguard adjacent or separate

## Instructions
1. For each row, read name (col B) from sheet
2. Search "Name Vanguard" or "Name Wyndham Hotels" (company-matched) in ZoomInfo Quick Search
3. If contact found with matching name → click profile → extract (B) email + (M) mobile → write H/I/K=Enriched
4. If not found after search → write K=Not Found, leave H/I as-is (LinkedIn data if present, or blank)
5. Speed: 1-2s after each search, 3s pause after every 10 rows
6. Verify each write before moving on
7. Report final count when done
