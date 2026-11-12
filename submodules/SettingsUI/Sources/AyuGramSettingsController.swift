// AyuGram: settings screen.

import Foundation
import UIKit
import Display
import SwiftSignalKit
import TelegramCore
import TelegramPresentationData
import ItemListUI
import PresentationDataUtils
import AccountContext
import PromptUI

private final class AyuGramSettingsControllerArguments {
    let toggleGhostMode: (Bool) -> Void
    let toggle: (AyuGramSettings.BoolKey, Bool) -> Void
    let addFilter: () -> Void
    let removeFilter: (String) -> Void
    let editDeletedMark: () -> Void
    let editEditedMark: () -> Void

    init(toggleGhostMode: @escaping (Bool) -> Void, toggle: @escaping (AyuGramSettings.BoolKey, Bool) -> Void, addFilter: @escaping () -> Void, removeFilter: @escaping (String) -> Void, editDeletedMark: @escaping () -> Void, editEditedMark: @escaping () -> Void) {
        self.toggleGhostMode = toggleGhostMode
        self.toggle = toggle
        self.addFilter = addFilter
        self.removeFilter = removeFilter
        self.editDeletedMark = editDeletedMark
        self.editEditedMark = editEditedMark
    }
}

private enum AyuGramSettingsSection: Int32 {
    case ghostMaster
    case ghost
    case history
    case filters
    case other
}

private enum AyuGramSettingsEntry: ItemListNodeEntry {
    case ghostMode(Bool)
    case ghostModeInfo(String)
    case ghostHeader(String)
    case toggle(Int32, AyuGramSettings.BoolKey, String, Bool)
    case ghostInfo(String)
    case historyHeader(String)
    case historyToggle(Int32, AyuGramSettings.BoolKey, String, Bool)
    case historyInfo(String)
    case historyDeletedMark(String)
    case historyEditedMark(String)
    case otherHeader(String)
    case otherToggle(Int32, AyuGramSettings.BoolKey, String, Bool)
    case otherInfo(String)
    case filterHeader(String)
    case filterToggle(Int32, AyuGramSettings.BoolKey, String, Bool)
    case filterPattern(Int32, String)
    case filterAdd(String)
    case filterInfo(String)

    var section: ItemListSectionId {
        switch self {
        case .ghostMode, .ghostModeInfo:
            return AyuGramSettingsSection.ghostMaster.rawValue
        case .ghostHeader, .toggle, .ghostInfo:
            return AyuGramSettingsSection.ghost.rawValue
        case .historyHeader, .historyToggle, .historyInfo, .historyDeletedMark, .historyEditedMark:
            return AyuGramSettingsSection.history.rawValue
        case .otherHeader, .otherToggle, .otherInfo:
            return AyuGramSettingsSection.other.rawValue
        case .filterHeader, .filterToggle, .filterPattern, .filterAdd, .filterInfo:
            return AyuGramSettingsSection.filters.rawValue
        }
    }

    var stableId: Int32 {
        switch self {
        case .ghostMode:
            return 0
        case .ghostModeInfo:
            return 1
        case .ghostHeader:
            return 2
        case let .toggle(index, _, _, _):
            return 10 + index
        case .ghostInfo:
            return 1000
        case .historyHeader:
            return 2000
        case let .historyToggle(index, _, _, _):
            return 2010 + index
        case .historyDeletedMark:
            return 2898
        case .historyEditedMark:
            return 2899
        case .historyInfo:
            return 2900
        case .otherHeader:
            return 3000
        case let .otherToggle(index, _, _, _):
            return 3010 + index
        case .otherInfo:
            return 3900
        case .filterHeader:
            return 2950
        case let .filterToggle(index, _, _, _):
            return 2951 + index
        case let .filterPattern(index, _):
            return 2960 + index
        case .filterAdd:
            return 2998
        case .filterInfo:
            return 2999
        }
    }

