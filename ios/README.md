# StreamFlix iOS Utilities

This directory contains iOS/Swift translations of the core Android utilities from the StreamFlix project.

## Overview

The utilities have been translated from Kotlin/Java to Swift, maintaining the same functionality while adapting to iOS platform conventions and APIs.

## Translated Utilities

### 1. CryptoAES.swift
**Original**: `app/src/main/java/com/streamflixreborn/streamflix/utils/CryptoAES.kt`

AES encryption/decryption utility that provides AES-CBC with PKCS5/7 padding.

**Usage**:
```swift
let decrypted = CryptoAES.decrypt(encryptedData: base64String, key: "encryption-key")
```

**Features**:
- Base64 decoding of encrypted data
- IV extraction from encrypted data (first 16 bytes)
- AES-CBC decryption with PKCS7 padding
- CommonCrypto framework integration

---

### 2. CookieManager.swift
**Original**: `app/src/main/java/com/streamflixreborn/streamflix/utils/MyCookieJar.kt`

Custom cookie management system for HTTP requests.

**Usage**:
```swift
let cookieManager = CookieManager.shared

// Save cookies from response
cookieManager.saveFromResponse(url: url, cookies: cookies)

// Load cookies for request
let cookies = cookieManager.loadForRequest(url: url)

// Clear all cookies
cookieManager.clearAllCookies()
```

**Features**:
- Per-host cookie storage
- Cookie persistence across requests
- Manual cookie management (bypassing default URLSession cookie handling)
- Singleton pattern for easy access

---

### 3. VoiceRecognitionHelper.swift
**Original**: `app/src/main/java/com/streamflixreborn/streamflix/utils/VoiceRecognitionHelper.kt`

Voice recognition helper for speech-to-text functionality.

**Usage**:
```swift
let voiceHelper = VoiceRecognitionHelper(
    onResult: { recognizedText in
        print("Recognized: \(recognizedText)")
    },
    onError: { errorMessage in
        print("Error: \(errorMessage)")
    },
    onListeningStateChanged: { isListening in
        print("Listening: \(isListening)")
    }
)

// Check availability
if voiceHelper.isAvailable() {
    // Start recognition with permission handling
    voiceHelper.startWithPermissionCheck()
}

// Stop recognition
voiceHelper.stopRecognition()
```

**Features**:
- Automatic permission handling
- Real-time speech recognition using iOS Speech framework
- Language locale support
- Audio session management
- Listening state callbacks

**Required**: Add `NSSpeechRecognitionUsageDescription` and `NSMicrophoneUsageDescription` to Info.plist

---

### 4. StringConverter.swift
**Original**: `app/src/main/java/com/streamflixreborn/streamflix/utils/StringConverter.kt`

Network response converter for transforming HTTP responses to strings.

**Usage**:
```swift
// Using the URLSession extension (callback style)
URLSession.shared.stringDataTask(with: url) { result in
    switch result {
    case .success(let string):
        print("Response: \(string)")
    case .failure(let error):
        print("Error: \(error)")
    }
}

// Using async/await
Task {
    do {
        let response = try await URLSession.shared.stringData(from: url)
        print("Response: \(response)")
    } catch {
        print("Error: \(error)")
    }
}

// Using the converter directly
let converter = StringConverter()
let string = try converter.convert(data: responseData)
```

**Features**:
- UTF-8 string conversion
- URLSession extensions for easy integration
- Both callback and async/await support
- Type-safe conversion protocol

---

## Integration

### Swift Package Manager

You can integrate these utilities using Swift Package Manager by adding the package to your Xcode project or Package.swift:

```swift
dependencies: [
    .package(url: "https://github.com/streamflix-reborn/streamflix.git", from: "1.0.0")
]
```

### Manual Integration

1. Copy the `ios/StreamFlix/Utils` directory to your project
2. Add the files to your Xcode project
3. Ensure your project has the required frameworks:
   - CommonCrypto (for CryptoAES)
   - Speech (for VoiceRecognitionHelper)
   - AVFoundation (for VoiceRecognitionHelper)

### CocoaPods

Create a Podspec for the utilities (optional):

```ruby
Pod::Spec.new do |spec|
  spec.name         = "StreamFlixUtils"
  spec.version      = "1.0.0"
  spec.summary      = "StreamFlix iOS Utilities"
  spec.description  = "Core utilities translated from StreamFlix Android app"
  spec.homepage     = "https://github.com/streamflix-reborn/streamflix"
  spec.license      = "Apache-2.0"
  spec.author       = { "StreamFlix" => "dev@streamflix.com" }
  spec.source       = { :git => "https://github.com/streamflix-reborn/streamflix.git", :tag => "#{spec.version}" }
  spec.ios.deployment_target = "13.0"
  spec.source_files = "ios/StreamFlix/Utils/**/*.swift"
  spec.swift_version = "5.0"
end
```

## Platform Differences

### Android → iOS Translations

| Android API | iOS API |
|------------|---------|
| `android.util.Base64` | `Foundation.Data(base64Encoded:)` |
| `javax.crypto.Cipher` | `CommonCrypto` |
| `android.speech.SpeechRecognizer` | `Speech.SFSpeechRecognizer` |
| `okhttp3.Cookie` | `Foundation.HTTPCookie` |
| `okhttp3.CookieJar` | Custom `CookieManager` |
| `retrofit2.Converter` | Custom `ResponseConverter` protocol |

### Key Adaptations

1. **Error Handling**: Swift uses native error handling with `throw`/`try`/`catch` instead of returning empty strings
2. **Async Operations**: iOS provides both callback and async/await patterns
3. **Permissions**: iOS uses a different permission model requiring Info.plist entries
4. **Singletons**: iOS utilities use static shared instances where appropriate
5. **Memory Management**: Swift uses ARC instead of garbage collection

## Requirements

- **iOS**: 13.0+
- **Swift**: 5.0+
- **Xcode**: 12.0+

## Frameworks

Make sure to link the following frameworks in your project:

- `Foundation.framework` (built-in)
- `CommonCrypto` (for CryptoAES)
- `Speech.framework` (for VoiceRecognitionHelper)
- `AVFoundation.framework` (for VoiceRecognitionHelper)

## Privacy Permissions

Add these keys to your `Info.plist` for voice recognition:

```xml
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app needs speech recognition to enable voice search</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for voice search</string>
```

## Testing

Each utility can be tested independently:

```swift
// Test CryptoAES
let encrypted = "base64EncodedEncryptedData"
let key = "your-secret-key"
let result = CryptoAES.decrypt(encryptedData: encrypted, key: key)

// Test CookieManager
let manager = CookieManager.shared
// ... test cookie operations

// Test VoiceRecognitionHelper
let helper = VoiceRecognitionHelper(onResult: { _ in }, onError: { _ in }, onListeningStateChanged: { _ in })
// ... test voice recognition

// Test StringConverter
let data = "test string".data(using: .utf8)!
let converter = StringConverter()
let result = try? converter.convert(data: data)
```

## Contributing

When adding new iOS utilities:

1. Maintain the same functionality as the Android version
2. Follow Swift naming conventions (camelCase, clear descriptive names)
3. Add comprehensive documentation
4. Include usage examples
5. Update this README

## License

These utilities are part of the StreamFlix project and are licensed under Apache-2.0.

See the [LICENSE](../LICENSE) file for details.
