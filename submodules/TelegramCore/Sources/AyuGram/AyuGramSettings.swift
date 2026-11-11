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
        case showMessageSeconds
        case keepAliveInBackground
        case disableStories
        case disableOpenLinkWarning
        case showPeerId
        case sendWithoutSoundAlways
        case sendWithoutSoundInGhost
        case allowSavingRestrictedContent
        case filtersEnabled
        case filtersEnabledInChats
        case hideNotificationBadge
        case stickerConfirmation
        case showMessageDetailsInContextMenu
        case showAddFilterInContextMenu
        case showHideMessageInContextMenu
        case gifConfirmation
        case disableGreetingSticker
        case voiceConfirmation
        case hideSimilarChannels
        case hidePremiumStatuses
        case showChannelReactions
        case showGroupReactions
        case showPrivateChatReactions
        case filterZalgo
        case showRepeatMessageInContextMenu
        case hideFastShare
        case disableCustomBackgrounds
        case semiTransparentDeletedMessages
        case showReactionsPanelInContextMenu
        case showViewsPanelInContextMenu
        case showAttachButtonInMessageField

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
            case .showMessageSeconds:
                return false
            case .keepAliveInBackground:
                return false
            case .disableStories, .disableOpenLinkWarning:
                return false
            case .showPeerId:
                return true
            case .sendWithoutSoundAlways, .sendWithoutSoundInGhost:
                return false
            case .allowSavingRestrictedContent:
                return false
            case .filtersEnabled, .filtersEnabledInChats:
                return false
            case .hideNotificationBadge, .stickerConfirmation:
                return false
            case .showHideMessageInContextMenu, .gifConfirmation, .disableGreetingSticker:
                return false
            case .voiceConfirmation, .hideSimilarChannels, .hidePremiumStatuses:
                return false
            case .showChannelReactions, .showGroupReactions, .showPrivateChatReactions:
                return true
            case .filterZalgo, .showRepeatMessageInContextMenu:
                return false
            case .hideFastShare, .disableCustomBackgrounds, .semiTransparentDeletedMessages:
                return false
            case .showReactionsPanelInContextMenu, .showViewsPanelInContextMenu, .showAttachButtonInMessageField:
                return true
            case .showMessageDetailsInContextMenu, .showAddFilterInContextMenu:
                return true
            }
        }

        fileprivate var storageKey: String {
            return "ayu.\(self.rawValue)"
        }
    }

    private static let defaults = UserDefaults.standard

    public static func bool(_ key: BoolKey) -> Bool {
        if let value = overrideValue(key) {
            return value
        }
        if let value = defaults.object(forKey: key.storageKey) as? Bool {
            return value
        }
        return key.defaultValue
    }

    public static func setBool(_ key: BoolKey, _ value: Bool) {
        defaults.set(value, forKey: key.storageKey)
    }

    /// Text shown next to the time of a message the server deleted.
    public static var deletedMark: String {
        if let value = defaults.string(forKey: "ayu.deletedMark"), !value.isEmpty {
            return value
        }
        return "\u{1F9F9}"
    }

    public static func setDeletedMark(_ value: String) {
        defaults.set(value, forKey: "ayu.deletedMark")
    }

    /// Custom replacement for the "edited" label; nil means the stock label.
    public static var editedMark: String? {
        if let value = defaults.string(forKey: "ayu.editedMark"), !value.isEmpty {
            return value
        }
        return nil
    }

    public static func setEditedMark(_ value: String) {
        defaults.set(value, forKey: "ayu.editedMark")
    }

    // MARK: Test hooks

    // A plist of setting name -> Bool at <tmp>/ayu-override.plist overrides stored values.
    // Used by the on-device test loop to switch settings without touching the UI.
    private static let overrideLock = NSLock()
    private static var overrideCache: [String: Bool] = [:]
    private static var overrideCheckedAt: Double = 0.0

    private static func overrideValue(_ key: BoolKey) -> Bool? {
        overrideLock.lock()
        defer {
            overrideLock.unlock()
        }
        let now = CFAbsoluteTimeGetCurrent()
        if now - overrideCheckedAt > 2.0 {
            overrideCheckedAt = now
            let path = NSTemporaryDirectory() + "ayu-override.plist"
            if let dict = NSDictionary(contentsOfFile: path) as? [String: Bool] {
                overrideCache = dict
            } else {
                overrideCache = [:]
            }
        }
        return overrideCache[key.rawValue]
    }

    private static let logLock = NSLock()

    /// Appends a line to <tmp>/ayu-debug.log.
    public static func debugLog(_ text: String) {
        let line = "\(Date().timeIntervalSince1970) \(text)\n"
        let path = NSTemporaryDirectory() + "ayu-debug.log"
        logLock.lock()
        defer {
            logLock.unlock()
        }
        if let file = fopen(path, "a") {
            fputs(line, file)
            fclose(file)
        }
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

// AyuGram: message filters. Incoming messages whose text matches any pattern are hidden.
public final class AyuFilters {
    private static let lock = NSLock()
    private static var cachedPatterns: [String]?
    private static var cachedRegexes: [NSRegularExpression] = []
    private static let storageKey = "ayu.filters"

    public static var patterns: [String] {
        return (UserDefaults.standard.array(forKey: storageKey) as? [String]) ?? []
    }

    public static func setPatterns(_ patterns: [String]) {
        UserDefaults.standard.set(patterns, forKey: storageKey)
        lock.lock()
        cachedPatterns = nil
        lock.unlock()
    }

    public static func matches(_ text: String) -> Bool {
        if text.isEmpty {
            return false
        }
        lock.lock()
        if cachedPatterns == nil {
            let current = self.patterns
            cachedPatterns = current
            var regexes: [NSRegularExpression] = []
            for pattern in current {
                if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) {
                    regexes.append(regex)
                }
            }
            cachedRegexes = regexes
        }
        let regexes = cachedRegexes
        lock.unlock()
        let range = NSRange(text.startIndex..., in: text)
        for regex in regexes {
            if regex.firstMatch(in: text, options: [], range: range) != nil {
                return true
            }
        }
        return false
    }

    /// True when the text stacks many combining marks on its characters ("zalgo" text).
    public static func isZalgo(_ text: String) -> Bool {
        var combining = 0
        var total = 0
        for scalar in text.unicodeScalars {
            total += 1
            let value = scalar.value
            if (value >= 0x0300 && value <= 0x036F) || (value >= 0x1AB0 && value <= 0x1AFF) || (value >= 0x1DC0 && value <= 0x1DFF) || (value >= 0x20D0 && value <= 0x20FF) || (value >= 0xFE20 && value <= 0xFE2F) {
                combining += 1
            }
        }
        return combining >= 12 && combining * 3 >= total
    }

    public static func shouldHide(text: String, isIncoming: Bool, isPrivateChat: Bool) -> Bool {
        if !isIncoming || !AyuGramSettings.bool(.filtersEnabled) {
            return false
        }
        if isPrivateChat && !AyuGramSettings.bool(.filtersEnabledInChats) {
            return false
        }
        if AyuGramSettings.bool(.filterZalgo) && isZalgo(text) {
            return true
        }
        return matches(text)
    }
}
