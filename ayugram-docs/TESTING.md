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

| # | Feature | Build | Steps | Expected | Actual | Result |
|---|---|---|---|---|---|---|
| 0 | Baseline: unmodified app installs and runs | run 42944143598 | Install, launch, log in | Telegram 13.2 runs, accounts usable | App runs, nash and luki logged in | PASS |
| 0b | Baseline: push notifications | same | Receive a message while app closed | Notification arrives | Not tested | NOT TESTED |
| 1 | AyuGram row in Settings | run 42958002171 | Settings, scroll to row | Row visible | Row visible under Power Saving | PASS |
| 2 | AyuGram settings screen opens | run 42958002171 | Tap the AyuGram row | Screen with ghost toggles | Nothing opens; other rows open normally | FAIL |
| 3 | Ghost: read receipts suppressed | run 42958002171 | Ghost on via prefs file; luki sends, nash opens chat, check tick as luki | One tick stays | One tick stays | INCONCLUSIVE (control #4 failed) |
| 4 | Control: read receipts sent with ghost off | run 42958002171 | Ghost off via prefs file; luki sends, nash opens chat | Two ticks | Still one tick | FAIL |
| 5 | Ghost: online status | - | - | - | Not tested (nash shows "last seen recently" to luki, so last-seen privacy hides the signal; needs a privacy change or log evidence) | NOT TESTED |
| 6 | Ghost: typing status | - | - | - | Not tested | NOT TESTED |
| 7 | Ghost: story views | - | - | - | Not tested | NOT TESTED |

## Open problems

- #2: cause unknown. On-device lldb could not see into the stripped code. Run
  42965390888 adds `<tmp>/ayu-debug.log` with log points on the whole path.
- #3/#4: settings were switched by editing the app's preferences plist over
  SSH, which may not reach the running app reliably. Run 42965390888 adds
  `<tmp>/ayu-override.plist`, read by the app directly, and logs every
  read-receipt decision, so the next test has evidence either way.
- One observation in favour of the local-read design: after an app relaunch,
  the message nash read under ghost mode stayed read locally.
