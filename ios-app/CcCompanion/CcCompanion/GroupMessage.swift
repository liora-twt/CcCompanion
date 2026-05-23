//
//  GroupMessage.swift
//  CcCompanion
//
//  Workgroup chat records from apns-server /group endpoints.
//

import Foundation
import SwiftUI
import UIKit

nonisolated struct GroupMessage: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let ts: String
    let conversationId: String?
    let senderId: String
    let senderModel: String?
    let text: String
    let mentions: [String]
    let parentMsgId: String?
    let replyTo: String?
    let source: String?
    let messageType: String
    let taskId: String?
    let parentTaskId: String?
    let owner: String?

    enum CodingKeys: String, CodingKey {
        case id, ts, text, mentions, source, owner
        case conversationId = "conversation_id"
        case senderId = "sender_id"
        case senderModel = "sender_model"
        case parentMsgId = "parent_msg_id"
        case replyTo = "reply_to"
        case messageType = "message_type"
        case taskId = "task_id"
        case parentTaskId = "parent_task_id"
    }

    init(
        id: String,
        ts: String,
        conversationId: String? = nil,
        senderId: String,
        senderModel: String? = nil,
        text: String,
        mentions: [String] = [],
        parentMsgId: String? = nil,
        replyTo: String? = nil,
        source: String? = nil,
        messageType: String = "chat",
        taskId: String? = nil,
        parentTaskId: String? = nil,
        owner: String? = nil
    ) {
        self.id = id
        self.ts = ts
        self.conversationId = conversationId
        self.senderId = senderId
        self.senderModel = senderModel
        self.text = text
        self.mentions = mentions
        self.parentMsgId = parentMsgId
        self.replyTo = replyTo
        self.source = source
        self.messageType = messageType
        self.taskId = taskId
        self.parentTaskId = parentTaskId
        self.owner = owner
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try c.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        self.ts = try c.decodeIfPresent(String.self, forKey: .ts) ?? ""
        self.conversationId = try c.decodeIfPresent(String.self, forKey: .conversationId)
        self.senderId = try c.decodeIfPresent(String.self, forKey: .senderId) ?? "unknown"
        self.senderModel = try c.decodeIfPresent(String.self, forKey: .senderModel)
        self.text = try c.decodeIfPresent(String.self, forKey: .text) ?? ""
        self.mentions = try c.decodeIfPresent([String].self, forKey: .mentions) ?? []
        self.parentMsgId = try c.decodeIfPresent(String.self, forKey: .parentMsgId)
        self.replyTo = try c.decodeIfPresent(String.self, forKey: .replyTo)
        self.source = try c.decodeIfPresent(String.self, forKey: .source)
        self.messageType = try c.decodeIfPresent(String.self, forKey: .messageType) ?? "chat"
        self.taskId = try c.decodeIfPresent(String.self, forKey: .taskId)
        self.parentTaskId = try c.decodeIfPresent(String.self, forKey: .parentTaskId)
        self.owner = try c.decodeIfPresent(String.self, forKey: .owner)
    }

    var isHumanSender: Bool { senderId == "amian" }
    var isShip: Bool { messageType == "ship" }
    var isTask: Bool { messageType == "task" }
    var isBlock: Bool { messageType == "block" }

    var shortTime: String {
        guard let tIndex = ts.firstIndex(of: "T") else { return "" }
        let afterT = ts[ts.index(after: tIndex)...]
        return String(afterT.prefix(5))
    }
}

