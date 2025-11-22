//
//  KeychainManager.swift
//  BananaClicker
//
//  Created by Claude on 2025-11-22.
//

import Foundation
import Security
import OSLog

/// Manages secure storage of authentication tokens in Keychain
actor KeychainManager {
    static let shared = KeychainManager()

    private let logger = Logger(subsystem: "com.yourcompany.bananaclicker", category: "Keychain")
    private let serviceName = "com.yourcompany.bananaclicker"
    private let tokenKey = "auth_token"
    private let userIdKey = "user_id"

    private init() {}

    /// Save authentication token
    func saveToken(_ token: String) async {
        await save(token, forKey: tokenKey)
        logger.info("Token saved to keychain")
    }

    /// Retrieve authentication token
    func getToken() async -> String? {
        let token = await get(forKey: tokenKey)
        if token != nil {
            logger.info("Token retrieved from keychain")
        }
        return token
    }

    /// Delete authentication token
    func deleteToken() async {
        await delete(forKey: tokenKey)
        logger.info("Token deleted from keychain")
    }

    /// Save user ID
    func saveUserId(_ userId: String) async {
        await save(userId, forKey: userIdKey)
        logger.info("User ID saved to keychain")
    }

    /// Retrieve user ID
    func getUserId() async -> String? {
        return await get(forKey: userIdKey)
    }

    /// Delete user ID
    func deleteUserId() async {
        await delete(forKey: userIdKey)
        logger.info("User ID deleted from keychain")
    }

    /// Clear all keychain data
    func clearAll() async {
        await deleteToken()
        await deleteUserId()
        logger.info("All keychain data cleared")
    }

    // MARK: - Private Methods

    private func save(_ value: String, forKey key: String) async {
        guard let data = value.data(using: .utf8) else {
            logger.error("Failed to encode value for key: \(key)")
            return
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        // Delete existing item
        SecItemDelete(query as CFDictionary)

        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)

        if status != errSecSuccess {
            logger.error("Failed to save to keychain: \(status)")
        }
    }

    private func get(forKey key: String) async -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            if status != errSecItemNotFound {
                logger.error("Failed to retrieve from keychain: \(status)")
            }
            return nil
        }

        return value
    }

    private func delete(forKey key: String) async {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)

        if status != errSecSuccess && status != errSecItemNotFound {
            logger.error("Failed to delete from keychain: \(status)")
        }
    }
}
