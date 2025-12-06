import Foundation

// Note: This is a demonstration file showing how to use the translated utilities.
// This file is not meant to be compiled directly but serves as a reference.

/// Example: Using CryptoAES for decryption
func exampleCryptoAES() {
    print("=== CryptoAES Example ===")
    
    // Example encrypted data (Base64 encoded)
    let encryptedData = "your_base64_encrypted_data_here"
    let key = "your-secret-key-16bytes"
    
    let decrypted = CryptoAES.decrypt(encryptedData: encryptedData, key: key)
    
    if !decrypted.isEmpty {
        print("Decryption successful: \(decrypted)")
    } else {
        print("Decryption failed")
    }
}

/// Example: Using CookieManager
func exampleCookieManager() {
    print("\n=== CookieManager Example ===")
    
    guard let url = URL(string: "https://example.com") else { return }
    
    // Create a sample cookie
    let cookie = HTTPCookie(properties: [
        .domain: "example.com",
        .path: "/",
        .name: "sessionId",
        .value: "abc123xyz",
        .secure: true,
        HTTPCookiePropertyKey.expires: Date().addingTimeInterval(3600)
    ])
    
    if let cookie = cookie {
        // Save cookie
        CookieManager.shared.saveFromResponse(url: url, cookies: [cookie])
        print("Cookie saved for \(url.host ?? "unknown")")
        
        // Load cookies
        let loadedCookies = CookieManager.shared.loadForRequest(url: url)
        print("Loaded \(loadedCookies.count) cookie(s)")
        
        for cookie in loadedCookies {
            print("  - \(cookie.name): \(cookie.value)")
        }
    }
}

/// Example: Using StringConverter with URLSession
func exampleStringConverter() {
    print("\n=== StringConverter Example ===")
    
    guard let url = URL(string: "https://api.example.com/data") else { return }
    
    // Example 1: Using async/await (iOS 13+)
    Task {
        do {
            let response = try await URLSession.shared.stringData(from: url)
            print("Async response received: \(response.prefix(100))...")
        } catch {
            print("Async request failed: \(error)")
        }
    }
    
    // Example 2: Using completion handler
    URLSession.shared.stringDataTask(with: url) { result in
        switch result {
        case .success(let string):
            print("Response received: \(string.prefix(100))...")
        case .failure(let error):
            print("Request failed: \(error)")
        }
    }
    
    // Example 3: Using converter directly
    let sampleData = "Sample response data".data(using: .utf8)!
    let converter = StringConverter()
    
    do {
        let converted = try converter.convert(data: sampleData)
        print("Direct conversion: \(converted)")
    } catch {
        print("Conversion failed: \(error)")
    }
}

/// Example: Using VoiceRecognitionHelper in a view controller
class ExampleViewController {
    var voiceHelper: VoiceRecognitionHelper?
    
    func setupVoiceRecognition() {
        print("\n=== VoiceRecognitionHelper Example ===")
        
        voiceHelper = VoiceRecognitionHelper(
            onResult: { [weak self] recognizedText in
                print("Voice recognized: \(recognizedText)")
                self?.handleVoiceSearch(query: recognizedText)
            },
            onError: { [weak self] errorMessage in
                print("Voice error: \(errorMessage)")
                self?.showError(message: errorMessage)
            },
            onListeningStateChanged: { [weak self] isListening in
                print("Listening state changed: \(isListening)")
                self?.updateMicrophoneUI(isListening: isListening)
            }
        )
    }
    
    func startVoiceSearch() {
        guard let voiceHelper = voiceHelper else {
            print("VoiceRecognitionHelper not initialized")
            return
        }
        
        if voiceHelper.isAvailable() {
            voiceHelper.startWithPermissionCheck()
            print("Starting voice recognition...")
        } else {
            print("Voice recognition is not available on this device")
        }
    }
    
    func stopVoiceSearch() {
        voiceHelper?.stopRecognition()
        print("Voice recognition stopped")
    }
    
    func handleVoiceSearch(query: String) {
        print("Performing search for: \(query)")
        // Implement your search logic here
    }
    
    func showError(message: String) {
        print("Error: \(message)")
        // Show alert or error UI
    }
    
    func updateMicrophoneUI(isListening: Bool) {
        print("Update UI - Listening: \(isListening)")
        // Update button appearance, show animation, etc.
    }
}

/// Example: Complete search flow with voice and text
class SearchExample {
    let voiceHelper: VoiceRecognitionHelper
    let cookieManager = CookieManager.shared
    
    init() {
        // Initialize voice helper
        self.voiceHelper = VoiceRecognitionHelper(
            onResult: { query in
                print("Voice query: \(query)")
            },
            onError: { error in
                print("Voice error: \(error)")
            },
            onListeningStateChanged: { isListening in
                print("Listening: \(isListening)")
            }
        )
    }
    
    func performSearch(query: String) {
        print("\n=== Complete Search Example ===")
        
        guard let url = URL(string: "https://api.search.example.com/search?q=\(query)") else {
            return
        }
        
        // Create request with cookies
        var request = URLRequest(url: url)
        
        // Load and set cookies
        let cookies = cookieManager.loadForRequest(url: url)
        let cookieHeaders = HTTPCookie.requestHeaderFields(with: cookies)
        cookieHeaders.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Perform search request
        URLSession.shared.stringDataTask(with: request.url!) { result in
            switch result {
            case .success(let response):
                print("Search results: \(response.prefix(100))...")
                // Parse and display results
                
            case .failure(let error):
                print("Search failed: \(error)")
            }
        }
    }
    
    func startVoiceSearch() {
        if voiceHelper.isAvailable() {
            voiceHelper.startWithPermissionCheck()
        } else {
            print("Voice search not available")
        }
    }
}

/// Example: Secure data handling with encryption
class SecureDataExample {
    func saveSecureData(data: String, key: String) {
        print("\n=== Secure Data Example ===")
        
        // In a real app, you would encrypt before saving
        // For decryption example:
        print("Saving encrypted data...")
        // UserDefaults or Keychain storage here
    }
    
    func loadSecureData(encryptedData: String, key: String) -> String? {
        let decrypted = CryptoAES.decrypt(encryptedData: encryptedData, key: key)
        
        if !decrypted.isEmpty {
            print("Data decrypted successfully")
            return decrypted
        } else {
            print("Failed to decrypt data")
            return nil
        }
    }
}

// MARK: - Main execution (for demonstration purposes)

func runExamples() {
    print("StreamFlix iOS Utilities - Usage Examples")
    print("==========================================\n")
    
    // Run examples
    exampleCryptoAES()
    exampleCookieManager()
    exampleStringConverter()
    
    // View controller examples (conceptual)
    let viewController = ExampleViewController()
    viewController.setupVoiceRecognition()
    // viewController.startVoiceSearch() // Uncomment to test
    
    // Search example (conceptual)
    let searchExample = SearchExample()
    searchExample.performSearch(query: "test query")
    
    // Secure data example
    let secureExample = SecureDataExample()
    // let encrypted = "..." // Your encrypted data
    // let key = "your-key"
    // let decrypted = secureExample.loadSecureData(encryptedData: encrypted, key: key)
    
    print("\n==========================================")
    print("Examples completed!")
}

// Note: In a real iOS app, you would call these functions from your
// view controllers, view models, or other appropriate places in your app architecture.
