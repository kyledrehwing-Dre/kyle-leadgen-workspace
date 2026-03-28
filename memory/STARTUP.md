# Startup Behavior

## Browser Session
On session start or receipt of `ensure_browser_session` event:
1. Check browser status: `browser status profile=openclaw`
2. If not running, start: `browser start profile=openclaw`
3. Verify LinkedIn and ZoomInfo tabs are available; if not, open them

This ensures the persistent browser session is always ready for LinkedIn/ZoomInfo workflow tasks.
