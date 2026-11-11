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
| 3 | Ghost: read receipts suppressed | run 42965390888 | - | One tick stays, log says SKIPPED | Not re-run yet on this build | NOT TESTED |
| 4 | Control: read receipts sent with receipts on | run 42965390888 | Receipts on; luki sends, nash opens chat | Two ticks on luki's side | Log: `read push SENT`, but luki still shows one tick | FAIL (under investigation) |
| 5 | Ghost: online status | run 42965390888 | Toggle Send Online Status | Log `suppress` follows the switch | Log shows suppress=true with the switch off and false with it on | PASS at log level; not observed (nash hides last seen) |
| 6 | Ghost: typing status | run 42965390888 | Type with Send Typing Status off | Log `typing SKIPPED` | Logged once while typing as luki | PASS at log level; not observed |
| 7 | Ghost: story views | - | - | - | Not tested | NOT TESTED |
| 8 | Deleted messages kept | - | - | - | Code written, not built | NOT TESTED |
| 9 | Edit history | - | - | - | Code written, not built | NOT TESTED |
| 10 | No sponsored messages | - | - | - | Code written, not built | NOT TESTED |
| 11 | Local Premium | - | - | - | Code written, not built | NOT TESTED |

## Notes

- Rows 3 and 4 from run 42958002171 were invalid: settings had been changed by
  editing the preferences plist over SSH, and the running app kept stale
  values (the settings screen later showed all four send switches off).
- Row 2 was fixed by opening the screen with the controller's own `push`
  instead of the local push closure used by neighbouring rows. Why the closure
  path failed is not understood.
- Row 4: the app logs that it sent the read receipt, yet the sender still sees
  one tick. Run 42973074591 logs the message id sent and the server's answer.
- nash is also in use on another device; ticks on old messages may come from there.
