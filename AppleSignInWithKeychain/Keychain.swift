//
//  Keychain.swift
//  AppleSignInWithKeychain
//
//  Created by Will Chen on 2019/10/5.
//  Copyright © 2019 rukurouc. All rights reserved.
//

import Foundation

// MARK: Custom keychain error

fileprivate enum KeychainError: Error {
    case encodePasswordFailed
    case noPassword
    case unexpectedPasswordData
    case deleteItemFailde
    case unhandledError(status: OSStatus)
}

// MARK: Keychain

struct Keychain {
    enum Constant: String{
        case currentUserIdentifier = "currentUserIdentifier"
    }
    
    // MARK: Utility static methods
    
    static var currentUserIdentifier: String {
        guard let bundleId = Bundle.main.bundleIdentifier  else { return "" }
        do {
            let storedIdentifier = try KeychainItem(service: bundleId, account: Constant.currentUserIdentifier.rawValue).readItem()
            return storedIdentifier
        } catch {
            //Get current user identifier failed
            return ""
        }
    }
    
    static func setCurrentUserIdentifier(_ indentifier: String) {
        guard let bundleId = Bundle.main.bundleIdentifier  else { return }
        do {
            try KeychainItem(service: bundleId, account: Constant.currentUserIdentifier.rawValue).saveItem(indentifier)
        } catch let error {
            //Set user identifier failed.
            print(error.localizedDescription)
        }
    }
    
    static func deleteCurrentUserIdentifier() {
        guard let bundleId = Bundle.main.bundleIdentifier  else { return }
        do {
            try KeychainItem(service: bundleId, account: Constant.currentUserIdentifier.rawValue).deleteItem()
        } catch let error {
            //Delete user identifier failed.
            print(error.localizedDescription)
        }
        
    }
}

// MARK: KeychainItem

private struct KeychainItem {
    
    // MARK: Properties
    
    private let service: String
    private let account: String
    
    // MARK: Intialization
    
    init(service: String, account: String) {
        self.service = service
        self.account = account
    }
    
    // MARK: CRUD
    
    func readItem() throws -> String {
        var query = KeychainItem.keychainQuery(withService: service, account: account)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
        guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
        guard
            let existingItem = item as? [String: AnyObject],
            let passwordData = existingItem[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: String.Encoding.utf8)
            else {
                throw KeychainError.unexpectedPasswordData
        }
        return password
    }
    
    func saveItem(_ password: String) throws {
        // Encode the password into an Data object.
        if let encodedPassword = password.data(using: String.Encoding.utf8) {
            do {
                // Check for an existing item in the keychain.
                try _ = readItem()
                // Update the existing item with the new password.
                var attributesToUpdate = [String: AnyObject]()
                attributesToUpdate[kSecValueData as String] = encodedPassword as AnyObject?
                let query = KeychainItem.keychainQuery(withService: service, account: account)
                let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
                // Throw an error if an unexpected status was returned.
                guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
            } catch KeychainError.noPassword {
                /*
                No password was found in the keychain. Create a dictionary to save
                as a new keychain item.
                */
                var newItem = KeychainItem.keychainQuery(withService: service, account: account)
                newItem[kSecValueData as String] = encodedPassword as AnyObject?
                
                // Add a the new item to the keychain.
                let status = SecItemAdd(newItem as CFDictionary, nil)
                
                // Throw an error if an unexpected status was returned.
                guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
            }
        }else {
            throw KeychainError.encodePasswordFailed
        }
    }
    
    func deleteItem() throws {
        // Delete the existing item from the keychain.
        let query = KeychainItem.keychainQuery(withService: service, account: account)
        let status = SecItemDelete(query as CFDictionary)
        // Throw an error if an unexpected status was returned.
        guard status == errSecSuccess || status == errSecItemNotFound else { throw KeychainError.unhandledError(status: status) }
    }
    
    // MARK: Keychain item getter
    
    private static func keychainQuery(withService service: String, account: String? = nil) -> [String: AnyObject] {
        var query = [String: AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = service as AnyObject?
        query[kSecAttrAccount as String] = account as AnyObject?
        return query
    }
}