    static func ==(lhs: AyuGramSettingsEntry, rhs: AyuGramSettingsEntry) -> Bool {
        switch lhs {
        case let .ghostMode(value):
            if case .ghostMode(value) = rhs {
                return true
            } else {
                return false
            }
        case let .ghostModeInfo(text):
            if case .ghostModeInfo(text) = rhs {
                return true
            } else {
                return false
            }
        case let .ghostHeader(text):
            if case .ghostHeader(text) = rhs {
                return true
            } else {
                return false
            }
        case let .toggle(index, key, title, value):
            if case .toggle(index, key, title, value) = rhs {
                return true
            } else {
                return false
            }
        case let .ghostInfo(text):
            if case .ghostInfo(text) = rhs {
                return true
            } else {
                return false
            }
        case let .historyHeader(text):
            if case .historyHeader(text) = rhs {
                return true
            } else {
                return false
            }
        case let .historyToggle(index, key, title, value):
            if case .historyToggle(index, key, title, value) = rhs {
                return true
            } else {
                return false
            }
        case let .historyInfo(text):
            if case .historyInfo(text) = rhs {
                return true
            } else {
                return false
            }
        case let .historyDeletedMark(text):
            if case .historyDeletedMark(text) = rhs {
                return true
            } else {
                return false
            }
        case let .historyEditedMark(text):
            if case .historyEditedMark(text) = rhs {
                return true
            } else {
                return false
            }
        case let .otherHeader(text):
            if case .otherHeader(text) = rhs {
                return true
            } else {
                return false
            }
        case let .otherToggle(index, key, title, value):
            if case .otherToggle(index, key, title, value) = rhs {
                return true
            } else {
                return false
            }
        case let .otherInfo(text):
            if case .otherInfo(text) = rhs {
                return true
            } else {
                return false
            }
        case let .filterHeader(text):
            if case .filterHeader(text) = rhs {
                return true
            } else {
                return false
            }
        case let .filterToggle(index, key, title, value):
            if case .filterToggle(index, key, title, value) = rhs {
                return true
            } else {
                return false
            }
        case let .filterPattern(index, pattern):
            if case .filterPattern(index, pattern) = rhs {
                return true
            } else {
                return false
            }
        case let .filterAdd(text):
            if case .filterAdd(text) = rhs {
                return true
            } else {
                return false
            }
        case let .filterInfo(text):
            if case .filterInfo(text) = rhs {
                return true
            } else {
                return false
            }
        }
    }

    static func <(lhs: AyuGramSettingsEntry, rhs: AyuGramSettingsEntry) -> Bool {
        return lhs.stableId < rhs.stableId
    }

    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        let arguments = arguments as! AyuGramSettingsControllerArguments
        switch self {
        case let .ghostMode(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "Ghost Mode", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.toggleGhostMode(value)
            })
        case let .ghostModeInfo(text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
        case let .ghostHeader(text):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: text, sectionId: self.section)
        case let .toggle(_, key, title, value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: title, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.toggle(key, value)
            })
        case let .ghostInfo(text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
        case let .filterPattern(_, pattern):
            return ItemListActionItem(presentationData: presentationData, systemStyle: .glass, title: pattern, kind: .destructive, alignment: .natural, sectionId: self.section, style: .blocks, action: {
                arguments.removeFilter(pattern)
            })
        case let .historyDeletedMark(text):
            return ItemListActionItem(presentationData: presentationData, systemStyle: .glass, title: text, kind: .generic, alignment: .natural, sectionId: self.section, style: .blocks, action: {
                arguments.editDeletedMark()
            })
        case let .historyEditedMark(text):
            return ItemListActionItem(presentationData: presentationData, systemStyle: .glass, title: text, kind: .generic, alignment: .natural, sectionId: self.section, style: .blocks, action: {
                arguments.editEditedMark()
            })
        case let .filterAdd(text):
            return ItemListActionItem(presentationData: presentationData, systemStyle: .glass, title: text, kind: .generic, alignment: .natural, sectionId: self.section, style: .blocks, action: {
                arguments.addFilter()
            })
        case let .historyHeader(text), let .otherHeader(text), let .filterHeader(text):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: text, sectionId: self.section)
        case let .historyToggle(_, key, title, value), let .otherToggle(_, key, title, value), let .filterToggle(_, key, title, value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: title, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.toggle(key, value)
            })
        case let .historyInfo(text), let .otherInfo(text), let .filterInfo(text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
        }
    }
}

