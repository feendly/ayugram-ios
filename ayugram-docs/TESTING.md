# AyuGram iOS test log

Device: iPad Pro 10.5" (iPad7,4), iOS 17.7.11, Dopamine rootless, TrollStore Lite.
Accounts: `nash` and `luki`, both logged in to the same app install.
A feature counts as done only when its row says PASS.

## How builds get onto the device

1. `gh workflow run build.yml -R feendly/repo-a6738d29 --ref ayugram`
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
| 22 | Send Read Receipt action (retest) | run 43002933120 | Receipts off; luki long-presses "rr10", taps Send Read Receipt; check as nash | Log `read push SENT`; two ticks for nash | Log `read forced`, `read push SENT`, `readHistory done ok=true`; nash shows two ticks on "rr10" | PASS |
| 23 | `tg://ayusettings` link | run 43002933120 | `uiopen --url tg://ayusettings` | AyuGram settings open | Opened | PASS |
| 24 | Message Details | run 43002933120 | Long-press a message, Message Details | Alert with IDs and date | Message ID 6999, chat and sender ID 6700664454, date with seconds | PASS |
| 25 | Hide message locally | run 43002933120 | Switch on; long-press "sche", Hide | Message disappears and stays hidden | Gone, still hidden after reopening the chat; nash still sees it | PASS |
| 26 | Add to Filters | run 43002933120 | Long-press "sch", Add to Filters; reopen chat; remove the filter in settings | "sch" and "sch x" hide, return after removal | As expected (the filter is a substring match) | PASS |
| 27 | Read receipt after reacting | run 43002933120 | Receipts off; luki reacts to "rr10" | Log `read forced` | Logged with `read push SENT` | PASS at log level |
| 28 | Hide reactions in private chats | run 43002933120 | Override `showPrivateChatReactions` off, reopen chat | Reaction not shown | Heart hidden; shown again with the switch on | PASS |
| 29 | Quick ghost toggle | run 43002933120 | Long-press the Settings tab | Item toggles ghost mode | "Turn Ghost Mode On", then "Off" after tapping; turned off again | PASS |
| 30 | Scheduled send clears the input (retest) | run 43002933120 | As row 17, luki sends "s11" | Field empties at once | Field kept "s11"; the fix was in the wrong send path | FAIL (second fix coded) |
| 31 | Sticker confirmation | run 43002933120 | Override on, open sticker panel, tap a sticker | Alert | Taps on stickers did not register over VNC; nothing sent, no alert | NOT TESTED |
| 32 | Custom deleted mark | run 43002933120 | Settings, Deleted Mark, type text, Done | Mark changes | Prompt opens with the broom; Done did not respond while a keyboard accent popup was open, prompt closed with Escape, value not saved | NOT TESTED |
| 33 | Keep-alive heartbeat | run 43002933120 | Watch the log | `keepalive heartbeat` every 30 s | Logged in the foreground; background not yet checked | PARTIAL |
| 34 | Keep-alive in the background | run 43002933120 | Background the app, watch the heartbeat | Heartbeat continues | Stopped about 30 s after backgrounding: the location indicator was off, so iOS suspended the app | FAIL (fixed in run 43012742764) |
| 35 | Keep-alive in the background (retest) | run 43012742764 | Same, 170 s in the background | Heartbeat every 30 s with state=2 | Heartbeats and location updates continued the whole time | PASS at log level; deletion from another device not yet tried |
| 36 | Scheduled send clears the input (second retest) | run 43012742764 | As row 17 | Field empties at once | Field cleared immediately; message arrived about 15 s later | PASS |
| 37 | Repeat in message menu | run 43012742764 | Override on, long-press a text message | Repeat item | Item shown; sending not tried | PARTIAL |
| 38 | Deleted while locked, sent from another device | run 43012742764 | User sends luki a message as nash from another device and deletes it while the iPad is locked | Log `deleted message kept` | Invalid run: the iPad had rebooted about 50 s after the last heartbeat of the previous test (uptime 5 h 52 min at check time), so AyuGram was not running for the whole window. No kept deletion logged. iOS relaunched the app in the background (state=2) once the jailbreak was back | NOT TESTED (repeat needed) |
| 39 | Repeat in message menu (send) | run 43012742764 | Override on; nash long-presses "plain 7", taps Repeat | Same text sent again | New "plain 7" sent at 3:41 PM and received by luki | PASS |
| 40 | Sticker confirmation | run 43012742764 | Override on; open a sticker pack preview, Send Sticker | Alert "Send this sticker?" | Alert shown; Cancel sent nothing. OK path not tried | PASS (Cancel path) |
| 41 | GIF confirmation | run 43012742764 | Override on; tap a GIF in the GIF panel | Alert "Send this GIF?" | Alert shown; Cancel sent nothing. OK path not tried | PASS (Cancel path) |
| 42 | Custom deleted and edited marks | run 43012742764 | Settings: Edited Mark "Chg", Deleted Mark broom plus "x"; open luki's chat with nash | Marks change on messages | Rows show the new values; "ghost 5 from nash v2" shows `Chg` and the broom with `x` before the time | PASS |

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
- Row 36 was run by mistake while nash was the active account, so the test message 's12' went to nash's Saved Messages. It was deleted there right after.
- A device reboot ends keep-alive until the app is opened again (or iOS relaunches it); deletions during that gap are not captured.
- Over VNC a scripted press of about 60 ms taps sticker and GIF grid cells; a normal click acts as a long press there.
- The custom marks from row 42 (`Chg`, broom plus `x`) are still set on the device.
