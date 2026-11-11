# Building and installing AyuGram for iOS

Nothing compiles locally. Builds run on GitHub Actions in
`feendly/ayugram-ios` (branch `ayugram`), on the `xcode-27` runner image,
which provides the Xcode 27.1 that `versions.json` pins.

## One-time setup (already done)

- Repository secrets: `TELEGRAM_API_ID`, `TELEGRAM_API_HASH`, `ARTIFACT_KEY`.
- `ARTIFACT_KEY` is also stored locally in `F:\ayugram-ios\.artifact-key`
  (outside the repository). Artifacts are encrypted because the IPA embeds the
  API credentials and the repository is public.
- The fake provisioning profiles in `build-system/fake-codesigning/profiles`
  were re-signed with the repo's self-signed certificate (expiry 2030-10-01);
  upstream's copies expired on 2026-10-30 and fail the build.
- `.gitmodules`: `tgcalls` uses an absolute URL.

## Build

```bash
gh workflow run build.yml -R feendly/ayugram-ios --ref ayugram
gh run view <run-id> -R feendly/ayugram-ios --json status,conclusion
```

Timing on the standard runner: about 100 minutes cold, 10 minutes with no
source changes, about 47 minutes when TelegramCore changes (everything above
it recompiles). The workflow keeps a Bazel disk cache between runs and
cancels an in-progress run when a new one starts.

## Download and decrypt

```bash
gh run download <run-id> -R feendly/ayugram-ios -n ipas-encrypted -D .
openssl enc -d -aes-256-cbc -pbkdf2 -pass "pass:$(cat F:/ayugram-ios/.artifact-key)" \
  -in AyuGram.ipa.enc -out AyuGram.ipa
```

`AyuGram.ipa` has bundle id `com.feendly.ayugram` (rewritten by
`ayugram-build/reid.sh`) and is ad-hoc signed for TrollStore.

## Install on the test iPad

```bash
scp AyuGram.ipa mobile@192.168.2.22:/var/mobile/Documents/AyuGram.ipa
ssh mobile@192.168.2.22 '/var/jb/usr/bin/uiopen --url "apple-magnifier://install?url=file:///var/mobile/Documents/AyuGram.ipa"'
```

Then tap Install in the TrollStore Lite prompt. App data and logins survive
the update.

## On-device test aids

Inside the app's data container, `tmp/`:

- `ayu-debug.log`: decisions made by the AyuGram code (read receipts, online
  status, typing, settings screen, kept deletions).
- `ayu-override.plist`: optional dictionary of setting name to Bool that
  overrides stored settings within two seconds. Delete it to return control
  to the in-app switches.

Screen control: noVNC at `http://192.168.2.22:5801/` in Chrome with
`&resize=scale`. Switches, context-menu items and alert buttons respond to a
scripted press of about 150 ms on the noVNC canvas, not to a plain click. `uiopen --url "tg://resolve?domain=<username>"` opens a chat.

## Upstream updates

The repository starts from a history-free snapshot of
TelegramMessenger/Telegram-iOS at `24638bc69bd083981b178dd1e7f921eebbf7fc46`.
Merging newer upstream code means fetching upstream and grafting or
cherry-picking; there is no shared history.
