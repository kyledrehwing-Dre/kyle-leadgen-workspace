#!/bin/bash
# ZoomInfo enrichment batch script for Morgan Stanley + Navy Federal Credit Union
# Reads names from sheet, searches ZoomInfo, writes back H/I/K

SPREADSHEET="18lfYgX03Q1sw9uLm-kSeutcNeyigjXQElSjatYbjgUI"
GOG_ACCOUNT="Kyle.Drehwing@gmail.com"
TAB="'Updated Format'"
BROWSER_TARGET="6F7CDFAAD4FD6664BA3C5BBF9992F94B"

log() { echo "[$(date '+%H:%M:%S')] $1"; }

find_contact() {
    local name="$1"
    local company="$2"
    local row="$3"
    
    log "Row $row: Searching $name at $company"
    
    # Click search box, clear, type query
    osascript -e 'tell application "Google Chrome" to activate' 2>/dev/null
    return 1  # fallback - let browser tool handle it
}

# Main loop
log "Starting ZoomInfo enrichment batch"
log "Morgan Stanley: 52 contacts, Navy Federal: 13 contacts"
log "Total: 65 contacts"
