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
}

private enum AyuGramSettingsEntry: ItemListNodeEntry {
    case ghostMode(Bool)
    case ghostModeInfo(String)
    case ghostHeader(String)
    case toggle(Int32, AyuGramSettings.BoolKey, String, Bool)
    case ghostInfo(String)

    var section: ItemListSectionId {
        switch self {
        case .ghostMode, .ghostModeInfo:
            return AyuGramSettingsSection.ghostMaster.rawValue
        case .ghostHeader, .toggle, .ghostInfo:
            return AyuGramSettingsSection.ghost.rawValue
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
        }
    }
}

private func ayuGramSettingsControllerEntries() -> [AyuGramSettingsEntry] {
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

    return entries
}

public func ayuGramSettingsController(context: AccountContext) -> ViewController {
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
