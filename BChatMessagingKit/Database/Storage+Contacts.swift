
extension Storage {
    
    private static let contactCollection = "LokiContactCollection"
    private static let contactCollection2 = "BeldexContactCollection"

    @objc(getContactWithBChatID:)
    public func getContact(with bchatID: String) -> Contact? {
        var result: Contact?
        Storage.read { transaction in
            result = self.getContact(with: bchatID, using: transaction)
        }
        return result
    }
    
    @objc(getContactWithBChatID:using:)
    public func getContact(with bchatID: String, using transaction: Any) -> Contact? {
        var result: Contact?
        var result2: Contact?
        let transaction = transaction as! YapDatabaseReadTransaction
        result = transaction.object(forKey: bchatID, inCollection: Storage.contactCollection) as? Contact
        result2 = transaction.object(forKey: bchatID, inCollection: Storage.contactCollection2) as? Contact
        if let result = result, result.bchatID == getUserHexEncodedPublicKey() {
            result.isTrusted = true // Always trust ourselves
        }
        if let result2 = result2, result2.bchatID == getUserHexEncodedPublicKey() {
            result2.isTrusted = true // Always trust ourselves
        }
        return result
    }
    
    @objc(setContact:usingTransaction:)
    public func setContact(_ contact: Contact, using transaction: Any) {
        let transaction = transaction as! YapDatabaseReadWriteTransaction
        let oldContact = getContact(with: contact.bchatID, using: transaction)
        if contact.bchatID == getUserHexEncodedPublicKey() {
            contact.isTrusted = true // Always trust ourselves
        }
        transaction.setObject(contact, forKey: contact.bchatID, inCollection: Storage.contactCollection)
        transaction.addCompletionQueue(DispatchQueue.main) {
            // Delete old profile picture if needed
            if let oldProfilePictureFileName = oldContact?.profilePictureFileName,
                oldProfilePictureFileName != contact.profilePictureFileName {
                let path = OWSUserProfile.profileAvatarFilepath(withFilename: oldProfilePictureFileName)
                DispatchQueue.global(qos: .default).async {
                    OWSFileSystem.deleteFileIfExists(path)
                }
            }
            // Post notification
            let notificationCenter = NotificationCenter.default
            notificationCenter.post(name: .contactUpdated, object: contact.bchatID)
            
            if contact.bchatID == getUserHexEncodedPublicKey() {
                notificationCenter.post(name: Notification.Name(kNSNotificationName_LocalProfileDidChange), object: nil)
            }
            else {
                let userInfo = [ kNSNotificationKey_ProfileRecipientId : contact.bchatID ]
                notificationCenter.post(name: Notification.Name(kNSNotificationName_OtherUsersProfileDidChange), object: nil, userInfo: userInfo)
            }
            
            if contact.isBlocked != oldContact?.isBlocked {
                notificationCenter.post(name: .contactBlockedStateChanged, object: contact.bchatID)
            }
        }
    }
    
    @objc public func getAllContacts() -> Set<Contact> {
        var result: Set<Contact> = []
        Storage.read { transaction in
            result = self.getAllContacts(with: transaction)
        }
        return result
    }
    
    @objc public func getAllContacts(with transaction: YapDatabaseReadTransaction) -> Set<Contact> {
        var result: Set<Contact> = []
        transaction.enumerateRows(inCollection: Storage.contactCollection) { _, object, _, _ in
            guard let contact = object as? Contact else { return }
            result.insert(contact)
        }
        return result
    }
}