private func ayuGramSettingsControllerEntries() -> [AyuGramSettingsEntry] {
    AyuGramSettings.debugLog("ui building entries")
    var entries: [AyuGramSettingsEntry] = []

    entries.append(.ghostMode(AyuGramSettings.isGhostModeActive))
    entries.append(.ghostModeInfo("Turns off every packet below at once and sends an offline status after any activity."))

    entries.append(.ghostHeader("GHOST ESSENTIALS"))
    let toggles: [(AyuGramSettings.BoolKey, String)] = [
        (.sendReadMessages, "Send Read Receipts"),
        (.sendReadStories, "Send Story Views"),
        (.sendOnlinePackets, "Send Online Status"),
        (.sendUploadProgress, "Send Typing Status"),
        (.sendOfflinePacketAfterOnline, "Go Offline Immediately"),
        (.useScheduledMessages, "Send via Schedule (No Online)"),
        (.sendWithoutSoundInGhost, "Send Silently in Ghost Mode"),
        (.sendWithoutSoundAlways, "Always Send Silently"),
        (.lockSendReadMessages, "Lock Read Receipts"),
        (.lockSendReadStories, "Lock Story Views"),
        (.lockSendOnlinePackets, "Lock Online Status"),
        (.lockSendUploadProgress, "Lock Typing Status"),
        (.lockSendOfflinePacketAfterOnline, "Lock Go Offline Immediately")
    ]
    var index: Int32 = 0
    for (key, title) in toggles {
        entries.append(.toggle(index, key, title, AyuGramSettings.bool(key)))
        index += 1
    }
    entries.append(.ghostInfo("With read receipts off, chats are marked as read on this device only. Sending a message still marks the chat as read on the server. A locked setting keeps its value when Ghost Mode is switched. Hold the Settings tab for the quick menu."))

    entries.append(.historyHeader("MESSAGE HISTORY"))
    let historyToggles: [(AyuGramSettings.BoolKey, String)] = [
        (.saveDeletedMessages, "Save Deleted Messages"),
        (.saveMessagesHistory, "Save Edit History"),
        (.saveForBots, "Save in Bot Chats")
    ]
    index = 0
    for (key, title) in historyToggles {
        entries.append(.historyToggle(index, key, title, AyuGramSettings.bool(key)))
        index += 1
    }
    entries.append(.historyDeletedMark("Deleted Mark: \(AyuGramSettings.deletedMark)"))
    entries.append(.historyEditedMark("Edited Mark: \(AyuGramSettings.editedMark ?? "edited")"))
    entries.append(.historyInfo("Deleted messages stay in the chat with a broom mark. Hold an edited message and choose Edit History to see earlier versions."))

    entries.append(.filterHeader("MESSAGE FILTERS"))
    entries.append(.filterToggle(0, .filtersEnabled, "Enable Filters", AyuGramSettings.bool(.filtersEnabled)))
    entries.append(.filterToggle(1, .filtersEnabledInChats, "Also in Private Chats", AyuGramSettings.bool(.filtersEnabledInChats)))
    entries.append(.filterToggle(2, .filterZalgo, "Hide Zalgo Text", AyuGramSettings.bool(.filterZalgo)))
    entries.append(.filterToggle(3, .hideFromBlocked, "Hide Messages from Blocked Users in Groups", AyuGramSettings.bool(.hideFromBlocked)))
    var filterIndex: Int32 = 0
    for pattern in AyuFilters.patterns.prefix(30) {
        entries.append(.filterPattern(filterIndex, pattern))
        filterIndex += 1
    }
    entries.append(.filterAdd("Add Filter"))
    entries.append(.filterInfo("Incoming messages matching any filter (regular expression, case-insensitive) are hidden. Entries like user:123 are shadow bans (added from the message menu in groups): that user's messages are hidden in groups. Tap an entry to remove it."))

    entries.append(.otherHeader("OTHER"))
    let otherToggles: [(AyuGramSettings.BoolKey, String)] = [
        (.disableAds, "Hide Sponsored Messages"),
        (.showMessageSeconds, "Show Seconds in Message Time"),
        (.localPremium, "Local Telegram Premium"),
        (.keepAliveInBackground, "Stay Connected in Background"),
        (.pauseKeepAliveOnLowBattery, "Pause Background Connection Below 15% Battery"),
        (.disableStories, "Hide Stories in Chat List"),
        (.disableOpenLinkWarning, "Skip Hidden Link Warning"),
        (.showPeerId, "Show User ID in Profile"),
        (.allowSavingRestrictedContent, "Allow Copy and Save in Restricted Chats"),
        (.hideNotificationBadge, "Hide App Icon Badge"),
        (.stickerConfirmation, "Confirm Before Sending Stickers"),
        (.showMessageDetailsInContextMenu, "Message Details in Message Menu"),
        (.showAddFilterInContextMenu, "Add to Filters in Message Menu"),
        (.showHideMessageInContextMenu, "Hide in Message Menu"),
        (.showRepeatMessageInContextMenu, "Repeat in Message Menu"),
        (.showUserMessagesInContextMenu, "User Messages in Message Menu (Groups)"),
        (.showReactionsPanelInContextMenu, "Reactions Bar in Message Menu"),
        (.showViewsPanelInContextMenu, "Read and Reactions Row in Message Menu"),
        (.showAttachButtonInMessageField, "Attach Button in Message Field"),
        (.showEmojiButtonInMessageField, "Emoji Button in Message Field"),
        (.showMicrophoneButtonInMessageField, "Microphone Button in Message Field"),
        (.showCommandsButtonInMessageField, "Bot Commands Button in Message Field"),
        (.showAutoDeleteButtonInMessageField, "Auto-Delete Button in Message Field"),
        (.showGiftButtonInMessageField, "Gift Button in Message Field"),
        (.hideFastShare, "Hide Quick Share Button"),
        (.disableCustomBackgrounds, "Ignore Per-Chat Backgrounds"),
        (.semiTransparentDeletedMessages, "Dim Deleted Messages"),
        (.streamerMode, "Streamer Mode (Hide Phone Number)"),
        (.premiumStickersAsCopy, "Send Premium Stickers as a Copy"),
        (.squareAvatars, "Rounded-Square Avatars (Restart to Apply)"),
        (.removeMessageTail, "No Tail on Message Bubbles"),
        (.hideNotificationCounters, "Hide Unread Counter on Chats Tab"),
        (.gifConfirmation, "Confirm Before Sending GIFs"),
        (.disableGreetingSticker, "No Greeting Sticker in Empty Chats"),
        (.voiceConfirmation, "Confirm Before Sending Recordings"),
        (.hideSimilarChannels, "Hide Similar Channels"),
        (.hidePremiumStatuses, "Hide Premium Badges in Chat List"),
        (.showChannelReactions, "Show Reactions in Channels"),
        (.showGroupReactions, "Show Reactions in Groups"),
        (.showPrivateChatReactions, "Show Reactions in Private Chats"),
        (.unlimitedRecentStickers, "Keep Up to 200 Recent Stickers"),
        (.showOnlyAddedEmojisAndStickers, "Only Added Sticker Packs in Sticker Panel"),
        (.showGhostToggleInDrawer, "Ghost Mode in Settings Tab Menu"),
        (.showStreamerToggleInDrawer, "Streamer Mode in Settings Tab Menu"),
        (.showLReadToggleInDrawer, "Read on Local in Settings Tab Menu"),
        (.showSReadToggleInDrawer, "Read on Server in Settings Tab Menu")
    ]
    index = 0
    for (key, title) in otherToggles {
        entries.append(.otherToggle(index, key, title, AyuGramSettings.bool(key)))
        index += 1
    }
    entries.append(.otherInfo("Local Premium only unlocks features on this device and takes effect after restarting the app. Staying connected in the background uses location access to keep the app running so deleted messages are caught while it is closed; it also takes effect after a restart and uses more battery."))

    return entries
}

