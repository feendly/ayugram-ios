# AyuGram feature inventory

Source of truth: `AyuGramDesktop/Telegram/SourceFiles/ayu/` (shallow clone,
November 2026), mainly `ayu_settings.h` for setting names and defaults.
Desktop paths below are relative to `Telegram/SourceFiles/ayu/`.
iOS paths are relative to `submodules/TelegramCore/Sources/` unless noted.

Status key: every row is **planned**. Nothing here is implemented or tested
yet. iOS hook files were located by search and still need to be read in full.

## 1. Ghost mode (per account, optional global)

Desktop: `ayu_settings.h` (`GhostModeAccountSettings`), `ayu_worker.cpp`,
`utils/telegram_helpers.cpp`.

| Setting | Default | Behaviour | iOS hook |
|---|---|---|---|
| `sendReadMessages` | true | When off, never send read receipts for messages | `State/SynchronizePeerReadState.swift`, `State/ManagedConsumePersonalMessagesActions.swift`, `State/ManagedSynchronizeConsumeMessageContentsOperations.swift` |
| `sendReadStories` | true | When off, never report stories as viewed | `State/ManagedSynchronizeViewStoriesOperations.swift` |
| `sendOnlinePackets` | true | When off, never send `account.updateStatus(offline:false)` | `State/ManagedAccountPresence.swift` |
| `sendUploadProgress` | true | When off, never send typing / uploading / recording activity | `State/ManagedLocalInputActivities.swift`, `State/TypingDraftStop.swift` |
| `sendOfflinePacketAfterOnline` | false | Every 3 s, if the account looks online, send `updateStatus(offline:true)` | new timer next to `ManagedAccountPresence` |
| `markReadAfterAction` | true | Sending a message or reaction marks the chat read even in ghost mode | send path + reaction path, explicit one-off read |
| `useScheduledMessages` | false | Send messages as scheduled (+ a few seconds) so sending does not flip the account online | enqueue path, schedule time attribute |
| `sendWithoutSound` | Never | Never / InGhostMode / Always: send silently | enqueue path, silent flag |
| `suggestGhostModeBeforeViewingStory` | true | Prompt to enable ghost mode before opening a story | story open path in TelegramUI |
| `ghostModeActive` | false | Master toggle that applies the five packet settings at once | settings model |
| `*Locked` (5 flags) | false | Excludes a packet setting from the master toggle | settings model |
| `useGlobalGhostMode` | true | One ghost configuration for all accounts instead of per account | settings model |

Extra desktop actions to port: "Read message" context item (explicit read
while ghost is on), "Read on server" / "Read locally" drawer toggles.

## 2. Message history and anti-recall

Desktop: `data/ayu_database.cpp`, `data/entities.h`,
`data/messages_storage.cpp`, `ui/message_history/*`, `ui/boxes/edit_mark_box.cpp`.

| Setting | Default | Behaviour |
|---|---|---|
| `saveDeletedMessages` | true | Keep messages others delete; show them with the deleted mark |
| `saveMessagesHistory` | true | Keep each prior version of an edited message; viewer per message |
| `saveForBots` | false | Also save for bot chats |
| `deletedMark` | "🧹" | Text/emoji shown on deleted messages |
| `editedMark` | localized "edited" | Text shown on edited messages |
| `semiTransparentDeletedMessages` | false | Draw deleted messages at reduced opacity |

iOS plan: intercept deletions and edits in
`State/Sync/UpdateInterpreter.swift` and `State/Sync/ChannelPolling.swift`
before they reach Postbox. For deletions, keep the message in Postbox and tag
it with a local "deleted" attribute instead of removing it; copy edits into a
separate SQLite database in the app group container. Also handle self-destruct
media, history clears and chat deletions the way desktop does (to be read in
`messages_storage.cpp`). Always-on capture while backgrounded is Phase 4.

## 3. Message filters

Desktop: `features/filters/*`, `ui/settings/filters/*`,
`ui/boxes/import_filters_box.cpp`.

| Setting | Default | Behaviour |
|---|---|---|
| `filtersEnabled` | false | Hide messages matching regex filters |
| `filtersEnabledInChats` | false | Apply filters in private chats too |
| `hideFromBlocked` | false | Hide messages from blocked users in groups |
| `shadowBanIds` | empty | Locally hide all messages from chosen users |
| `filterZalgo` | false | Strip zalgo combining characters |

Global and per-chat filter lists, import/export, "Add filter" context item.

## 4. Local Telegram Premium and annoyances

| Setting | Default | Behaviour | iOS hook |
|---|---|---|---|
| `localPremium` | false | Treat the account as Premium locally (UI unlocks only) | `SyncCore/SyncCore_TelegramUser.swift` `isPremium`, premium checks in TelegramUI |
| `disableAds` | true | No sponsored messages | `TelegramEngine/Messages/AdMessages.swift` |
| `disableStories` | false | Hide stories everywhere | story list components |
| `disableCustomBackgrounds` | false | Ignore per-chat wallpapers | chat background resolution |
| `disableOpenLinkWarning` | false | Skip "open this link?" prompt | link open path |
| `disableNotificationsDelay` | false | Remove notification delay | notification scheduling |
| `disableGreetingSticker` | false | No greeting sticker in empty chats | empty chat component |
| `hidePremiumStatuses` | false | Hide premium/emoji status badges | peer title components |
| `collapseSimilarChannels` / `hideSimilarChannels` | true / false | Similar channels block | channel join service message |
| `showOnlyAddedEmojisAndStickers` | false | Hide featured/suggested packs | sticker and emoji panels |
| `unlimitedRecentStickers` | false | Lift the recent sticker cap | recent stickers store |

