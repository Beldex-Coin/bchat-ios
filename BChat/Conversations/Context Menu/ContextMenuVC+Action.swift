
extension ContextMenuVC {

    struct Action {
        let icon: UIImage
        let title: String
        let work: () -> Void

        static func reply(_ viewItem: ConversationViewItem, _ delegate: ContextMenuActionDelegate?) -> Action {
            let title = NSLocalizedString("context_menu_reply", comment: "")
            return Action(icon: UIImage(named: "reply")!, title: title) { delegate?.reply(viewItem) }
        }

        static func copy(_ viewItem: ConversationViewItem, _ delegate: ContextMenuActionDelegate?) -> Action {
            let title = NSLocalizedString("copy", comment: "")
            return Action(icon: UIImage(named: "copy 1")!, title: title) { delegate?.copy(viewItem) }
        }

        static func copyBChatID(_ viewItem: ConversationViewItem, _ delegate: ContextMenuActionDelegate?) -> Action {
            let title = NSLocalizedString("vc_conversation_settings_copy_bchat_id_button_title", comment: "")
            return Action(icon: UIImage(named: "copy 1")!, title: title) { delegate?.copyBChatID(viewItem) }
        }

        static func delete(_ viewItem: ConversationViewItem, _ delegate: ContextMenuActionDelegate?) -> Action {
            let title = NSLocalizedString("Delete", comment: "")
            return Action(icon: UIImage(named: "delete")!, title: title) { delegate?.delete(viewItem) }
        }
        
        static func report(_ viewItem: ConversationViewItem, _ delegate: ContextMenuActionDelegate?) -> Action {
              let title = NSLocalizedString("Report", comment: "")
              return Action(icon: UIImage(named: "about987")!, title: title) { delegate?.report(viewItem) }
            }

        static func save(_ viewItem: ConversationViewItem, _ delegate: ContextMenuActionDelegate?) -> Action {
            let title = NSLocalizedString("context_menu_save", comment: "")
            return Action(icon: UIImage(named: "ic_download")!, title: title) { delegate?.save(viewItem) }
        }

        static func ban(_ viewItem: ConversationViewItem, _ delegate: ContextMenuActionDelegate?) -> Action {
            let title = NSLocalizedString("context_menu_ban_user", comment: "")
            return Action(icon: UIImage(named: "ic_block")!, title: title) { delegate?.ban(viewItem) }
        }
        
        static func banAndDeleteAllMessages(_ viewItem: ConversationViewItem, _ delegate: ContextMenuActionDelegate?) -> Action {
            let title = NSLocalizedString("context_menu_ban_and_delete_all", comment: "")
            return Action(icon: UIImage(named: "ic_block")!, title: title) { delegate?.banAndDeleteAllMessages(viewItem) }
        }
        
        static func messageDetail(_ viewItem: ConversationViewItem, _ delegate: ContextMenuActionDelegate?) -> Action {
            let title = NSLocalizedString("context_menu_message_detail", comment: "")
            return Action(icon: UIImage(named: "ic_message_detail")!, title: title) { delegate?.messageDetail(viewItem) }
        }
        
    }

    static func actions(for viewItem: ConversationViewItem, delegate: ContextMenuActionDelegate?) -> [Action] {
        func isReplyingAllowed() -> Bool {
            guard let message = viewItem.interaction as? TSOutgoingMessage else { return true }
            switch message.messageState {
            case .failed, .sending: return false
            default: return true
            }
        }
        switch viewItem.messageCellType {
        case .textOnlyMessage:
            var result: [Action] = []
          //  if isReplyingAllowed() { result.append(Action.reply(viewItem, delegate)) }
            if isReplyingAllowed() {
                // Payment Card View and openGroupInvitation Both "Replay" Option is disabled
                if let payment = viewItem.interaction as? TSIncomingMessage, let txnid = payment.paymentTxnid {
                    if txnid.isEmpty { }
                } else if let payment = viewItem.interaction as? TSOutgoingMessage, let txnid = payment.paymentTxnid {
                    if txnid.isEmpty { }
                } else if let payment = viewItem.interaction as? TSOutgoingMessage, let openGroupInvitationURL = payment.openGroupInvitationURL {
                    if openGroupInvitationURL.isEmpty { }
                } else if let payment = viewItem.interaction as? TSIncomingMessage, let openGroupInvitationURL = payment.openGroupInvitationURL {
                    if openGroupInvitationURL.isEmpty { }
                } else {
                    result.append(Action.reply(viewItem, delegate))
                }
            }
            // Copy Code
            result.append(Action.copy(viewItem, delegate))
            
            // Message Detail For OutgoingMessage
            if viewItem.interaction is TSOutgoingMessage {
                result.append(Action.messageDetail(viewItem, delegate))
            }
            
            let isGroup = viewItem.isGroupThread
            if let message = viewItem.interaction as? TSIncomingMessage, isGroup, message.isOpenGroupMessage {
                result.append(Action.report(viewItem, delegate))
            }
            if let message = viewItem.interaction as? TSIncomingMessage, isGroup, !message.isOpenGroupMessage {
                result.append(Action.copyBChatID(viewItem, delegate))
            }
            if !isGroup || viewItem.userCanDeleteGroupMessage { result.append(Action.delete(viewItem, delegate)) }
            if isGroup && viewItem.interaction is TSIncomingMessage && viewItem.userHasModerationPermission {
                result.append(Action.ban(viewItem, delegate))
                result.append(Action.banAndDeleteAllMessages(viewItem, delegate))
            }
            return result
        case .mediaMessage, .audio, .genericAttachment:
            var result: [Action] = []
            if isReplyingAllowed() { result.append(Action.reply(viewItem, delegate)) }
            if viewItem.canCopyMedia() { result.append(Action.copy(viewItem, delegate)) }
            if viewItem.canSaveMedia() { result.append(Action.save(viewItem, delegate)) }
            
            // Message Detail For OutgoingMessage
            if viewItem.interaction is TSOutgoingMessage {
                result.append(Action.messageDetail(viewItem, delegate))
            }
            
            let isGroup = viewItem.isGroupThread
            if let message = viewItem.interaction as? TSIncomingMessage, isGroup, !message.isOpenGroupMessage {
                result.append(Action.copyBChatID(viewItem, delegate))
            }
            if !isGroup || viewItem.userCanDeleteGroupMessage { result.append(Action.delete(viewItem, delegate)) }
            if isGroup && viewItem.interaction is TSIncomingMessage && viewItem.userHasModerationPermission {
                result.append(Action.ban(viewItem, delegate))
                result.append(Action.banAndDeleteAllMessages(viewItem, delegate))
            }
            return result
        default: return []
        }
    }
}

// MARK: Delegate
protocol ContextMenuActionDelegate : AnyObject {
    
    func reply(_ viewItem: ConversationViewItem)
    func copy(_ viewItem: ConversationViewItem)
    func copyBChatID(_ viewItem: ConversationViewItem)
    func delete(_ viewItem: ConversationViewItem)
    func report(_ viewItem: ConversationViewItem)
    func save(_ viewItem: ConversationViewItem)
    func ban(_ viewItem: ConversationViewItem)
    func banAndDeleteAllMessages(_ viewItem: ConversationViewItem)
    func contextMenuDismissed()
    func messageDetail(_ viewItem: ConversationViewItem)
    func showFullEmojiKeyboard(_ viewItem: ConversationViewItem)
}
