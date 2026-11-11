// AyuGram: local settings store.
//
// Mirrors the setting names and defaults of AyuGram Desktop (ayu/ayu_settings.h).
// Backed by UserDefaults so it can be read synchronously from any queue.

import Foundation

public final class AyuGramSettings {
    public enum BoolKey: String, CaseIterable {
        // Ghost mode
        case sendReadMessages
        case sendReadStories
        case sendOnlinePackets
        case sendUploadProgress
        case sendOfflinePacketAfterOnline
        case markReadAfterAction
        case useScheduledMessages

        // Message history
        case saveDeletedMessages
        case saveMessagesHistory
        case saveForBots

        // Other
        case disableAds
        case localPremium

        public var defaultValue: Bool {
            switch self {
            case .sendReadMessages, .sendReadStories, .sendOnlinePackets, .sendUploadProgress:
                return true
            case .sendOfflinePacketAfterOnline:
                return false
            case .markReadAfterAction:
                return true
            case .useScheduledMessages:
                return false
            case .saveDeletedMessages, .saveMessagesHistory:
                return true
            case .saveForBots:
                return false
            case .disableAds:
                return true
            case .localPremium:
                return false
            }
        }

        fileprivate var storageKey: String {
            return "ayu.\(self.rawValue)"
        }
    }

    private static let defaults = UserDefaults.standard

    public static func bool(_ key: BoolKey) -> Bool {
        if let value = defaults.object(forKey: key.storageKey) as? Bool {
            return value
        }
        return key.defaultValue
    }

    public static func setBool(_ key: BoolKey, _ value: Bool) {
        defaults.set(value, forKey: key.storageKey)
    }

    // MARK: Ghost mode

    public static var sendReadMessages: Bool { return bool(.sendReadMessages) }
    public static var sendReadStories: Bool { return bool(.sendReadStories) }
    public static var sendOnlinePackets: Bool { return bool(.sendOnlinePackets) }
    public static var sendUploadProgress: Bool { return bool(.sendUploadProgress) }
    public static var sendOfflinePacketAfterOnline: Bool { return bool(.sendOfflinePacketAfterOnline) }

    /// Ghost mode counts as active when every packet type is suppressed, as on desktop.
    public static var isGhostModeActive: Bool {
        return !sendReadMessages && !sendReadStories && !sendOnlinePackets && !sendUploadProgress && sendOfflinePacketAfterOnline
    }

    public static func setGhostModeActive(_ active: Bool) {
        setBool(.sendReadMessages, !active)
        setBool(.sendReadStories, !active)
        setBool(.sendOnlinePackets, !active)
        setBool(.sendUploadProgress, !active)
        setBool(.sendOfflinePacketAfterOnline, active)
    }

    // MARK: One-shot read override

    private static let forcedReadLock = NSLock()
    private static var forcedReadPeerIds = Set<Int64>()

    /// Allows the next read receipt for this peer to be sent even while read receipts are suppressed.
    public static func forceReadOnce(peerId: Int64) {
        forcedReadLock.lock()
        forcedReadPeerIds.insert(peerId)
        forcedReadLock.unlock()
    }

    static func consumeForcedRead(peerId: Int64) -> Bool {
        forcedReadLock.lock()
        defer {
            forcedReadLock.unlock()
        }
        return forcedReadPeerIds.remove(peerId) != nil
    }
}
