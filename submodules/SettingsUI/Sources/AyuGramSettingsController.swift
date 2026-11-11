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

private final class AyuGramSettingsControllerArguments {
    let toggleGhostMode: (Bool) -> Void
    let toggle: (AyuGramSettings.BoolKey, Bool) -> Void

    init(toggleGhostMode: @escaping (Bool) -> Void, toggle: @escaping (AyuGramSettings.BoolKey, Bool) -> Void) {
        self.toggleGhostMode = toggleGhostMode
        self.toggle = toggle
    }
}

private enum AyuGramSettingsSection: Int32 {
    case ghostMaster
    case ghost
    case history
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
    case otherHeader(String)
    case otherToggle(Int32, AyuGramSettings.BoolKey, String, Bool)
    case otherInfo(String)

    var section: ItemListSectionId {
        switch self {
        case .ghostMode, .ghostModeInfo:
            return AyuGramSettingsSection.ghostMaster.rawValue
        case .ghostHeader, .toggle, .ghostInfo:
            return AyuGramSettingsSection.ghost.rawValue
        case .historyHeader, .historyToggle, .historyInfo:
            return AyuGramSettingsSection.history.rawValue
        case .otherHeader, .otherToggle, .otherInfo:
            return AyuGramSettingsSection.other.rawValue
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
        case .historyInfo:
            return 2900
        case .otherHeader:
            return 3000
        case let .otherToggle(index, _, _, _):
            return 3010 + index
        case .otherInfo:
            return 3900
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
        case let .historyHeader(text), let .otherHeader(text):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: text, sectionId: self.section)
        case let .historyToggle(_, key, title, value), let .otherToggle(_, key, title, value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: title, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.toggle(key, value)
            })
        case let .historyInfo(text), let .otherInfo(text):
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
        (.sendOfflinePacketAfterOnline, "Go Offline Immediately")
    ]
    var index: Int32 = 0
    for (key, title) in toggles {
        entries.append(.toggle(index, key, title, AyuGramSettings.bool(key)))
        index += 1
    }
    entries.append(.ghostInfo("With read receipts off, chats are marked as read on this device only. Sending a message still marks the chat as read on the server."))

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
    entries.append(.historyInfo("Deleted messages stay in the chat with a broom mark. Hold an edited message and choose Edit History to see earlier versions."))

    entries.append(.otherHeader("OTHER"))
    let otherToggles: [(AyuGramSettings.BoolKey, String)] = [
        (.disableAds, "Hide Sponsored Messages"),
        (.showMessageSeconds, "Show Seconds in Message Time"),
        (.localPremium, "Local Telegram Premium")
    ]
    index = 0
    for (key, title) in otherToggles {
        entries.append(.otherToggle(index, key, title, AyuGramSettings.bool(key)))
        index += 1
    }
    entries.append(.otherInfo("Local Premium only unlocks features on this device and takes effect after restarting the app."))

    return entries
}

public func ayuGramSettingsController(context: AccountContext) -> ViewController {
    AyuGramSettings.debugLog("ui ayuGramSettingsController created")
    let version = Atomic<Int>(value: 0)
    let versionPromise = ValuePromise<Int>(0, ignoreRepeated: false)
    let bump: () -> Void = {
        versionPromise.set(version.modify { $0 + 1 })
    }

    let arguments = AyuGramSettingsControllerArguments(toggleGhostMode: { value in
        AyuGramSettings.setGhostModeActive(value)
        bump()
    }, toggle: { key, value in
        AyuGramSettings.setBool(key, value)
        bump()
    })

    let signal = combineLatest(context.sharedContext.presentationData, versionPromise.get())
    |> deliverOnMainQueue
    |> map { presentationData, _ -> (ItemListControllerState, (ItemListNodeState, Any)) in
        let controllerState = ItemListControllerState(presentationData: ItemListPresentationData(presentationData), title: .text("AyuGram"), leftNavigationButton: nil, rightNavigationButton: nil, backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back), animateChanges: false)
        let listState = ItemListNodeState(presentationData: ItemListPresentationData(presentationData), entries: ayuGramSettingsControllerEntries(), style: .blocks, emptyStateItem: nil, animateChanges: false)

        return (controllerState, (listState, arguments))
    }

    let controller = ItemListController(context: context, state: signal)
    return controller
}
