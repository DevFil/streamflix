# StreamFlix iOS Examples

This directory contains example code demonstrating how to use the iOS utilities translated from the Android StreamFlix project.

## Files

### BasicUsageExample.swift

Comprehensive examples showing how to use each utility:

- **CryptoAES**: AES decryption examples
- **CookieManager**: Cookie storage and retrieval
- **StringConverter**: Network response conversion
- **VoiceRecognitionHelper**: Voice search implementation

## Usage

These examples are for reference and education purposes. They show the proper way to:

1. Initialize each utility
2. Handle errors and edge cases
3. Integrate utilities into view controllers
4. Combine utilities for complex workflows

## Integration Patterns

### Pattern 1: Simple Utility Usage

```swift
// Direct usage for simple tasks
let decrypted = CryptoAES.decrypt(encryptedData: data, key: key)
```

### Pattern 2: View Controller Integration

```swift
class MyViewController: UIViewController {
    var voiceHelper: VoiceRecognitionHelper?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVoiceRecognition()
    }
    
    func setupVoiceRecognition() {
        voiceHelper = VoiceRecognitionHelper(
            onResult: { text in /* handle result */ },
            onError: { error in /* handle error */ },
            onListeningStateChanged: { isListening in /* update UI */ }
        )
    }
}
```

### Pattern 3: Service Layer Integration

```swift
class NetworkService {
    private let cookieManager = CookieManager.shared
    
    func makeRequest(url: URL) {
        let cookies = cookieManager.loadForRequest(url: url)
        // Use cookies in request
    }
}
```

## Running Examples

To run these examples in your project:

1. Copy the utility files to your project
2. Copy the example file
3. Import necessary frameworks
4. Call the example functions from your app delegate or view controller

```swift
// In your view controller or app delegate
runExamples()
```

## Notes

- Examples are conceptual and may need adaptation for your specific use case
- Ensure all required frameworks are linked (CommonCrypto, Speech, AVFoundation)
- Add necessary Info.plist permissions before using VoiceRecognitionHelper
- Handle errors appropriately in production code

## See Also

- [Main README](../README.md) - Complete API documentation
- [Setup Guide](../SETUP.md) - Integration instructions
- [Android Source](../../app/src/main/java/com/streamflixreborn/streamflix/utils/) - Original implementation
