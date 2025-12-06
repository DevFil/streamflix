import Foundation
import Speech
import AVFoundation

/// Helper class for voice recognition functionality
/// Translated from Android's VoiceRecognitionHelper.kt
class VoiceRecognitionHelper: NSObject {
    
    // MARK: - Properties
    
    private let onResult: (String) -> Void
    private let onError: (String) -> Void
    private let onListeningStateChanged: (Bool) -> Void
    
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    private(set) var isListening: Bool = false
    
    // MARK: - Initialization
    
    init(onResult: @escaping (String) -> Void,
         onError: @escaping (String) -> Void,
         onListeningStateChanged: @escaping (Bool) -> Void) {
        self.onResult = onResult
        self.onError = onError
        self.onListeningStateChanged = onListeningStateChanged
        super.init()
    }
    
    // MARK: - Public Methods
    
    /// Checks if speech recognition is available on the device
    func isAvailable() -> Bool {
        return SFSpeechRecognizer.authorizationStatus() != .denied &&
               SFSpeechRecognizer.authorizationStatus() != .restricted
    }
    
    /// Starts voice recognition with permission check
    func startWithPermissionCheck() {
        let authStatus = SFSpeechRecognizer.authorizationStatus()
        
        switch authStatus {
        case .authorized:
            // Permission already granted
            startRecognition()
            
        case .notDetermined:
            // Request permission
            SFSpeechRecognizer.requestAuthorization { [weak self] status in
                DispatchQueue.main.async {
                    if status == .authorized {
                        self?.startRecognition()
                    } else {
                        self?.onError("Permission denied for speech recognition")
                    }
                }
            }
            
        case .denied, .restricted:
            // Permission denied or restricted
            onError("Speech recognition permission is denied. Please enable it in Settings.")
            
        @unknown default:
            onError("Unknown authorization status")
        }
    }
    
    /// Stops ongoing voice recognition
    func stopRecognition() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        recognitionTask?.cancel()
        recognitionTask = nil
        
        isListening = false
        onListeningStateChanged(false)
    }
    
    /// Resolves a partial language tag to a full locale identifier
    /// - Parameter partialTag: Partial language code (e.g., "en", "es")
    /// - Returns: Full language tag (e.g., "en-US", "es-ES")
    func resolveFullLanguageTag(partialTag: String) -> String {
        let supportedTags: [String: String] = [
            "en": "en-US",
            "es": "es-ES",
            "de": "de-DE",
            "it": "it-IT",
            "ar": "ar-SA",
            "fr": "fr-FR"
        ]
        
        let normalized = partialTag.lowercased()
        
        return supportedTags[normalized] ?? Locale.current.identifier
    }
    
    // MARK: - Private Methods
    
    private func startRecognition() {
        // Stop any ongoing recognition
        if isListening {
            stopRecognition()
        }
        
        // Check if audio engine is available
        guard !audioEngine.isRunning else {
            onError("Audio engine is already running")
            return
        }
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            onError("Failed to configure audio session: \(error.localizedDescription)")
            return
        }
        
        // Create speech recognizer with locale
        // You can customize the locale based on user preference
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            onError("Speech recognizer is not available")
            return
        }
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = recognitionRequest else {
            onError("Unable to create recognition request")
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Create recognition task
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            var isFinal = false
            
            if let result = result {
                let transcription = result.bestTranscription.formattedString.trimmingCharacters(in: .whitespacesAndNewlines)
                isFinal = result.isFinal
                
                if isFinal && !transcription.isEmpty {
                    self.onResult(transcription)
                    self.stopRecognition()
                }
            }
            
            if error != nil || isFinal {
                self.stopRecognition()
                
                if let error = error {
                    self.onError("Recognition error: \(error.localizedDescription)")
                }
            }
        }
        
        // Configure audio input
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        // Start audio engine
        audioEngine.prepare()
        do {
            try audioEngine.start()
            isListening = true
            onListeningStateChanged(true)
        } catch {
            onError("Failed to start audio engine: \(error.localizedDescription)")
        }
    }
}
