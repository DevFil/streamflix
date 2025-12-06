# Android to iOS Translation Mapping

This document provides a detailed mapping of how Android APIs and patterns were translated to iOS equivalents.

## Overview

The StreamFlix Android utilities have been translated to iOS/Swift while maintaining equivalent functionality. This document serves as a reference for developers familiar with the Android implementation.

## Utility Translations

### 1. CryptoAES

| Aspect | Android (Kotlin) | iOS (Swift) |
|--------|------------------|-------------|
| **File** | `utils/CryptoAES.kt` | `Utils/CryptoAES.swift` |
| **Base64 Decode** | `android.util.Base64.decode()` | `Data(base64Encoded:)` |
| **Cipher** | `javax.crypto.Cipher` | `CommonCrypto` (CCCrypt) |
| **Algorithm** | `"AES/CBC/PKCS5Padding"` | `kCCAlgorithmAES` + `kCCOptionPKCS7Padding` |
| **Key Spec** | `SecretKeySpec` | `Data` with key bytes |
| **IV Spec** | `IvParameterSpec` | `Data` with IV bytes |
| **Error Handling** | Try-catch returning empty string | Try-catch with Swift Error throwing |

**Key Differences:**
- Android uses Java Cryptography Extension (JCE)
- iOS uses CommonCrypto C API (requires unsafe pointer operations)
- PKCS5 and PKCS7 padding are equivalent in practice

---

### 2. MyCookieJar → CookieManager

| Aspect | Android (Kotlin) | iOS (Swift) |
|--------|------------------|-------------|
| **File** | `utils/MyCookieJar.kt` | `Utils/CookieManager.swift` |
| **Interface** | Implements `okhttp3.CookieJar` | Standalone class (no protocol requirement) |
| **Cookie Type** | `okhttp3.Cookie` | `Foundation.HTTPCookie` |
| **URL Type** | `okhttp3.HttpUrl` | `Foundation.URL` |
| **Storage** | `MutableMap<String, MutableList<Cookie>>` | `[String: [HTTPCookie]]` |
| **Access Pattern** | Per-instance | Singleton (`shared`) |

**Key Differences:**
- Android integrates directly with OkHttp interceptor chain
- iOS requires manual cookie management with URLSession
- iOS provides URLSessionConfiguration extension for easy integration

**Additional Features in iOS:**
- `clearAllCookies()` - Clear all stored cookies
- `clearCookies(forHost:)` - Clear cookies for specific host
- `getCookies(forHost:)` - Get cookies for specific host

---

### 3. VoiceRecognitionHelper

| Aspect | Android (Kotlin) | iOS (Swift) |
|--------|------------------|-------------|
| **File** | `utils/VoiceRecognitionHelper.kt` | `Utils/VoiceRecognitionHelper.swift` |
| **Speech API** | `android.speech.SpeechRecognizer` | `Speech.SFSpeechRecognizer` |
| **Permission** | `Manifest.permission.RECORD_AUDIO` | `SFSpeechRecognizer.requestAuthorization()` |
| **Audio** | Managed by `SpeechRecognizer` | Manual `AVAudioEngine` setup |
| **Listener** | `RecognitionListener` interface | Closure-based callbacks |
| **Intent** | `RecognizerIntent` | `SFSpeechAudioBufferRecognitionRequest` |
| **Language** | Intent extra | `SFSpeechRecognizer(locale:)` |

**Key Differences:**
- Android uses Intent-based system
- iOS requires explicit audio session and engine configuration
- Android permission is simpler (single RECORD_AUDIO)
- iOS requires both Speech Recognition and Microphone permissions

**Permission Requirements:**

Android (AndroidManifest.xml):
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
```

iOS (Info.plist):
```xml
<key>NSSpeechRecognitionUsageDescription</key>
<string>...</string>
<key>NSMicrophoneUsageDescription</key>
<string>...</string>
```

---

### 4. StringConverter

| Aspect | Android (Kotlin) | iOS (Swift) |
|--------|------------------|-------------|
| **File** | `utils/StringConverter.kt` | `Utils/StringConverter.swift` |
| **Framework** | Retrofit `Converter.Factory` | Custom `ResponseConverter` protocol |
| **Response Type** | `ResponseBody` | `Data` |
| **Encoding** | `Charsets.UTF_8` | `String.Encoding.utf8` |
| **Integration** | Retrofit builder `.addConverterFactory()` | URLSession extensions |

**Key Differences:**
- Android integrates with Retrofit's converter system
- iOS provides both protocol-based and URLSession extension approaches
- iOS version includes async/await support (iOS 13+)

**API Comparison:**

Android (Retrofit):
```kotlin
val retrofit = Retrofit.Builder()
    .addConverterFactory(StringConverterFactory.create())
    .build()
```

iOS (URLSession Extension):
```swift
// Callback style
URLSession.shared.stringDataTask(with: url) { result in }

// Async/await style
let string = try await URLSession.shared.stringData(from: url)
```

---

## Framework Mappings

### Networking

| Android | iOS |
|---------|-----|
| OkHttp | URLSession |
| Retrofit | URLSession + Codable |
| `ResponseBody` | `Data` |
| `HttpUrl` | `URL` |
| `Cookie` | `HTTPCookie` |

### Cryptography

| Android | iOS |
|---------|-----|
| `javax.crypto.Cipher` | CommonCrypto `CCCrypt()` |
| `android.util.Base64` | `Foundation.Data(base64Encoded:)` |
| `SecretKeySpec` | Raw `Data` |
| `IvParameterSpec` | Raw `Data` |

### Speech Recognition

| Android | iOS |
|---------|-----|
| `SpeechRecognizer` | `SFSpeechRecognizer` |
| `RecognitionListener` | Closure callbacks |
| `RecognizerIntent` | `SFSpeechAudioBufferRecognitionRequest` |
| Automatic audio handling | Manual `AVAudioEngine` |

### Permissions

| Android | iOS |
|---------|-----|
| `Manifest.permission.RECORD_AUDIO` | `NSSpeechRecognitionUsageDescription` + `NSMicrophoneUsageDescription` |
| Runtime permissions via Activity | `SFSpeechRecognizer.requestAuthorization()` |
| `shouldShowRequestPermissionRationale` | Manual alert before requesting |

---

## Design Pattern Differences

### Initialization

**Android:**
```kotlin
class MyClass(
    private val fragment: Fragment,
    private val callback: (String) -> Unit
) {
    private val context = fragment.requireContext()
}
```

**iOS:**
```swift
class MyClass {
    private let callback: (String) -> Void
    
