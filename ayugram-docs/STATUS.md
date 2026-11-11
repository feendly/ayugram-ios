# AyuGram for iOS: feature status

One row per AyuGram Desktop setting or feature (source: `ayu/ayu_settings.h`
and the `ayu/features` and `ayu/ui` folders). Updated 2026-11-11 (after testing run 42990218595).

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
| TESTED | 12 |
| LOG ONLY | 5 |
| UNTESTED | 17 |
| TODO | 65 |
| N/A | 9 |

Some rows group several related desktop settings, so the row count is lower than the number of individual settings.

## Ghost mode

| Setting | Desktop default | iOS status | Notes |
|---|---|---|---|
| sendReadMessages | on | TESTED | One tick stays on the sender's side with it off |
| sendReadStories | on | UNTESTED | Gate in place, no story test yet |
| sendOnlinePackets | on | LOG ONLY | |
| sendUploadProgress (typing) | on | LOG ONLY | |
| sendOfflinePacketAfterOnline | off | LOG ONLY | Log shows an offline status sent every 5 s while enabled |
| ghostModeActive (master switch) | off | UNTESTED | Switch exists; sets the five above |
| markReadAfterAction | on | TODO | Sending a message already marks read server-side; reactions missing |
| useScheduledMessages | off | TESTED | Only with online status off, as on desktop. Message arrives about 12 s later. Input field was not cleared after sending (fix in run 43002076982, untested) |
| sendWithoutSound | Never | UNTESTED | Two switches: always, or only in ghost mode. Not observable from the sender's side |
| suggestGhostModeBeforeViewingStory | on | TODO | |
| Per-setting "locked" flags (5) | off | TODO | |
| useGlobalGhostMode (per-account ghost) | on | TODO | iOS build is global only |
| "Read message" context action | - | UNTESTED | "Send Read Receipt" in the long-press menu. First version FAILED on device (queued a check instead of a push); fix in run 43002076982 |

## Message history

| Setting | Desktop default | iOS status | Notes |
|---|---|---|---|
| saveDeletedMessages | on | TESTED | Live deletion in a private chat |
| saveMessagesHistory (edits) | on | TESTED | "Edit History" in the long-press menu |
| saveForBots | off | UNTESTED | |
| deletedMark | broom | TESTED | Broom shown. Custom mark setting added in run 43002076982 (UNTESTED) |
| editedMark | "edited" | TODO | |
| semiTransparentDeletedMessages | off | TODO | |
| Deleted messages while app is closed | - | UNTESTED | Keep-alive runs (location permission granted, process alive after 200 s in background). Needs a deletion sent from another device while the iPad is on the home screen |
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
| shadowBanIds | empty | TODO |
| filterZalgo | off | TODO |
| Per-chat filters, import/export | - | TODO |

## Premium, ads and clutter

| Setting | Desktop default | iOS status | Notes |
|---|---|---|---|
| disableAds | on | UNTESTED | Needs a channel that shows ads |
| localPremium | off | UNTESTED | Needs restart to apply |
| disableStories | off | UNTESTED | Switch on; no stories were available to compare |
| disableCustomBackgrounds | off | TODO | |
| disableOpenLinkWarning | off | UNTESTED | Needs a message with a hidden link |
| disableNotificationsDelay | off | TODO | |
| disableGreetingSticker | off | TODO | |
| hidePremiumStatuses | off | TODO | |
| collapseSimilarChannels | on | TODO | |
| hideSimilarChannels | off | TODO | |
| showOnlyAddedEmojisAndStickers | off | TODO | |
| unlimitedRecentStickers | off | TODO | |

## Send confirmations

| Setting | Desktop default | iOS status |
|---|---|---|
| stickerConfirmation | off | UNTESTED (run 43002076982) |
| gifConfirmation | off | TODO |
| voiceConfirmation | off | TODO |
| roundConfirmation | off | TODO |

## Appearance