## 5. Confirmations

`stickerConfirmation`, `gifConfirmation`, `voiceConfirmation`,
`roundConfirmation` (all false): ask before sending that media type.

## 6. Appearance and customization

Desktop: `ui/settings/settings_appearance.cpp`, `ui/boxes/font_selector.cpp`,
`ui/components/icon_picker.cpp`, `ui/ayu_userpic.cpp`.

| Setting | Default | Behaviour |
|---|---|---|
| `appIcon` | default | Alternate app icons (iOS: alternate icons API) |
| `monoFont` + main font selector | system | Custom UI and monospace fonts |
| `messageBubbleRadius` | 16 | Bubble corner radius |
| `removeMessageTail` | false | Bubbles without tails |
| `avatarCorners` / `singleCornerRadius` | 23 / false | Avatar shape from square to circle |
| `materialSwitches` | true | Switch style |
| `simpleQuotesAndReplies` | false | Plain reply/quote blocks |
| `replaceBottomInfoWithIcons` | true | Icons instead of text for edited/deleted marks |
| `showMessageSeconds` | false | Seconds in message timestamps |
| `showPeerId` | BotApi | Show user/chat ID in profiles (Hidden / Telegram API / Bot API) |
| `adaptiveCoverColor` | true | Profile cover colour from avatar |
| `improveLinkPreviews` | false | Rewrite links for better previews |
| `hideFastShare` | false | Hide the quick share button beside messages |
| `showChannelReactions` / `showGroupReactions` / `showPrivateChatReactions` | true | Show reactions per chat type |
| `wideMultiplier` | 1.0 | Wider message column (desktop layout; iPad only) |
| `hideNotificationCounters` / `hideNotificationBadge` | false | Unread counters and app badge |
| `hideAllChatsFolder` | false | Hide the "All chats" folder tab |
| `channelBottomButton` | DiscussWithFallback | Channel bottom bar: hidden / mute / discuss |
| `quickAdminShortcuts` | true | Quick admin actions in groups |

## 7. Message field and menus

- Message field buttons, each toggleable (all true): attach, commands, emoji,
  microphone, auto-delete, gift, AI editor; `showAttachPopup`, `showEmojiPopup`.
- Context menu items with Hidden / Visible / VisibleWithModifier:
  reactions panel (Visible), views panel (Visible), hide message (Hidden),
  user messages (Modifier), message details (Modifier), repeat message
  (Hidden), add filter (Visible). iOS has no modifier key; map
  "VisibleWithModifier" to a secondary submenu.
- Drawer items (desktop side menu): my profile, bots, new group, new channel,
  contacts, calls, saved messages, read toggles, night mode, ghost toggle,
  streamer toggle. iOS has no drawer; ghost and streamer toggles go in the
  AyuGram settings screen and a chat-list quick action.
- Tray toggles (`showGhostToggleInTray`, `showStreamerToggleInTray`):
  desktop only. Closest iOS equivalent: home-screen quick actions.

## 8. Streamer mode

Desktop: `features/streamer_mode/*`. `streamerMode` (false) hides the window
from screen capture and masks sensitive data. iOS plan: mask phone numbers and
private content while screen recording/mirroring is active
(`UIScreen.isCaptured`).

## 9. Message shot

Desktop: `features/message_shot/*`, `ui/boxes/message_shot_box.cpp`.
`showMessageShot` (true): render selected messages to an image, with options
`showBackground` (true), `showDate` (false), `showReactions` (false),
`showHeaderDecorations` (true), `showColorfulReplies` (true),
`revealSpoilers` (true), plus theme choice.

## 10. Forwarding and translation

- `features/forward/*`: forward without author, forward from chats with
  restricted saving (re-upload), "repeat message".
- `features/translator/*`: `translationProvider` (Telegram / Google / Yandex /
  Native). iOS "Native" maps to Apple's Translation framework.

## 11. Webview

`spoofWebviewAsAndroid`, `increaseWebviewHeight`, `increaseWebviewWidth`
(all false): mini-app webview tweaks.

## 12. Misc

- `ayu_url_handlers.cpp`: `tg://ayu/...` links that open AyuGram settings.
- `crashReporting` (true): AyuGram's own crash reporting. Will NOT be ported
  as-is; it would send data to AyuGram's servers from an unofficial build.
- Donate / plugin info boxes: desktop project specific, not ported.
- Saved music component, iTunes cover search: cosmetic, low priority.

## Not yet read in full

The settings header was read completely. The implementation files for
filters, forwarding, message shot and translator were only listed, so details
in sections 3, 9 and 10 can still change. The diff of AyuGram against upstream
tdesktop (patches outside `ayu/`) has not been done and may reveal more.