nonisolated struct GroupMember: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let displayName: String
    let kind: String?
    let avatar: String?
    let color: String?
    let model: String?
    let tmux: String?
    let canReply: Bool?
    let optional: Bool?
    let customAvatarURL: String?

    enum CodingKeys: String, CodingKey {
        case id, kind, avatar, color, model, tmux, optional
        case displayName = "display_name"
        case canReply = "can_reply"
        case customAvatarURL = "custom_avatar_url"
    }

    init(
        id: String,
        displayName: String,
        kind: String? = nil,
        avatar: String? = nil,
        color: String? = nil,
        model: String? = nil,
        tmux: String? = nil,
        canReply: Bool? = nil,
        optional: Bool? = nil,
        customAvatarURL: String? = nil
    ) {
        self.id = id
        self.displayName = displayName
        self.kind = kind
        self.avatar = avatar
        self.color = color
        self.model = model
        self.tmux = tmux
        self.canReply = canReply
        self.optional = optional
        self.customAvatarURL = customAvatarURL
    }

    var title: String {
        if id == "sonnet", displayName.lowercased() == "sonnet" {
            return "小豹"
        }
        return displayName
    }

    var avatarText: String {
        if let avatar, !avatar.isEmpty { return avatar }
        return String(title.prefix(1))
    }

    func withCustomAvatarURL(_ path: String?) -> GroupMember {
        GroupMember(
            id: id,
            displayName: displayName,
            kind: kind,
            avatar: avatar,
            color: color,
            model: model,
            tmux: tmux,
            canReply: canReply,
            optional: optional,
            customAvatarURL: path
        )
    }

    var avatarColor: Color {
        switch color {
        case "orange": return Color(red: 0.92, green: 0.45, blue: 0.20)
        case "blue": return Color(red: 0.25, green: 0.48, blue: 0.95)
        case "green": return Color(red: 0.20, green: 0.62, blue: 0.38)
        case "purple": return Color(red: 0.52, green: 0.38, blue: 0.86)
        case "slate": return Color(red: 0.38, green: 0.44, blue: 0.52)
        default: return Color(red: 0.92, green: 0.45, blue: 0.20)
        }
    }

    static let defaults: [GroupMember] = [
        GroupMember(id: "amian", displayName: "阿眠", kind: "human", avatar: "眠", color: "neutral", model: nil, tmux: nil, canReply: false, optional: nil),
        GroupMember(id: "opia", displayName: "Opia", kind: "agent", avatar: "O", color: "orange", model: "Claude Opus 4.7 1m", tmux: "opia", canReply: true, optional: nil),
        GroupMember(id: "sonnet", displayName: "小豹", kind: "agent", avatar: "S", color: "blue", model: "Claude Sonnet 4.6", tmux: "bao", canReply: true, optional: nil),
        GroupMember(id: "shu", displayName: "枢", kind: "agent", avatar: "枢", color: "green", model: "Codex GPT-5.5", tmux: "shu", canReply: true, optional: nil),
        GroupMember(id: "opus47_fresh", displayName: "Opus47-fresh", kind: "agent", avatar: "F", color: "purple", model: "Claude Opus 4.7 fresh", tmux: "opus47-fresh", canReply: true, optional: true),
        GroupMember(id: "fresh", displayName: "fresh", kind: "agent", avatar: "F", color: "purple", model: "Claude Opus 4.7 fresh", tmux: "opus47-fresh", canReply: true, optional: true),
        GroupMember(id: "di", displayName: "砥", kind: "agent", avatar: "砥", color: "slate", model: "Claude Opus 4.7", tmux: "砥", canReply: true, optional: nil),
    ]

    static var defaultMap: [String: GroupMember] {
        Dictionary(uniqueKeysWithValues: defaults.map { ($0.id, $0) })
    }
}

nonisolated struct GroupAgentStatus: Codable, Hashable, Sendable {
    let state: String?
    let tmux: String?
    let lastSeen: String?
    let isTyping: Bool?
    let typingSince: String?
    let dispatchId: String?
    let statusText: String?

    enum CodingKeys: String, CodingKey {
        case state, tmux
        case lastSeen = "last_seen"
        case isTyping = "is_typing"
        case typingSince = "typing_since"
        case dispatchId = "dispatch_id"
        case statusText = "status_text"
    }
}

nonisolated struct GroupStatusSnapshot: Codable, Hashable, Sendable {
    let agents: [String: GroupAgentStatus]
}

extension Notification.Name {
    static let ccGroupAppearanceDidChange = Notification.Name("CcGroupAppearanceDidChange")
}

enum GroupAvatarStore {
    static let pathsKey = "group_member_avatar_paths"
    static let revisionKey = "group_avatar_revision"

    static func avatarPath(for memberId: String) -> String? {
        avatarPaths()[memberId]
    }

    static func avatarPaths() -> [String: String] {
        guard let data = UserDefaults.standard.data(forKey: pathsKey),
              let decoded = try? JSONDecoder().decode([String: String].self, from: data) else {
            return [:]
        }
        return decoded
    }

    static func setAvatarPath(_ path: String, for memberId: String) {
        var paths = avatarPaths()
        paths[memberId] = path
        persist(paths)
        bumpRevision()
    }

    static func removeAvatar(for memberId: String) {
        if let path = avatarPath(for: memberId) {
            try? FileManager.default.removeItem(atPath: path)
        }
        var paths = avatarPaths()
        paths.removeValue(forKey: memberId)
        persist(paths)
        bumpRevision()
    }

    static func filename(for memberId: String) -> String {
        let clean = memberId.map { ch -> Character in
            ch.isLetter || ch.isNumber || ch == "_" || ch == "-" ? ch : "_"
        }
        return "groupAvatar_\(String(clean)).png"
    }

    private static func persist(_ paths: [String: String]) {
        guard let data = try? JSONEncoder().encode(paths) else { return }
        UserDefaults.standard.set(data, forKey: pathsKey)
    }

    private static func bumpRevision() {
        let next = UserDefaults.standard.integer(forKey: revisionKey) + 1
        UserDefaults.standard.set(next, forKey: revisionKey)
        NotificationCenter.default.post(name: .ccGroupAppearanceDidChange, object: nil)
    }
}

struct GroupAvatarView: View {
    let member: GroupMember
    let size: CGFloat

    @AppStorage(GroupAvatarStore.revisionKey) private var avatarRevision: Int = 0

    private var avatarPath: String? {
        member.customAvatarURL ?? GroupAvatarStore.avatarPath(for: member.id)
    }

    var body: some View {
        ZStack {
            if let avatarPath, !avatarPath.isEmpty,
               let image = UIImage(contentsOfFile: avatarPath) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Circle().fill(member.avatarColor)
                Text(member.avatarText)
                    .font(.ccSerifAdaptive(size: max(11, size * 0.42), weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .id("\(member.id)-\(avatarRevision)-\(avatarPath ?? "")")
    }
}
