import Foundation

/// Cookie management for HTTP requests
/// Translated from Android's MyCookieJar.kt
class CookieManager {
    
    // Shared instance for cookie management
    static let shared = CookieManager()
    
    // Cookie storage keyed by host
    private var cookieStore: [String: [HTTPCookie]] = [:]
    
    private init() {}
    
    /// Saves cookies from an HTTP response
    /// - Parameters:
    ///   - url: The URL of the request
    ///   - cookies: Array of cookies to save
    func saveFromResponse(url: URL, cookies: [HTTPCookie]) {
        guard let host = url.host else { return }
        cookieStore[host] = cookies
    }
    
    /// Loads cookies for an HTTP request
    /// - Parameter url: The URL for which to load cookies
    /// - Returns: Array of cookies for the given URL
    func loadForRequest(url: URL) -> [HTTPCookie] {
        guard let host = url.host else { return [] }
        return cookieStore[host] ?? []
    }
    
    /// Clears all stored cookies
    func clearAllCookies() {
        cookieStore.removeAll()
    }
    
    /// Clears cookies for a specific host
    /// - Parameter host: The host for which to clear cookies
    func clearCookies(forHost host: String) {
        cookieStore.removeValue(forKey: host)
    }
    
    /// Gets all stored cookies for a specific host
    /// - Parameter host: The host to query
    /// - Returns: Array of cookies for the host, or empty array if none
    func getCookies(forHost host: String) -> [HTTPCookie] {
        return cookieStore[host] ?? []
    }
}

// MARK: - URLSessionConfiguration Extension
extension URLSessionConfiguration {
    
    /// Configures the session to use the custom cookie manager
    func useCookieManager() {
        self.httpCookieStorage = nil
        self.httpShouldSetCookies = false
    }
}
