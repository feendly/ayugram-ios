# AyuGram for iOS: feature status

One row per AyuGram Desktop setting or feature (source: `ayu/ayu_settings.h`
and the `ayu/features` and `ayu/ui` folders). Updated 2026-11-11 (after testing run 42990218595; run 43012742764 installed).

Status values:

- **TESTED**: implemented and seen working on the iPad.
- **LOG ONLY**: implemented; the app's log shows the right behaviour, but it
  has not been observed from the other account.
- **UNTESTED**: implemented and compiled (or compiling), not yet tried.
- **TODO**: not implemented.
- **N/A**: desktop-only; no iOS equivalent planned, or replaced as noted.

## Summary

| Status | Rows |
|---|---|
| TESTED | 36 |
| LOG ONLY | 7 |
| UNTESTED | 22 |
| TODO | 35 |
| N/A | 10 |

Some rows group several related desktop settings, so the row count is lower than the number of individual settings.

## Ghost mode

| Setting | Desktop default | iOS status | Notes |
|---|---|---|---|
| sendReadMessages | on | TESTED | One tick stays on the sender's side with it off |
| sendReadStories | on | UNTESTED | Gate in place, no story test yet |
| sendOnlinePackets | on | LOG ONLY | |
| sendUploadProgress (typing) | on | LOG ONLY | |
| sendOfflinePacketAfterOnline | off | LOG ONLY | Log shows an offline status sent every 5 s while enabled |
| ghostModeActive (master switch) | off | TESTED | Flips the five switches both ways |
| markReadAfterAction | on | LOG ONLY | Reacting sends one read receipt (log `read forced`, `read push SENT`) |
| useScheduledMessages | off | TESTED | Only with online status off, as on desktop. Message arrives about 12 s later; input field clears at once (run 43012742764) |
| sendWithoutSound | Never | UNTESTED | Two switches: always, or only in ghost mode. Not observable from the sender's side |
| suggestGhostModeBeforeViewingStory | on | TODO | |
| Per-setting "locked" flags (5) | off | TODO | |
| useGlobalGhostMode (per-account ghost) | on | TODO | iOS build is global only |
| "Read message" context action | - | TESTED | "Send Read Receipt" in the long-press menu; nash saw two ticks (run 43002933120) |

## Message history

| Setting | Desktop default | iOS status | Notes |
|---|---|---|---|
| saveDeletedMessages | on | TESTED | Live deletion in a private chat |
| saveMessagesHistory (edits) | on | TESTED | "Edit History" in the long-press menu |
| saveForBots | off | UNTESTED | |
| deletedMark | broom | TESTED | Broom shown. Custom mark: prompt opens with the current value; custom mark saved and shown (row 42) |
| editedMark | "edited" | TESTED | Custom text, run 43002933120 |
| semiTransparentDeletedMessages | off | TESTED | Bubble messages only (run 43084196247) |
| Deleted messages while app is closed | - | TESTED | App now stays running in the background (see Stay Connected). Kept a deletion sent from another device while the app was in the background (TESTING row 43). Not captured after a device reboot until the app runs again |
| Deleted messages in groups and channels | - | LOG ONLY | Log shows a channel deletion kept; not looked at in the chat |
| Self-destructing media, cleared history, deleted chats | - | TODO | |
| Proper database instead of a plist file | - | TODO | |
| Full-screen edit history viewer | - | TODO | Currently an alert listing old texts |

## Filters