    init(callback: @escaping (String) -> Void) {
        self.callback = callback
    }
}
```

### Callbacks

**Android (Interface):**
```kotlin
interface RecognitionListener {
    fun onResults(results: Bundle?)
    fun onError(error: Int)
}
```

**iOS (Closures):**
```swift
typealias ResultCallback = (String) -> Void
typealias ErrorCallback = (String) -> Void
```

### Error Handling

**Android:**
```kotlin
return try {
    // code
    result
} catch (e: Exception) {
    e.printStackTrace()
    ""
}
```

**iOS:**
```swift
do {
    // code
    return result
} catch {
    print("Error: \(error)")
    return ""
}
```

### Singletons

**Android (Object):**
```kotlin
object CryptoAES {
    fun decrypt(data: String, key: String): String { }
}
```

**iOS (Static or Shared):**
```swift
class CryptoAES {
    static func decrypt(encryptedData: String, key: String) -> String { }
}

// Or for state management:
class CookieManager {
    static let shared = CookieManager()
    private init() {}
}
```

---

## Async Patterns

### Android Coroutines vs iOS async/await

**Android:**
```kotlin
suspend fun fetchData(): String {
    return withContext(Dispatchers.IO) {
        // network call
    }
}
```

**iOS:**
```swift
func fetchData() async throws -> String {
    return try await URLSession.shared.stringData(from: url)
}
```

### Callbacks

**Android:**
```kotlin
fun doWork(callback: (Result) -> Unit) {
    // work
    callback(result)
}
```

**iOS:**
```swift
func doWork(completion: @escaping (Result) -> Void) {
    // work
    completion(result)
}
```

---

## Memory Management

| Android | iOS |
|---------|-----|
| Garbage Collection | Automatic Reference Counting (ARC) |
| No circular reference issues | Use `weak` or `unowned` for closures |
| `lateinit var` | Optional properties or lazy vars |
| N/A | `[weak self]` in closures |

**Example:**

**Android:**
```kotlin
class MyClass(private val fragment: Fragment) {
    fun setup() {
        // No memory leak concerns with fragment reference
    }
}
```

**iOS:**
```swift
class MyClass {
    func setup() {
        someMethod { [weak self] in
            // Prevent retain cycle
            self?.doSomething()
        }
    }
}
```

---

## Platform-Specific Features

### Android-Only Features Not Translated

- `Fragment` integration (iOS uses UIViewController)
- `AlertDialog.Builder` (iOS uses UIAlertController)
- `Activity` context (iOS uses UIViewController)
- Android lifecycle methods

### iOS-Only Features Added

- `async/await` support (Swift 5.5+)
- URLSession extensions for convenience
- More explicit error types
- Singleton patterns where appropriate

---

## Testing Differences

### Android (JUnit + Mockito)

```kotlin
@Test
fun testDecryption() {
    val result = CryptoAES.decrypt(encrypted, key)
    assertEquals(expected, result)
}
```

### iOS (XCTest)

```swift
func testDecryption() {
    let result = CryptoAES.decrypt(encryptedData: encrypted, key: key)
    XCTAssertEqual(expected, result)
}
```

---

## Build System Differences

| Android | iOS |
|---------|-----|
| Gradle | Xcode / Swift Package Manager |
| `build.gradle` | `Package.swift` or Xcode project |
| Maven Central | Swift Package Index / CocoaPods |
| ProGuard/R8 | App Store optimization |

---

## Migration Checklist

When porting Android utilities to iOS:

- [ ] Replace Android framework imports with iOS equivalents
- [ ] Convert `object` to `class` with static methods or singleton
- [ ] Replace interfaces with protocols or closures
- [ ] Convert `lateinit var` to optional or lazy properties
- [ ] Add `[weak self]` where needed to prevent retain cycles
- [ ] Replace Android-specific types (Intent, Bundle, etc.)
- [ ] Update permission handling for iOS
- [ ] Add Info.plist entries for required permissions
- [ ] Convert coroutines to async/await or completion handlers
- [ ] Update error handling to use Swift Error protocol
- [ ] Test on iOS devices/simulators
- [ ] Add documentation comments using Swift markup

---

## Performance Considerations

### Android
- Garbage collector pauses
- Dalvik/ART optimizations
- ProGuard reduces APK size

### iOS
- ARC (no GC pauses)
- Swift optimizations (whole module optimization)
- Bitcode enables App Store optimizations

---

## Further Resources

- [Swift from Kotlin](https://kotlinlang.org/docs/apple-platform.html)
- [iOS for Android Developers](https://developer.apple.com/)
- [CommonCrypto Documentation](https://developer.apple.com/documentation/security)
- [Speech Framework](https://developer.apple.com/documentation/speech)

---

## Contributing

When adding new translations:

1. Update this mapping document
2. Add comparison examples
3. Document any platform-specific caveats
4. Include test cases for both platforms
5. Update the main README with usage examples
