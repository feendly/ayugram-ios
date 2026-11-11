// AyuGram: storage for deleted-message marks and edit history.
//
// Deleted messages are kept in Postbox untouched; this store only remembers
// which ones the server deleted, and the previous texts of edited messages.

import Foundation
import Postbox
import SwiftSignalKit

public final class AyuMessagesStore {
    public struct Edit {
        public let text: String
        public let timestamp: Int32
    }

    public static let shared = AyuMessagesStore()

    private let lock = NSLock()
    private let writeQueue = DispatchQueue(label: "ayugram.messages-store")
    private var deletedByKey: [String: Int32] = [:]
    private var editsByKey: [String: [[String: Any]]] = [:]
    private var hiddenKeys = Set<String>()
    private var writeScheduled = false
    private let path: String

    private init() {
        let directory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? NSTemporaryDirectory()
        self.path = (directory as NSString).appendingPathComponent("ayu-messages.plist")
        if let root = NSDictionary(contentsOfFile: self.path) {
            if let deleted = root["deleted"] as? [String: NSNumber] {
                for (key, value) in deleted {
                    self.deletedByKey[key] = value.int32Value
                }
            }
            if let edits = root["edits"] as? [String: [[String: Any]]] {
                self.editsByKey = edits
            }
            if let hidden = root["hidden"] as? [String] {
                self.hiddenKeys = Set(hidden)
            }
        }
    }

    private static func key(_ id: MessageId) -> String {
        return "\(id.peerId.toInt64()):\(id.namespace):\(id.id)"
    }

    public func isDeleted(_ id: MessageId) -> Bool {
        let key = AyuMessagesStore.key(id)
        self.lock.lock()
        defer {
            self.lock.unlock()
        }
        return self.deletedByKey[key] != nil
    }

    public func markDeleted(_ id: MessageId, timestamp: Int32) {
        let key = AyuMessagesStore.key(id)
        self.lock.lock()
        self.deletedByKey[key] = timestamp
        self.lock.unlock()
        self.scheduleWrite()
    }

    public func isHidden(_ id: MessageId) -> Bool {
        let key = AyuMessagesStore.key(id)
        self.lock.lock()
        defer {
            self.lock.unlock()
        }
        return self.hiddenKeys.contains(key)
    }

    public func markHidden(_ id: MessageId) {
        let key = AyuMessagesStore.key(id)
        self.lock.lock()
        self.hiddenKeys.insert(key)
        self.lock.unlock()
        self.scheduleWrite()
    }

    public func addEdit(_ id: MessageId, previousText: String, timestamp: Int32) {
        let key = AyuMessagesStore.key(id)
        self.lock.lock()
        var list = self.editsByKey[key] ?? []
        list.append(["text": previousText, "date": NSNumber(value: timestamp)])
        self.editsByKey[key] = list
        self.lock.unlock()
        self.scheduleWrite()
    }

    public func edits(_ id: MessageId) -> [Edit] {
        let key = AyuMessagesStore.key(id)
        self.lock.lock()
        let list = self.editsByKey[key] ?? []
        self.lock.unlock()
        var result: [Edit] = []
        for item in list {
            if let text = item["text"] as? String {
                let timestamp = (item["date"] as? NSNumber)?.int32Value ?? 0
                result.append(Edit(text: text, timestamp: timestamp))
            }
        }
        return result
    }

    private func scheduleWrite() {
        self.lock.lock()
        let alreadyScheduled = self.writeScheduled
        self.writeScheduled = true
        self.lock.unlock()
        if alreadyScheduled {
            return
        }
        self.writeQueue.asyncAfter(deadline: .now() + 1.0, execute: { [weak self] in
            guard let self = self else {
                return
            }
            self.lock.lock()
            self.writeScheduled = false
            var deleted: [String: NSNumber] = [:]
            for (key, value) in self.deletedByKey {
                deleted[key] = NSNumber(value: value)
            }
            let root: [String: Any] = ["deleted": deleted, "edits": self.editsByKey, "hidden": Array(self.hiddenKeys)]
            self.lock.unlock()
            let _ = (root as NSDictionary).write(toFile: self.path, atomically: true)
        })
    }
}