| Setting | Desktop default | iOS status |
|---|---|---|
| filtersEnabled (regex filters) | off | TESTED (filter "blockme" hid nash's message for luki) |
| filtersEnabledInChats | off | TESTED |
| hideFromBlocked | off | TODO |
| shadowBanIds | empty | TESTED (via message menu, shown in the filter list as user:<id>) |
| filterZalgo | off | UNTESTED (run 43012742764) |
| Per-chat filters, import/export | - | TODO |

## Premium, ads and clutter

| Setting | Desktop default | iOS status | Notes |
|---|---|---|---|
| disableAds | on | UNTESTED | Needs a channel that shows ads |
| localPremium | off | UNTESTED | Needs restart to apply |
| premiumStickersAsCopy | on | TESTED | Not in AyuGram Desktop; added at the user's request. Re-uploads a premium sticker and sends the copy. Animated stickers tested; user confirmed it shows as a sticker on another device; video stickers not checked |
| Filtered/hidden messages in chat list preview | - | TESTED | Shows "Filtered message" |
| disableStories | off | UNTESTED | Switch on; no stories were available to compare |
| disableCustomBackgrounds | off | UNTESTED | run 43084196247 |
| disableOpenLinkWarning | off | UNTESTED | Needs a message with a hidden link |
| disableNotificationsDelay | off | TODO | |
| disableGreetingSticker | off | UNTESTED | Run 43002933120 |
| hidePremiumStatuses | off | UNTESTED | Chat list only (run 43002933120) |
| collapseSimilarChannels | on | TODO | |
| hideSimilarChannels | off | UNTESTED | Run 43002933120 |
| showOnlyAddedEmojisAndStickers | off | TODO | |
| unlimitedRecentStickers | off | TODO | |

## Send confirmations

| Setting | Desktop default | iOS status |
|---|---|---|
| stickerConfirmation | off | TESTED (alert and Cancel; OK path not tried) |
| gifConfirmation | off | TESTED (alert and Cancel; OK path not tried) |
| voiceConfirmation | off | UNTESTED (run 43002933120; covers recordings sent from the preview, not hold-and-release) |
| roundConfirmation | off | UNTESTED (same switch as voice) |

## Appearance

| Setting | Desktop default | iOS status | Notes |
|---|---|---|---|
| showMessageSeconds | off | TESTED | |
| showPeerId | Bot API | TESTED | ID row in user profiles; on/off only |
| appIcon | default | TODO | |
| monoFont / main font | system | TODO | |
| messageBubbleRadius | 16 | N/A | Stock setting exists: Appearance, Message Corners |
| removeMessageTail | off | TODO | |
| avatarCorners | 23 | TODO | |
| singleCornerRadius | off | TODO | |
| materialSwitches | on | N/A | iOS uses system switches |
| simpleQuotesAndReplies | off | TODO | |
| replaceBottomInfoWithIcons | on | TODO | |
| adaptiveCoverColor | on | TODO | |
| improveLinkPreviews | off | TODO | |
| hideFastShare | off | UNTESTED | run 43084196247 |
| showChannelReactions | on | UNTESTED | Run 43002933120 |
| showGroupReactions | on | TESTED | Run 43002933120 |
| showPrivateChatReactions | on | TESTED | Reaction hidden with the switch off |
| wideMultiplier | 1.0 | N/A | Desktop window layout |
| hideNotificationCounters | off | TESTED | Chats tab counter only (run 43084196247) |
| hideNotificationBadge | off | UNTESTED | Run 43002933120 |
| hideAllChatsFolder | off | TODO | |
| channelBottomButton | Discuss | TODO | |
| quickAdminShortcuts | on | TODO | |

## Message field buttons

| Setting | Desktop default | iOS status |
|---|---|---|
| showAttachButtonInMessageField | on | TESTED (run 43084196247) |
| showCommandsButtonInMessageField | on | UNTESTED (run 43113668579) |
| showEmojiButtonInMessageField | on | TESTED |
| showMicrophoneButtonInMessageField | on | TODO |
| showAutoDeleteButtonInMessageField | on | UNTESTED (run 43113668579) |
| showGiftButtonInMessageField | on | UNTESTED (run 43113668579) |
| showAiEditorButtonInMessageField | on | TODO |
| showAttachPopup | on | N/A (hover popup) |
| showEmojiPopup | on | N/A (hover popup) |

## Context menu items

| Setting | Desktop default | iOS status |
|---|---|---|
| showReactionsPanelInContextMenu | Visible | TESTED (on/off only, run 43084196247) |
| showViewsPanelInContextMenu | Visible | TESTED (on/off only, run 43084196247) |
| showHideMessageInContextMenu | Hidden | TESTED (Message disappears on this device and stays hidden after reopening) |
| showUserMessagesInContextMenu | With modifier | TODO |
| showMessageDetailsInContextMenu | With modifier | TESTED (Alert with message, chat and sender IDs and date) |
| showRepeatMessageInContextMenu | Hidden | TESTED (text messages only) |
| showAddFilterInContextMenu | Visible | TESTED (Adds the text as a filter; matching messages hide; tap the filter in settings to remove) |

## Side drawer and tray (desktop navigation)

| Setting | iOS status | Notes |
|---|---|---|
| showMyProfileInDrawer, showBotsInDrawer, showNewGroupInDrawer, showNewChannelInDrawer, showContactsInDrawer, showCallsInDrawer, showSavedMessagesInDrawer, showNightModeToggleInDrawer | N/A | iOS has no drawer |
| showLReadToggleInDrawer / showSReadToggleInDrawer | TODO | As quick actions |
| showGhostToggleInDrawer | TESTED | Long-press the Settings tab: Turn Ghost Mode On/Off |
| showStreamerToggleInDrawer | TODO | With streamer mode |
| showGhostToggleInTray / showStreamerToggleInTray | N/A | Could map to home-screen quick actions |

## Larger features

| Feature | iOS status | Notes |
|---|---|---|
| AyuGram settings screen | TESTED | Ghost, history, filters and other sections; Add Filter prompt works |
| Streamer mode | TESTED | Hides own phone number in Settings only (run 43084196247) |
| Message shot (messages as image) | TODO | 7 options |
| Forward without author / from restricted chats / repeat message | TODO | Copy and save in restricted chats is implemented (UNTESTED, no restricted chat at hand) |
| Translator providers (Telegram, Google, Yandex, native) | TODO | |
| Webview options (spoof Android, larger size) | TODO | 3 options |
| `tg://ayu` settings links | TESTED | `tg://ayusettings` opens the AyuGram screen |
| Saved music, cover search | TODO | Low priority |
| Crash reporting to AyuGram | N/A | Deliberately not ported |
| Donate / plugin info boxes | N/A | Desktop project specific |

## iOS-only additions

| Feature | Status | Notes |
|---|---|---|
| Stay Connected in Background | LOG ONLY | Heartbeat and location updates continued for 170 s in the background (run 43012742764). Shows the system location indicator. Catching a deletion from another device not yet tried |
| All accounts receive updates at once | UNTESTED | Part of keep-alive |
| Debug log and test override files | TESTED | Test aids; to be removed or hidden before release |
