import Foundation
import Security

class KeychainManager {
    static let shared = KeychainManager()
    
    private let service = "com.gaulatti.cirrus"
    private let authTokenKey = "authToken"
    private let refreshTokenKey = "refreshToken"
    
    @discardableResult
    func saveAuthTokens(authToken: String, refreshToken: String?) -> Bool {
        guard let authData = authToken.data(using: .utf8) else {
            return false
        }
        // Delete existing tokens first
        let authQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: authTokenKey
        ]
        SecItemDelete(authQuery as CFDictionary)
        
        let refreshQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: refreshTokenKey
        ]
        SecItemDelete(refreshQuery as CFDictionary)
        
        // Add auth token
        let authAttributes: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: authTokenKey,
            kSecValueData as String: authData
        ]
        let authStatus = SecItemAdd(authAttributes as CFDictionary, nil)
        
        // Add refresh token if available
        if let refreshToken = refreshToken, let refreshData = refreshToken.data(using: .utf8) {
            let refreshAttributes: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: refreshTokenKey,
                kSecValueData as String: refreshData
            ]
            let _ = SecItemAdd(refreshAttributes as CFDictionary, nil)
        }
        
        return authStatus == errSecSuccess
    }
    
    func retrieveAuthToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: authTokenKey,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        guard status == errSecSuccess,
              let tokenData = dataTypeRef as? Data,
              let token = String(data: tokenData, encoding: .utf8)
        else {
            return nil
        }
        return token
    }
    
    func retrieveRefreshToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: refreshTokenKey,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        guard status == errSecSuccess,
              let tokenData = dataTypeRef as? Data,
              let token = String(data: tokenData, encoding: .utf8)
        else {
            return nil
        }
        return token
    }
    
    func deleteTokens() {
        let authQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: authTokenKey
        ]
        SecItemDelete(authQuery as CFDictionary)
        
        let refreshQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: refreshTokenKey
        ]
        SecItemDelete(refreshQuery as CFDictionary)
    }
}