// Rewrites a message unchanged so its version changes and the chat redraws it.
private func ayuTouchMessage(transaction: Transaction, id: MessageId) {
    transaction.updateMessage(id, update: { currentMessage in
        var storeForwardInfo: StoreMessageForwardInfo?
        if let forwardInfo = currentMessage.forwardInfo {
            storeForwardInfo = StoreMessageForwardInfo(authorId: forwardInfo.author?.id, sourceId: forwardInfo.source?.id, sourceMessageId: forwardInfo.sourceMessageId, date: forwardInfo.date, authorSignature: forwardInfo.authorSignature, psaType: forwardInfo.psaType, flags: forwardInfo.flags)
        }
        return .update(StoreMessage(id: currentMessage.id, customStableId: nil, globallyUniqueId: currentMessage.globallyUniqueId, groupingKey: currentMessage.groupingKey, threadId: currentMessage.threadId, timestamp: currentMessage.timestamp, flags: StoreMessageFlags(currentMessage.flags), tags: currentMessage.tags, globalTags: currentMessage.globalTags, localTags: currentMessage.localTags, forwardInfo: storeForwardInfo, authorId: currentMessage.author?.id, text: currentMessage.text, attributes: currentMessage.attributes, media: currentMessage.media))
    })
}

/// Hides a message on this device only. The message stays on the server and for everyone else.
public func ayuHideMessageLocally(account: Account, id: MessageId) -> Signal<Never, NoError> {
    AyuMessagesStore.shared.markHidden(id)
    return account.postbox.transaction { transaction -> Void in
        ayuTouchMessage(transaction: transaction, id: id)
    }
    |> ignoreValues
}

/// Decides what happens to messages the server reports as deleted.
/// Returns the ids that should really be removed; the rest are kept and marked as deleted.
func ayuKeepRemotelyDeletedMessages(transaction: Transaction, ids: [MessageId]) -> [MessageId] {
    if !AyuGramSettings.bool(.saveDeletedMessages) {
        return ids
    }
    let saveForBots = AyuGramSettings.bool(.saveForBots)
    let timestamp = Int32(Date().timeIntervalSince1970)
    var idsToDelete: [MessageId] = []
    for id in ids {
        if id.namespace != Namespaces.Message.Cloud {
            idsToDelete.append(id)
            continue
        }
        guard let _ = transaction.getMessage(id) else {
            idsToDelete.append(id)
            continue
        }
        if !saveForBots, let user = transaction.getPeer(id.peerId) as? TelegramUser, user.botInfo != nil {
            idsToDelete.append(id)
            continue
        }
        if AyuMessagesStore.shared.isDeleted(id) {
            continue
        }
        AyuMessagesStore.shared.markDeleted(id, timestamp: timestamp)
        AyuGramSettings.debugLog("deleted message kept \(id)")
        // Rewrite the message unchanged so its version changes and the chat redraws it with the deleted mark.
        transaction.updateMessage(id, update: { currentMessage in
            var storeForwardInfo: StoreMessageForwardInfo?
            if let forwardInfo = currentMessage.forwardInfo {
                storeForwardInfo = StoreMessageForwardInfo(authorId: forwardInfo.author?.id, sourceId: forwardInfo.source?.id, sourceMessageId: forwardInfo.sourceMessageId, date: forwardInfo.date, authorSignature: forwardInfo.authorSignature, psaType: forwardInfo.psaType, flags: forwardInfo.flags)
            }
            return .update(StoreMessage(id: currentMessage.id, customStableId: nil, globallyUniqueId: currentMessage.globallyUniqueId, groupingKey: currentMessage.groupingKey, threadId: currentMessage.threadId, timestamp: currentMessage.timestamp, flags: StoreMessageFlags(currentMessage.flags), tags: currentMessage.tags, globalTags: currentMessage.globalTags, localTags: currentMessage.localTags, forwardInfo: storeForwardInfo, authorId: currentMessage.author?.id, text: currentMessage.text, attributes: currentMessage.attributes, media: currentMessage.media))
        })
    }
    return idsToDelete
}
