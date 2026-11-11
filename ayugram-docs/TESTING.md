# AyuGram iOS test log

Device: iPad Pro 10.5" (iPad7,4), iOS 17.7.11, Dopamine rootless, TrollStore Lite.
Accounts: `nash` and `luki`, both logged in to the same app install.
A feature counts as done only when its row says PASS.

## How builds get onto the device

1. `gh workflow run build.yml -R feendly/ayugram-ios --ref ayugram`
2. `gh run download <run> -n ipas-encrypted`, decrypt with the key in `F:\ayugram-ios\.artifact-key`
   (`openssl enc -d -aes-256-cbc -pbkdf2`).
3. `scp AyuGram.ipa mobile@192.168.2.22:/var/mobile/Documents/`
4. `uiopen --url "apple-magnifier://install?url=file:///var/mobile/Documents/AyuGram.ipa"`,
   then tap Install in TrollStore Lite through noVNC (Chrome).

## Results

"Log" means the app's own `ayu-debug.log`; "observed" means seen from the other account.

| # | Feature | Build | Steps | Expected | Actual | Result |
|---|---|---|---|---|---|---|
| 0 | Baseline: unmodified app installs and runs | run 42944143598 | Install, launch, log in | Telegram 13.2 runs, accounts usable | App runs, nash and luki logged in | PASS |
| 0b | Baseline: push notifications | same | Receive a message while app closed | Notification arrives | Not tested | NOT TESTED |
| 1 | AyuGram row in Settings | run 42958002171 | Settings, scroll to row | Row visible | Row visible under Power Saving | PASS |
| 2 | AyuGram settings screen opens | run 42965390888 | Tap the AyuGram row | Screen with ghost toggles | Opens; log shows row tap, controller creation, entries built | PASS |
| 2b | Settings switches change and persist in the UI | run 42965390888 | Drag each switch | Switch flips, list redraws | Flips and redraws (needs a right-to-left drag over VNC; stock switches behave the same) | PASS |
| 3 | Ghost: read receipts suppressed | run 42973074591 | Receipts off; nash sends "ghost 5", luki opens the chat, check tick as nash | One tick stays, log says SKIPPED | Log `read push SKIPPED`; nash sees one tick while its earlier messages show two | PASS |
| 4 | Control: read receipts sent with receipts on | run 42973074591 | Receipts on; luki sends, nash opens chat | Two ticks on luki's side | Log `readHistory done ok=true`; luki shows two ticks after reopening the chat (the chat-list tick lagged) | PASS |
| 5 | Ghost: online status | run 42965390888 | Toggle Send Online Status | Log `suppress` follows the switch | Log shows suppress=true with the switch off and false with it on | PASS at log level; not observed from the other account |
| 6 | Ghost: typing status | run 42973074591 | Type with Send Typing Status off | Log `typing SKIPPED` | Logged for both accounts while typing | PASS at log level; not observed from the other account |
| 7 | Ghost: story views | - | - | - | Not tested | NOT TESTED |
| 8 | Deleted messages kept | run 42973074591 | nash sends, luki receives, nash deletes for both | luki keeps the message with the deleted mark | Message stays in luki's chat with the broom mark; log `deleted message kept` | PASS |
| 9 | Edit history | run 42973074591 | nash edits "ghost 5 from nash" to "... v2"; luki long-presses it | "Edit History" item shows the old text | Item present; alert shows "ghost 5 from nash" | PASS |
| 10 | No sponsored messages | run 42973074591 | - | - | Not tested (needs a channel that shows ads) | NOT TESTED |
| 11 | Local Premium | run 42973074591 | - | - | Not tested (no switch in the UI yet) | NOT TESTED |
| 12 | Deleted messages while the app is closed | run 42990218595 | Stay Connected on, restart, allow location, put the app in the background for 200 s | Process keeps running; a deletion sent meanwhile is kept | Location permission granted (log `keepalive authorization=3`), process alive after 200 s. No deletion could be sent from a second device, so the end-to-end case is open | NOT TESTED end to end |
| 13 | New settings sections | run 42990218595 | Open AyuGram settings, scroll | Ghost extras, filters, other switches | All present; switches flip; Add Filter prompt adds a row | PASS |
| 14 | Seconds in message time | run 42990218595 | Turn on, open a chat | Times show seconds | `1:48:22 AM` style in the chat | PASS |
| 15 | User ID in profile | run 42990218595 | Open nash's profile as luki | ID row | `ID 6700664454` above the username | PASS |
| 16 | Message filters | run 42990218595 | Filter `blockme`, filters on incl. private chats; nash sends "blockme 1" and "plain 7" | luki sees only "plain 7" | Only "plain 7" shown | PASS |
| 17 | Send via schedule | run 42990218595 | Override `useScheduledMessages` on and `sendOnlinePackets` off; nash sends | Message leaves the chat view, arrives about 12 s later | Arrived 12 to 20 s later with the scheduled time. Bug: the input field kept the text | PASS with bug (fix in run 43002933120) |
| 18 | Send Read Receipt action | run 42990218595 | Receipts off; luki long-presses nash's new message, taps Send Read Receipt | Log `read push SENT`, two ticks for nash | Menu item present; log shows `push=false validate=true` and `read validate kept local`, no receipt sent | FAIL (fix in run 43002933120) |
| 19 | Go Offline Immediately | run 42990218595 | Override `sendOfflinePacketAfterOnline` on | Log `forceOffline=true` | Logged every 5 s | PASS at log level |
| 20 | Deletion kept in a channel or group | run 42990218595 | (happened during testing) | Log line for a channel peer | `deleted message kept 2:Id(...)` | PASS at log level; not looked at in the chat |
| 20b | Master Ghost Mode switch | run 42990218595 | Tap Ghost Mode on, then off | All five ghost switches follow | Receipts, story views, online, typing went off and Go Offline on; all reversed on the second tap | PASS |
| 21 | Hide stories, skip link warning, copy in restricted chats, local Premium, silent sending | run 42990218595 | Switches on | - | No test material at hand (no stories, hidden links or restricted chats in the test accounts); silent sending is not visible to the sender | NOT TESTED |

## Notes

- Rows 3 and 4 from run 42958002171 were invalid: settings had been changed by
  editing the preferences plist over SSH, and the running app kept stale values.
- Row 2 history: on run 42958002171 the row did not open. Later testing showed
  Settings rows (stock ones too) ignore taps while the list is scrolled to its
  very end, and open again after scrolling slightly. The original failure was
  most likely that, not the push path. The code still uses the controller's
  own `push`.
- Row 8: the kept deletion was logged when the luki account was activated,
  not while nash was the active account. Updates for the inactive account
  appear to be applied on activation.
- Remote-control quirks over VNC: switches and context-menu items need a
  press of about 150 ms (scripted mouse down/up on the noVNC canvas); a plain
  click works for list rows and tabs; long-press needs about 1 s.
- nash is also in use on another device; ticks on old messages may come from there.
- During testing one of nash's group chats (Quang Blue IOS) was opened by a
  mis-timed tap and closed again. Read receipts were off at the time.
