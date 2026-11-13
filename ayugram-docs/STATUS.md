# AyuGram for iOS: feature status

One row per AyuGram Desktop setting or feature (source: `ayu/ayu_settings.h`
and the `ayu/features` and `ayu/ui` folders). Updated 2026-11-12 (run 43358340179 installed; next run building).

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
| TESTED | 59 |
| LOG ONLY | 5 |
| UNTESTED | 17 |
| TODO | 20 |
| N/A | 11 |

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
| suggestGhostModeBeforeViewingStory | on | UNTESTED | Prompt when opening someone's stories from the chat list (run 43349311751). Ghost Mode stays on afterwards; desktop turns it off again when the story closes. Stories opened from a profile or a chat avatar are not covered |
| Per-setting "locked" flags (5) | off | TESTED | Five Lock switches. With Read Receipts locked, switching Ghost Mode on and off left it alone and changed the other four |
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
| Deleted messages in groups and channels | - | TESTED | Group: nash's message deleted for everyone stays visible for luki with the deleted mark. Channel: log only |
| Self-destructing media, cleared history, deleted chats | - | TODO | |
| Proper database instead of a plist file | - | TODO | |
| Edit history viewer | - | TESTED | Sheet listing each earlier version with its time and a copy button |

## Filters

| Setting | Desktop default | iOS status |
|---|---|---|
| filtersEnabled (regex filters) | off | TESTED (filter "blockme" hid nash's message for luki) |
| filtersEnabledInChats | off | TESTED |
| hideFromBlocked | off | TESTED (groups only: after luki blocked nash, nash's messages and join notice disappeared from the Test group. Only for users whose blocked state the app has loaded or changed since this version. The chat list preview shows "Filtered message" once the row is redrawn; the author's name stays) |
| shadowBanIds | empty | TESTED (via message menu, shown in the filter list as user:<id>) |
| filterZalgo | off | TESTED (nash's zalgo message hidden for luki, "Filtered message" in the chat list) |
| Per-chat filters, import/export | - | TODO |

## Premium, ads and clutter

| Setting | Desktop default | iOS status | Notes |
|---|---|---|---|
| disableAds | on | UNTESTED | Needs a channel that shows ads; the one checked (32K subscribers) showed none even with the switch off |
| localPremium | off | TESTED | Client side: premium flag for the logged-in accounts (star, premium-only rows). Server-enforced features stay locked. Restart to apply |
| premiumStickersAsCopy | on | TESTED | Not in AyuGram Desktop; added at the user's request. Re-uploads a premium sticker and sends the copy. Animated stickers tested; user confirmed it shows as a sticker on another device; video stickers not checked. From run 43330220187 the copy send closes the panel, clears the reply bar and keeps the reply like a normal send (confirmed by the user) |
| Filtered/hidden messages in chat list preview | - | TESTED | Shows "Filtered message" |
| disableStories | off | UNTESTED | Switch on; no stories were available to compare |
| disableCustomBackgrounds | off | UNTESTED | run 43084196247 |
| disableOpenLinkWarning | off | UNTESTED | Needs a message with a hidden link |
| disableNotificationsDelay | off | N/A | Desktop delays its own notifications while another device is online; iOS notifications come from Apple's push service and have no such delay to remove |
| disableGreetingSticker | off | UNTESTED | Run 43002933120 |
| hidePremiumStatuses | off | TESTED | Chat list only: the status icon next to a contact's name disappears |
| collapseSimilarChannels | on | TESTED | Similar channels under the "you joined" notice start collapsed; tapping the notice opens them. Channels whose list was already loaded keep their state |
| hideSimilarChannels | off | UNTESTED | Run 43002933120 |
| showOnlyAddedEmojisAndStickers | off | TESTED | Sticker panel only: trending strip and suggested packs gone after reopening the chat. Emoji panel not covered |
| unlimitedRecentStickers | off | UNTESTED | Keeps up to 200 recent stickers on the device instead of 20. Needs more than 20 different stickers sent to check |

## Send confirmations

| Setting | Desktop default | iOS status |
|---|---|---|
| stickerConfirmation | off | TESTED (alert and Cancel; OK path not tried) |
| gifConfirmation | off | TESTED (saved, recent, search and trending GIFs; Cancel and OK) |
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
| removeMessageTail | off | TESTED | |
| avatarCorners | 23 | TESTED | On/off switch for rounded squares, not a radius slider; restart to apply |
| singleCornerRadius | off | TODO | |
| materialSwitches | on | N/A | iOS uses system switches |
| simpleQuotesAndReplies | off | TODO | |
| replaceBottomInfoWithIcons | on | TODO | |
| adaptiveCoverColor | on | TODO | |
| improveLinkPreviews | off | TODO | |
| hideFastShare | off | TESTED | Share arrow next to channel posts gone |
| showChannelReactions | on | TESTED | Reaction row under a channel post hidden with the switch off |
| showGroupReactions | on | TESTED | Run 43002933120 |
| showPrivateChatReactions | on | TESTED | Reaction hidden with the switch off |
| wideMultiplier | 1.0 | N/A | Desktop window layout |
| hideNotificationCounters | off | TESTED | Chats tab counter only (run 43084196247) |
| hideNotificationBadge | off | UNTESTED | The home screen cannot be reached over VNC; needs a look at the app icon on the iPad itself |
| hideAllChatsFolder | off | TESTED | Hides the All Chats tab when there is at least one folder and starts on the first folder. The All Chats list stays reachable from the Chats tab long-press menu (no tab is highlighted then); swiping does not reach it |
| channelBottomButton | Discuss | TODO | |
| quickAdminShortcuts | on | TODO | |

## Message field buttons

| Setting | Desktop default | iOS status |
|---|---|---|
| showAttachButtonInMessageField | on | TESTED (run 43084196247) |
| showCommandsButtonInMessageField | on | TESTED (a bot's "Open" menu button disappears; a bot with the "/" commands button was not at hand) |
| showEmojiButtonInMessageField | on | TESTED |
| showMicrophoneButtonInMessageField | on | TESTED |
| showAutoDeleteButtonInMessageField | on | TESTED (the "1mo" timer button disappears) |
| showGiftButtonInMessageField | on | UNTESTED (no chat at hand shows the button in the message field; the gift button in a channel's bottom bar is a different control and is not hidden) |
| showAiEditorButtonInMessageField | on | TODO |
| showAttachPopup | on | N/A (hover popup) |
| showEmojiPopup | on | N/A (hover popup) |

## Context menu items

| Setting | Desktop default | iOS status |
|---|---|---|
| showReactionsPanelInContextMenu | Visible | TESTED (on/off only, run 43084196247) |
| showViewsPanelInContextMenu | Visible | TESTED (on/off only, run 43084196247) |
| showHideMessageInContextMenu | Hidden | TESTED (Message disappears on this device and stays hidden after reopening) |
| showUserMessagesInContextMenu | With modifier | TESTED ("User Messages" in a group opens the search filtered to that member) |
| showMessageDetailsInContextMenu | With modifier | TESTED (Alert with message, chat and sender IDs and date) |
| showRepeatMessageInContextMenu | Hidden | TESTED (text messages only) |
| showAddFilterInContextMenu | Visible | TESTED (Adds the text as a filter; matching messages hide; tap the filter in settings to remove) |

## Side drawer and tray (desktop navigation)

| Setting | iOS status | Notes |
|---|---|---|
| showMyProfileInDrawer, showBotsInDrawer, showNewGroupInDrawer, showNewChannelInDrawer, showContactsInDrawer, showCallsInDrawer, showSavedMessagesInDrawer, showNightModeToggleInDrawer | N/A | iOS has no drawer |
| showLReadToggleInDrawer / showSReadToggleInDrawer | TESTED | Both items appear in the Settings tab long-press menu and Read on Server asks for confirmation (run 43322077655). The actions themselves were not run: they mark every chat of the account as read |
| showGhostToggleInDrawer | TESTED | Long-press the Settings tab: Turn Ghost Mode On/Off |
| showStreamerToggleInDrawer | TESTED | "Turn Streamer Mode On/Off" in the Settings tab long-press menu; the label flips after each tap |
| showGhostToggleInTray / showStreamerToggleInTray | N/A | Could map to home-screen quick actions |

## Larger features

| Feature | iOS status | Notes |
|---|---|---|
| AyuGram settings screen | TESTED | Ghost, history, filters and other sections; Add Filter prompt works |
| Streamer mode | TESTED | Hides own phone number in Settings only (run 43084196247) |
| Message shot (messages as image) | TODO | 7 options |
| Forward without author / from restricted chats / repeat message | TODO | Copy and save in restricted chats is implemented (UNTESTED, no restricted chat at hand) |
| Translator providers (Telegram, Google, Yandex, native) | TODO | |
| Webview options (spoof Android, larger size) | TODO | "Report Android to Mini Apps" is coded (UNTESTED: the Durger King mini app opens with it on but does not show the platform; a log line added for the next build); the two size options are not |
| `tg://ayu` settings links | TESTED | `tg://ayusettings` opens the AyuGram screen |
| Saved music, cover search | TODO | Low priority |
| Crash reporting to AyuGram | N/A | Deliberately not ported |
| Donate / plugin info boxes | N/A | Desktop project specific |

## iOS-only additions

| Feature | Status | Notes |
|---|---|---|
| Stay Connected in Background | TESTED | Kept a deletion sent from another device while the app was in the background (TESTING row 43). Shows the system location indicator |
| All accounts receive updates at once | UNTESTED | Part of keep-alive |
| Debug log and test override files | TESTED | Test aids; to be removed or hidden before release |
| Link cleaner for outgoing messages | TESTED | Requested by the user 2026-11-12. "Remove Tracking from Links I Send" drops known tracking parameters; "Strict Link Cleaning" drops every parameter a site does not need and the fragment, after Link Cleaner (corbindavenport/link-cleaner-js, MIT). Only text the system link detector recognises as a web link is changed, bare domains included; Telegram links and code are left alone. Edited messages are not covered |
| Edit Sticker on premium stickers | TESTED | Requested by the user 2026-11-12. Offered when Send Premium Stickers as a Copy is on; the edited sticker is a new upload and is delivered. The editor produces a still image, so the animation is lost. Checked from the sticker panel menu, not from the message menu |