public func ayuGramSettingsController(context: AccountContext) -> ViewController {
    AyuGramSettings.debugLog("ui ayuGramSettingsController created")
    let version = Atomic<Int>(value: 0)
    let versionPromise = ValuePromise<Int>(0, ignoreRepeated: false)
    let bump: () -> Void = {
        versionPromise.set(version.modify { $0 + 1 })
    }

    var presentControllerImpl: ((ViewController) -> Void)?

    let arguments = AyuGramSettingsControllerArguments(toggleGhostMode: { value in
        AyuGramSettings.setGhostModeActive(value)
        bump()
    }, toggle: { key, value in
        AyuGramSettings.setBool(key, value)
        bump()
    }, addFilter: {
        let controller = promptController(context: context, text: "Add Filter", subtitle: "Regular expression. Matching incoming messages are hidden.", value: nil, placeholder: "word or regex", apply: { value in
            guard let value = value?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else {
                return
            }
            var patterns = AyuFilters.patterns
            if !patterns.contains(value) {
                patterns.append(value)
            }
            AyuFilters.setPatterns(patterns)
            bump()
        })
        presentControllerImpl?(controller)
    }, removeFilter: { pattern in
        AyuFilters.setPatterns(AyuFilters.patterns.filter { $0 != pattern })
        bump()
    }, editDeletedMark: {
        let controller = promptController(context: context, text: "Deleted Mark", subtitle: "Shown next to the time of deleted messages. Leave empty for the default.", value: AyuGramSettings.deletedMark, placeholder: "mark", apply: { value in
            guard let value = value else {
                return
            }
            AyuGramSettings.setDeletedMark(value.trimmingCharacters(in: .whitespacesAndNewlines))
            bump()
        })
        presentControllerImpl?(controller)
    }, editEditedMark: {
        let controller = promptController(context: context, text: "Edited Mark", subtitle: "Replaces the \"edited\" label on edited messages. Leave empty for the default.", value: AyuGramSettings.editedMark, placeholder: "edited", apply: { value in
            guard let value = value else {
                return
            }
            AyuGramSettings.setEditedMark(value.trimmingCharacters(in: .whitespacesAndNewlines))
            bump()
        })
        presentControllerImpl?(controller)
    })

    let signal = combineLatest(context.sharedContext.presentationData, versionPromise.get())
    |> deliverOnMainQueue
    |> map { presentationData, _ -> (ItemListControllerState, (ItemListNodeState, Any)) in
        let controllerState = ItemListControllerState(presentationData: ItemListPresentationData(presentationData), title: .text("AyuGram"), leftNavigationButton: nil, rightNavigationButton: nil, backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back), animateChanges: false)
        let listState = ItemListNodeState(presentationData: ItemListPresentationData(presentationData), entries: ayuGramSettingsControllerEntries(), style: .blocks, emptyStateItem: nil, animateChanges: false)

        return (controllerState, (listState, arguments))
    }

    let controller = ItemListController(context: context, state: signal)
    presentControllerImpl = { [weak controller] c in
        controller?.present(c, in: .window(.root))
    }
    return controller
}
