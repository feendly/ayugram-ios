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
        case streamerMode
        case premiumStickersAsCopy
        case squareAvatars
        case removeMessageTail
        case showMicrophoneButtonInMessageField
        case pauseKeepAliveOnLowBattery
        case showCommandsButtonInMessageField
        case showEmojiButtonInMessageField
        case showAutoDeleteButtonInMessageField
        case showGiftButtonInMessageField
        case hideNotificationCounters
        case lockSendReadMessages
        case lockSendReadStories
        case lockSendOnlinePackets
        case lockSendUploadProgress
        case lockSendOfflinePacketAfterOnline
        case showLReadToggleInDrawer
        case showSReadToggleInDrawer
        case showGhostToggleInDrawer
        case showStreamerToggleInDrawer
        case unlimitedRecentStickers
        case showOnlyAddedEmojisAndStickers
        case showUserMessagesInContextMenu
        case hideFromBlocked
        case cleanLinks
        case cleanLinksStrict
        case suggestGhostModeBeforeViewingStory
        case hideAllChatsFolder
        case collapseSimilarChannels
        case spoofWebviewAsAndroid
        case channelBottomButtonDiscuss
        case channelBottomButtonHidden

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
            case .streamerMode, .hideNotificationCounters:
                return false
            case .premiumStickersAsCopy:
                return true
            case .squareAvatars, .removeMessageTail:
                return false
            case .showMicrophoneButtonInMessageField, .pauseKeepAliveOnLowBattery:
                return true
            case .showCommandsButtonInMessageField, .showEmojiButtonInMessageField, .showAutoDeleteButtonInMessageField, .showGiftButtonInMessageField:
                return true
            case .showReactionsPanelInContextMenu, .showViewsPanelInContextMenu, .showAttachButtonInMessageField:
                return true
            case .showMessageDetailsInContextMenu, .showAddFilterInContextMenu, .showUserMessagesInContextMenu:
                return true
            case .lockSendReadMessages, .lockSendReadStories, .lockSendOnlinePackets, .lockSendUploadProgress, .lockSendOfflinePacketAfterOnline:
                return false
            case .showLReadToggleInDrawer, .showStreamerToggleInDrawer:
                return false
            case .showSReadToggleInDrawer, .showGhostToggleInDrawer, .suggestGhostModeBeforeViewingStory, .collapseSimilarChannels, .channelBottomButtonDiscuss:
                return true
            case .unlimitedRecentStickers, .showOnlyAddedEmojisAndStickers, .hideFromBlocked, .cleanLinks, .cleanLinksStrict, .hideAllChatsFolder, .spoofWebviewAsAndroid, .channelBottomButtonHidden:
                return false
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

    public static var sendReadMessages: Bool {
        readOverrideLock.lock()
        let overrideActive = CFAbsoluteTimeGetCurrent() < readOverrideUntil
        let overrideValue = readOverrideValue
        readOverrideLock.unlock()
        if overrideActive {
            return overrideValue
        }
        return bool(.sendReadMessages)
    }

    // "Read on Local" / "Read on Server": for a short time read receipts are forced off or on,
    // whatever the stored setting says, while every chat is marked as read.
    private static let readOverrideLock = NSLock()
    private static var readOverrideValue: Bool = true
    private static var readOverrideUntil: Double = 0.0

    public static func overrideSendReadMessages(_ value: Bool, seconds: Double) {
        readOverrideLock.lock()
        readOverrideValue = value
        readOverrideUntil = CFAbsoluteTimeGetCurrent() + seconds
        readOverrideLock.unlock()
        debugLog("read override value=\(value) seconds=\(seconds)")
    }

    /// Recent stickers kept on the device (the stock client keeps 20).
    public static var recentStickersLimit: Int {
        return bool(.unlimitedRecentStickers) ? 200 : 20
    }
    public static var sendReadStories: Bool { return bool(.sendReadStories) }
    public static var sendOnlinePackets: Bool { return bool(.sendOnlinePackets) }
    public static var sendUploadProgress: Bool { return bool(.sendUploadProgress) }
    public static var sendOfflinePacketAfterOnline: Bool { return bool(.sendOfflinePacketAfterOnline) }

    /// Ghost mode counts as active when every packet type is suppressed, as on desktop.
    // Each ghost setting, the value it has while ghost mode is on, and its lock.
    // A locked setting is left alone by the ghost mode switch, as on desktop.
    private static let ghostKeys: [(key: BoolKey, ghostValue: Bool, lock: BoolKey)] = [
        (key: .sendReadMessages, ghostValue: false, lock: .lockSendReadMessages),
        (key: .sendReadStories, ghostValue: false, lock: .lockSendReadStories),
        (key: .sendOnlinePackets, ghostValue: false, lock: .lockSendOnlinePackets),
        (key: .sendUploadProgress, ghostValue: false, lock: .lockSendUploadProgress),
        (key: .sendOfflinePacketAfterOnline, ghostValue: true, lock: .lockSendOfflinePacketAfterOnline)
    ]

    public static var isGhostModeActive: Bool {
        var unlockedCount = 0
        for entry in ghostKeys {
            if bool(entry.lock) {
                continue
            }
            unlockedCount += 1
            if bool(entry.key) != entry.ghostValue {
                return false
            }
        }
        return unlockedCount != 0
    }

    public static func setGhostModeActive(_ active: Bool) {
        for entry in ghostKeys {
            if bool(entry.lock) {
                continue
            }
            setBool(entry.key, active ? entry.ghostValue : !entry.ghostValue)
        }
    }

    // MARK: One-shot read override

    private static let forcedReadLock = NSLock()
    private static var forcedReadPeerIds = Set<Int64>()

    // Local Premium: the logged-in accounts are treated as Premium by the client.
    private static let ownAccountLock = NSLock()
    private static var ownAccountIds = Set<Int64>()

    public static func registerOwnAccount(_ peerId: Int64) {
        ownAccountLock.lock()
        ownAccountIds.insert(peerId)
        ownAccountLock.unlock()
    }

    public static func isLocalPremiumAccount(_ peerId: Int64) -> Bool {
        ownAccountLock.lock()
        let isOwn = ownAccountIds.contains(peerId)
        ownAccountLock.unlock()
        return isOwn && bool(.localPremium)
    }

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
    private static var cachedUserIds = Set<Int64>()
    private static let storageKey = "ayu.filters"

    /// Entries of the form "user:<id>" are shadow bans, not text patterns.
    public static let userPrefix = "user:"

    // Call with the lock held.
    private static func rebuildCacheIfNeeded() {
        if cachedPatterns != nil {
            return
        }
        let current = self.patterns
        cachedPatterns = current
        var regexes: [NSRegularExpression] = []
        var userIds = Set<Int64>()
        for pattern in current {
            if pattern.hasPrefix(userPrefix) {
                if let id = Int64(pattern.dropFirst(userPrefix.count)) {
                    userIds.insert(id)
                }
                continue
            }
            if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) {
                regexes.append(regex)
            }
        }
        cachedRegexes = regexes
        cachedUserIds = userIds
    }

    /// Shadow ban: messages from these users are hidden in groups and channels.
    public static func isShadowBanned(_ userId: Int64) -> Bool {
        lock.lock()
        rebuildCacheIfNeeded()
        let result = cachedUserIds.contains(userId)
        lock.unlock()
        return result
    }

    // Blocked users, mirrored from the account's data as it is loaded or changed,
    // so the chat can hide their messages without a database lookup.
    private static let blockedKey = "ayu.blockedPeerIds"
    private static var cachedBlocked: Set<Int64>?

    // Call with the lock held.
    private static func loadedBlocked() -> Set<Int64> {
        if let cachedBlocked = cachedBlocked {
            return cachedBlocked
        }
        let stored = (UserDefaults.standard.array(forKey: blockedKey) as? [NSNumber]) ?? []
        let loaded = Set(stored.map { $0.int64Value })
        cachedBlocked = loaded
        return loaded
    }

    public static func setBlocked(_ peerId: Int64, _ blocked: Bool) {
        lock.lock()
        var current = loadedBlocked()
        var changed = false
        if blocked {
            changed = current.insert(peerId).inserted
        } else {
            changed = current.remove(peerId) != nil
        }
        cachedBlocked = current
        lock.unlock()
        if changed {
            UserDefaults.standard.set(current.map { NSNumber(value: $0) }, forKey: blockedKey)
        }
    }

    public static func isBlocked(_ peerId: Int64) -> Bool {
        lock.lock()
        let result = loadedBlocked().contains(peerId)
        lock.unlock()
        return result
    }

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
        rebuildCacheIfNeeded()
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
