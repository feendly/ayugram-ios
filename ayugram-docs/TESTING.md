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
| 43 | Deleted while the app is in the background, sent from another device | run 43012742764 | User sends messages between luki and nash from another device and deletes them (about 3:58 PM and 4:06 PM) | Messages kept with the deleted mark | Both kept. For the 4:06 PM one the log shows `keepalive heartbeat state=2` (background) 19 s before `deleted message kept`, for both accounts at once. Whether the screen was locked is not known | PASS |
| 44 | Dim deleted messages | run 43084196247 | Override on; open the chat with the kept deletions | Deleted bubbles at half opacity | Both deleted messages dimmed, others normal | PASS |
| 45 | Hide reactions bar and read row in message menu | run 43084196247 | Overrides off; long-press own read message "plain 7" | No reactions bar, no "read at" row | Neither shown; other items present | PASS |
| 46 | Hide attach button | run 43084196247 | Override off; open a chat | No paperclip in the message field | Field starts at the left edge, no paperclip | PASS |
| 47 | Hide unread counter on Chats tab | run 43084196247 | Override on | No badge on the Chats tab | Badge gone (it showed 1.2K before) | PASS |
| 48 | Streamer mode | run 43084196247 | Override on; open Settings | Own phone number hidden | Header shows only the username. The "Is +1 ... still your number?" card still showed the number | PASS with gap (card fix coded, not built) |
| 49 | Hide quick share, ignore per-chat backgrounds | run 43084196247 | - | - | No channel post or custom chat background in the test chat | NOT TESTED |
| 50 | Filtered message hidden in chat list preview | run 43094601854 | Install; look at luki's row in nash's chat list (last message is filtered) | Preview does not show the message text | Row shows "Filtered message" (it showed the text "Lazy" on the previous build) | PASS |
| 51 | Premium sticker sent as a copy | run 43094601854 | Open the sticker panel, tap a premium sticker | Sticker sent | Not reached: the iPad dropped off the network (15% battery warning seconds earlier) before a premium sticker was found in the panel | NOT TESTED |
| 52 | Premium sticker sent as a copy | run 43113668579 | nash (no Premium): sticker panel, Trending Premium Stickers, Duck pack, press a star-badged sticker | Sticker is sent and arrives as a sticker | Log `sticker copy start mime=application/x-tgsticker`, `enqueue bytes=10465`. Sent at 8:11 PM; shows as an animated sticker for nash and for luki, whose chat list says "Sticker". The user confirmed on another device that it looks like a sticker. Video (.webm) premium stickers not tried | PASS (animated stickers) |
| 53 | Hide emoji button in message field | run 43113668579 | Override off, reopen chat | No emoji/sticker button in the field | Button gone | PASS |
| 54 | Hide commands, auto-delete and gift buttons | run 43113668579 | - | - | The test chat shows none of these buttons to begin with | NOT TESTED |
| 55 | Streamer mode hides the phone confirmation card | run 43113668579 | - | - | Checked on luki, which has no such card; not checked on nash | NOT TESTED |
| 56 | Hide reactions in groups | run 43113668579 | In the Test group nash sends "g1" and reacts with a heart; override `showGroupReactions` off; reopen the group | Reaction not shown | Heart shown before, hidden after | PASS |
| 57 | Shadow ban | run 43125223413 | As luki in the Test group: long-press nash's "g1", Shadow Ban; reopen the group; remove `user:6700664454` in the filter list; reopen | nash's messages hidden, then back | "g1" and nash's join notice hidden; entry listed in settings; both back after removal. The open chat has to be closed and reopened to refresh. The chat list preview still showed nash's message (fix coded, not built) | PASS with gap |
| 58 | Rounded-square avatars | run 43133651759 | Override on before launch; open the chat list and a chat | Avatars are rounded squares | Chat list, archive icon and chat header avatars are rounded squares; the account avatar in the tab bar stays round | PASS |
| 59 | No tail on message bubbles | run 43133651759 | Override on; open the nash chat | Bubbles without tails | Incoming and outgoing bubbles have no tail | PASS |
| 60 | Shadow-banned user hidden in chat list preview | run 43133651759 | - | - | Not re-run after the fix | NOT TESTED |
| 61 | Local Premium (fixed) | run 43147318173 | Override on before launch; open Settings | Accounts treated as Premium by the app | Premium star next to luki and nash; "Set Emoji Status" and "Change Profile Color" rows appear. Client-side only: server features were not tried and are expected to be refused | PASS (client side) |
| 62 | GIF confirmation, OK path | run 43147318173 | Override on; tap a recent GIF, OK | GIF sent after OK | Alert, then GIF sent at 12:29 AM | PASS |
| 63 | GIF confirmation for search and trending GIFs (fixed) | run 43147318173 | Search "cat" in the GIF panel, tap a result, OK | Alert, then sent | Alert shown; GIF sent at 12:30 AM after OK | PASS |
| 64 | Sticker confirmation, OK path | run 43147318173 | - | - | The sticker cell tap did not register over VNC this time | NOT TESTED |
| 65 | Edit history sheet | run 43147318173 | Long-press "ghost 5 from nash v2", Edit History | Sheet with earlier versions, time and copy | "Edit History (1 earlier version)", "Nov 11, 2026 at 3:55:58 AM", the old text, Copy Version 1, Cancel. Copy itself not checked | PASS |
| 66 | Filter applies to the open chat at once (fixed) | run 43147318173 | Long-press "sch", Add to Filters, without leaving the chat | Matching messages vanish immediately | "sch" and "sch x" disappeared at once | PASS |
| 67 | Shadow ban applies at once; hidden in chat list preview | run 43147318173 | - | - | Not re-run; same refresh call as the filter case | NOT TESTED |
| 68 | Premium sticker copy with Local Premium on | run 43147318173 | Override `localPremium` on before launch, copy switch on; tap a star-badged "Bird of Paradise" sticker | Sent as a copy | Log `sticker copy start` and `enqueue bytes=34398`; delivered. A regular sticker also sent normally | PASS |
| 69 | Hide microphone button | run 43154802111 | Override off, open a chat | No mic button | Icon gone, but its empty round background stayed | PASS with gap (fix in run 43161070387) |
| 70 | Sticker copy rule: Local Premium on, copy on | run 43161070387 | Overrides on; tap a star-badged sticker | Sent as a copy | Log `sticker copy start` / `enqueue bytes=34398`; delivered at 2:39 AM | PASS |
| 71 | Sticker copy rule: Local Premium on, copy off | run 43161070387 | Copy override off; tap a star-badged sticker | Sent normally (server refuses it) | No copy log line; message at 2:40 AM shows the failed mark | PASS (behaves as specified) |
| 72 | Hide microphone button (fixed) | run 43161070387 | Override off, open a chat | No mic button or background | Field shows no mic and no empty circle | PASS |
| 73 | Hide quick share button | run 43161070387 | Override on; reopen the LuckyClumsy channel | No share arrow next to posts | Arrow shown before, gone after | PASS |
| 74 | Hide reactions in channels | run 43161070387 | Override `showChannelReactions` off; reopen the channel | No reaction row under posts | Reaction row shown before, gone after | PASS |
| 75 | Zalgo filter | run 43161070387 | nash sends "zalgo" with 20 combining marks to luki; luki has filters on, private chats on, then `filterZalgo` on | Message hidden only with the zalgo switch on | Shown with the switch off; with it on the chat list says "Filtered message" and the chat does not show it | PASS |
| 76 | Hide auto-delete button | run 43161070387 | Set a 1 month auto-delete timer in the luki-nash chat; override off; reopen the chat | No timer button in the message field | "1mo" button shown before, gone after; back when the override is removed. Timer disabled again afterwards | PASS |
| 77 | Hide gift button in message field | run 43161070387 | Override off; open a channel | - | The message field of the chats at hand has no gift button; the channel's bottom-bar gift button stayed (different control) | NOT TESTED |
| 78 | Hide app icon badge | run 43161070387 | Override on | No badge on the home screen icon | The home screen could not be reached over VNC | NOT TESTED |
| 79 | Skip hidden link warning | run 43161070387 | Tap the hidden link in a channel post | - | The only hidden link at hand points to a Telegram bot, which never shows the warning | NOT TESTED |

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
- The two iPad reboots on 2026-11-11 (09:40 and 17:29 device time) were low-battery shutdowns: each has a LowBatteryLog at 1% capacity. The logs show the screen held on for hours, AyuGram in the foreground, and (second time) AyuGram's location keep-alive holding the system awake for 43 min. Not a crash or kernel panic.
- Third shutdown, 19:02 device time, 90 s after installing run 43094601854: LowBatteryLog again, but at 16% reported charge with only 3367 mV (the earlier ones were at 1%). Five more LowBatteryLogs exist from 26 Sep to 4 Nov, before AyuGram was ever installed. Reading: a worn battery whose voltage collapses under load (install, app launch, screen on, VNC, location). No panic logs; the install itself is not the cause, the load spike at low charge is.
- Over VNC, pressing a star-badged sticker in the pack preview sent it directly (no menu appeared); the press that sent it was a mouse click on a neighbouring cell, so the exact gesture is unclear.
- A test group named "Test" (nash and luki only) exists for group features since 2026-11-11.
- 2026-11-11 late: with luki active, tapping a trending GIF sent it to nash without the confirmation alert. Trending and search GIFs use a separate send path (bot results) that the confirmation did not cover; row 41's pass was for saved GIFs only. Fix in run 43147318173.
- With Local Premium on, every account logged in on the device shows as Premium inside the app (nash shows a star when viewed from luki).
- Premium sticker copy rule (user's decision, 2026-11-12): it applies to premium stickers only. Copy switch on: sent as a copy when the account has no real Premium, including with Local Premium on. Copy switch off: sent normally, which the server refuses for an account without real Premium (three such failed sends from the user at 12:48 AM are in the luki-nash chat). Run 43154802111 briefly forced the copy whenever Local Premium was on; that was reverted.
- The build PC's C: drive is full (83 MB free on 2026-11-12); artifact downloads now use F:\ayugram-ios\tmp for temp files.
- 2026-11-12: the luki-nash chat has two service messages from row 76 (auto-delete set to 1 month, then disabled) and nash's "zalgo test" message from row 75. The LuckyFiles bot chat was opened once by the link in row 79 and closed without pressing Start.
- `tg://msg?text=...` opened from SSH with `uiopen` puts text into the share picker of the active account; used to send text that cannot be typed over VNC.
- The home screen cannot be reached over VNC (the swipe from the bottom edge is not passed on).
