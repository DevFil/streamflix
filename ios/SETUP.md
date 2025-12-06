# StreamFlix iOS Setup Guide

This guide will help you set up and integrate the iOS utilities translated from the Android StreamFlix project.

## Quick Start

### Option 1: Swift Package Manager (Recommended)

1. Open your Xcode project
2. Go to **File → Add Packages...**
3. Enter the repository URL: `https://github.com/streamflix-reborn/streamflix.git`
4. Select the iOS utilities package
5. Click **Add Package**

### Option 2: Manual Integration

1. Copy the `ios/StreamFlix/Utils` folder to your project
2. In Xcode, right-click your project and select **Add Files to "YourProject"...**
3. Select the Utils folder and check **Copy items if needed**
4. Ensure the files are added to your target

## Project Configuration

### 1. Update Info.plist

Add the required permission descriptions to your `Info.plist`:

```xml
<key>NSSpeechRecognitionUsageDescription</key>
<string>StreamFlix needs speech recognition to enable voice search</string>

<key>NSMicrophoneUsageDescription</key>
<string>StreamFlix needs microphone access for voice search</string>
```

Or in Xcode:
1. Select your project's Info.plist
2. Click the **+** button
3. Add **Privacy - Speech Recognition Usage Description**
4. Add **Privacy - Microphone Usage Description**

### 2. Link Required Frameworks

The utilities require the following frameworks (most are included by default):

- **Foundation** (included)
- **CommonCrypto** (for CryptoAES)
- **Speech** (for VoiceRecognitionHelper)
- **AVFoundation** (for VoiceRecognitionHelper)

To add frameworks:
1. Select your project target
2. Go to **Build Phases → Link Binary With Libraries**
3. Click **+** and add the required frameworks

### 3. Bridging Header (if using Objective-C)

If your project uses Objective-C, create a bridging header:

1. Create a new file: **YourProject-Bridging-Header.h**
2. Add: `#import <CommonCrypto/CommonCrypto.h>`
3. In Build Settings, set **Objective-C Bridging Header** to the file path

## Usage Examples

### Using CryptoAES

```swift
import Foundation

// Decrypt AES-encrypted data
let encryptedBase64 = "your_encrypted_data_here"
let key = "your_secret_key"

let decrypted = CryptoAES.decrypt(encryptedData: encryptedBase64, key: key)
print("Decrypted: \(decrypted)")
```

### Using VoiceRecognitionHelper

```swift
import UIKit

class SearchViewController: UIViewController {
    var voiceHelper: VoiceRecognitionHelper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        voiceHelper = VoiceRecognitionHelper(
            onResult: { [weak self] text in
                // Handle recognized text
                self?.performSearch(with: text)
            },
            onError: { [weak self] error in
                // Handle error
                self?.showError(error)
            },
            onListeningStateChanged: { [weak self] isListening in
                // Update UI based on listening state
                self?.updateMicrophoneButton(isListening: isListening)
            }
        )
    }
    
    @IBAction func microphoneButtonTapped(_ sender: UIButton) {
        if voiceHelper.isAvailable() {
            voiceHelper.startWithPermissionCheck()
        } else {
            showError("Voice recognition is not available")
        }
    }
    
    func performSearch(with query: String) {
        print("Searching for: \(query)")
        // Implement your search logic
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func updateMicrophoneButton(isListening: Bool) {
        // Update button appearance based on listening state
        // e.g., change color, add animation, etc.
    }
}
```

### Using CookieManager

```swift
import Foundation

// Configure URLSession with custom cookie handling
let config = URLSessionConfiguration.default
config.useCookieManager()
let session = URLSession(configuration: config)

// Save cookies after a response
let url = URL(string: "https://example.com")!
let cookies = [/* your HTTPCookie objects */]
CookieManager.shared.saveFromResponse(url: url, cookies: cookies)

// Load cookies for a request
var request = URLRequest(url: url)
let savedCookies = CookieManager.shared.loadForRequest(url: url)

// Add cookies to request
let cookieHeader = HTTPCookie.requestHeaderFields(with: savedCookies)
cookieHeader.forEach { key, value in
    request.setValue(value, forHTTPHeaderField: key)
}
```

### Using StringConverter