| Setting | Desktop default | iOS status | Notes |
|---|---|---|---|
| showMessageSeconds | off | TESTED | |
| showPeerId | Bot API | TESTED | ID row in user profiles; on/off only |
| appIcon | default | TODO | |
| monoFont / main font | system | TODO | |
| messageBubbleRadius | 16 | TODO | |
| removeMessageTail | off | TODO | |
| avatarCorners | 23 | TODO | |
| singleCornerRadius | off | TODO | |
| materialSwitches | on | N/A | iOS uses system switches |
| simpleQuotesAndReplies | off | TODO | |
| replaceBottomInfoWithIcons | on | TODO | |
| adaptiveCoverColor | on | TODO | |
| improveLinkPreviews | off | TODO | |
| hideFastShare | off | TODO | |
| showChannelReactions | on | TODO | |
| showGroupReactions | on | TODO | |
| showPrivateChatReactions | on | TODO | |
| wideMultiplier | 1.0 | N/A | Desktop window layout |
| hideNotificationCounters | off | TODO | |
| hideNotificationBadge | off | UNTESTED | Run 43002076982 |
| hideAllChatsFolder | off | TODO | |
| channelBottomButton | Discuss | TODO | |
| quickAdminShortcuts | on | TODO | |

## Message field buttons

| Setting | Desktop default | iOS status |
|---|---|---|
| showAttachButtonInMessageField | on | TODO |
| showCommandsButtonInMessageField | on | TODO |
| showEmojiButtonInMessageField | on | TODO |
| showMicrophoneButtonInMessageField | on | TODO |
| showAutoDeleteButtonInMessageField | on | TODO |
| showGiftButtonInMessageField | on | TODO |
| showAiEditorButtonInMessageField | on | TODO |
| showAttachPopup | on | N/A (hover popup) |
| showEmojiPopup | on | N/A (hover popup) |

## Context menu items

| Setting | Desktop default | iOS status |
|---|---|---|
| showReactionsPanelInContextMenu | Visible | TODO |
| showViewsPanelInContextMenu | Visible | TODO |
| showHideMessageInContextMenu | Hidden | TODO |
| showUserMessagesInContextMenu | With modifier | TODO |
| showMessageDetailsInContextMenu | With modifier | UNTESTED (run 43002076982; on/off) |
| showRepeatMessageInContextMenu | Hidden | TODO |
| showAddFilterInContextMenu | Visible | UNTESTED (run 43002076982; on/off) |

## Side drawer and tray (desktop navigation)

| Setting | iOS status | Notes |
|---|---|---|
| showMyProfileInDrawer, showBotsInDrawer, showNewGroupInDrawer, showNewChannelInDrawer, showContactsInDrawer, showCallsInDrawer, showSavedMessagesInDrawer, showNightModeToggleInDrawer | N/A | iOS has no drawer |
| showLReadToggleInDrawer / showSReadToggleInDrawer | TODO | As quick actions |
| showGhostToggleInDrawer | TODO | Quick ghost toggle outside Settings |
| showStreamerToggleInDrawer | TODO | With streamer mode |
| showGhostToggleInTray / showStreamerToggleInTray | N/A | Could map to home-screen quick actions |

## Larger features

| Feature | iOS status | Notes |
|---|---|---|
| AyuGram settings screen | TESTED | Ghost, history, filters and other sections; Add Filter prompt works |
| Streamer mode | TODO | |
| Message shot (messages as image) | TODO | 7 options |
| Forward without author / from restricted chats / repeat message | TODO | Copy and save in restricted chats is implemented (UNTESTED, no restricted chat at hand) |
| Translator providers (Telegram, Google, Yandex, native) | TODO | |
| Webview options (spoof Android, larger size) | TODO | 3 options |
| `tg://ayu` settings links | TODO | |
| Saved music, cover search | TODO | Low priority |
| Crash reporting to AyuGram | N/A | Deliberately not ported |
| Donate / plugin info boxes | N/A | Desktop project specific |

## iOS-only additions

| Feature | Status | Notes |
|---|---|---|
| Stay Connected in Background | UNTESTED | Starts after restart, location permission granted on the iPad; end-to-end deletion test still open |
| All accounts receive updates at once | UNTESTED | Part of keep-alive |
| Debug log and test override files | TESTED | Test aids; to be removed or hidden before release |