```swift
import Foundation

// Method 1: Using URLSession extension (async/await)
Task {
    do {
        let url = URL(string: "https://api.example.com/data")!
        let response = try await URLSession.shared.stringData(from: url)
        print("Response: \(response)")
    } catch {
        print("Error: \(error)")
    }
}

// Method 2: Using URLSession extension (callback)
let url = URL(string: "https://api.example.com/data")!
URLSession.shared.stringDataTask(with: url) { result in
    switch result {
    case .success(let string):
        print("Response: \(string)")
    case .failure(let error):
        print("Error: \(error)")
    }
}

// Method 3: Using converter directly
let data = "Response data".data(using: .utf8)!
let converter = StringConverter()
do {
    let string = try converter.convert(data: data)
    print("Converted: \(string)")
} catch {
    print("Conversion error: \(error)")
}
```

## Testing

### Unit Tests

Create unit tests for each utility:

```swift
import XCTest
@testable import YourApp

class CryptoAESTests: XCTestCase {
    
    func testDecryption() {
        // Prepare test data
        let key = "test-key-16bytes!"
        let plaintext = "Hello, World!"
        
        // Test encryption/decryption cycle
        // (You'll need to implement encryption or use known encrypted values)
        
        // Test invalid input handling
        let result = CryptoAES.decrypt(encryptedData: "invalid", key: key)
        XCTAssertEqual(result, "")
    }
}

class StringConverterTests: XCTestCase {
    
    func testConversion() throws {
        let testString = "Hello, World!"
        let data = testString.data(using: .utf8)!
        
        let converter = StringConverter()
        let result = try converter.convert(data: data)
        
        XCTAssertEqual(result, testString)
    }
}
```

### UI Tests

For VoiceRecognitionHelper, you can create UI tests to verify permission handling:

```swift
import XCTest

class VoiceRecognitionUITests: XCTestCase {
    
    func testVoicePermissionFlow() {
        let app = XCUIApplication()
        app.launch()
        
        // Tap microphone button
        app.buttons["microphoneButton"].tap()
        
        // Handle permission alert if it appears
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        if springboard.alerts.element.exists {
            springboard.alerts.buttons["Allow"].tap()
        }
    }
}
```

## Build Configuration

### Debug vs Release

Configure different settings for debug and release builds:

```swift
#if DEBUG
let apiBaseURL = "https://dev-api.example.com"
#else
let apiBaseURL = "https://api.example.com"
#endif
```

### Deployment Target

Set the minimum iOS version in your project settings:
- **Minimum iOS Version**: 13.0 or higher

### Swift Version

Ensure you're using Swift 5.0 or later:
- In Build Settings, set **Swift Language Version** to Swift 5

## Common Issues and Solutions

### Issue: CommonCrypto not found

**Solution**: 
1. Add a module map for CommonCrypto
2. Create a `module.modulemap` file:
```
module CommonCrypto {
    header "/usr/include/CommonCrypto/CommonCrypto.h"
    export *
}
```
3. Add the module map path to Build Settings → Import Paths

### Issue: Speech recognition permission denied

**Solution**: 
1. Verify Info.plist has the required keys
2. Check device Settings → Privacy → Speech Recognition
3. Ensure your app is listed and enabled

### Issue: Async/await not available

**Solution**: 
- Ensure deployment target is iOS 13.0+ and Xcode 13.0+
- For older versions, use the callback-based APIs instead

## Next Steps

1. **Integrate with Network Layer**: Use StringConverter with your networking code
2. **Implement Voice Search**: Add VoiceRecognitionHelper to search screens
3. **Secure Storage**: Use CryptoAES for encrypting sensitive data
4. **Cookie Management**: Implement CookieManager for custom cookie handling

## Additional Resources

- [Apple Documentation - Speech Framework](https://developer.apple.com/documentation/speech)
- [Apple Documentation - CommonCrypto](https://developer.apple.com/library/archive/documentation/Security/Conceptual/cryptoservices/)
- [Swift Package Manager](https://swift.org/package-manager/)

## Support

For issues or questions:
1. Check the main [README](README.md) for detailed API documentation
2. Review the original Android code for behavior reference
3. Open an issue on GitHub

## License

Apache-2.0 - See [LICENSE](../LICENSE) for details
