import Foundation
import Speech
import AVFoundation

final class SpeechRecognizerService: ObservableObject {
    
    @Published private(set) var transcript: String = ""
    @Published private(set) var isRecognizing = false
    @Published private(set) var authorizationStatus =
    SFSpeechRecognizer.authorizationStatus()
    
    @Published var errorMessage: String?
    
    private let speechRecognizer =
    SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    
    private var recognitionRequest:
    SFSpeechAudioBufferRecognitionRequest?
    
    private var recognitionTask:
    SFSpeechRecognitionTask?
    
    private var isStoppingIntentionally = false
    
    // Used when we need to wait for the final transcript.
    private var finalResultContinuation:
    CheckedContinuation<String, Never>?
    
    // MARK: - Permission
    
    func requestPermission(
        completion: @escaping (Bool) -> Void
    ) {
        
        let currentStatus =
        SFSpeechRecognizer.authorizationStatus()
        
        if currentStatus == .authorized {
            authorizationStatus = .authorized
            completion(true)
            return
        }
        
        SFSpeechRecognizer.requestAuthorization {
            [weak self] status in
            
            DispatchQueue.main.async {
                
                self?.authorizationStatus = status
                
                if status == .authorized {
                    completion(true)
                } else {
                    self?.errorMessage =
                    "Speech recognition permission was not granted."
                    
                    completion(false)
                }
            }
        }
    }
    
    // MARK: - Start Recognition
    
    func startRecognition() {
        
        stopRecognition()
        
        guard let speechRecognizer else {
            errorMessage =
            "Speech recognizer is unavailable."
            return
        }
        
        guard speechRecognizer.isAvailable else {
            errorMessage =
            "Speech recognition is currently unavailable."
            return
        }
        
        guard authorizationStatus == .authorized else {
            errorMessage =
            "Speech recognition permission is not granted."
            return
        }
        
        isStoppingIntentionally = false
        errorMessage = nil
        
        let request =
        SFSpeechAudioBufferRecognitionRequest()
        
        request.shouldReportPartialResults = true
        
        if #available(iOS 13.0, *) {
            request.requiresOnDeviceRecognition = false
        }
        
        recognitionRequest = request
        
        recognitionTask =
        speechRecognizer.recognitionTask(
            with: request
        ) {
            [weak self] result, error in
            
            guard let self else {
                return
            }
            
            DispatchQueue.main.async {
                
                if let result {
                    
                    self.transcript =
                    result.bestTranscription
                        .formattedString
                    
                    if result.isFinal {
                        self.isRecognizing = false
                        
                        self.finalResultContinuation?
                            .resume(
                                returning: self.transcript
                            )
                        
                        self.finalResultContinuation = nil
                    }
                }
                
                if let error {
                    
                    if self.isStoppingIntentionally {
                        
                        if self.finalResultContinuation != nil {
                            
                            self.finalResultContinuation?
                                .resume(
                                    returning: self.transcript
                                )
                            
                            self.finalResultContinuation = nil
                        }
                        
                    } else {
                        
                        self.errorMessage =
                        "Speech recognition error: \(error.localizedDescription)"
                        
                        self.isRecognizing = false
                    }
                }
            }
        }
        
        isRecognizing = true
    }
    
    // MARK: - Append Audio
    
    func appendAudioBuffer(
        _ buffer: AVAudioPCMBuffer
    ) {
        
        guard isRecognizing else {
            return
        }
        
        guard let recognitionRequest else {
            return
        }
        
        recognitionRequest.append(buffer)
    }
    
    // MARK: - Final Transcript
    
    func stopAndGetFinalTranscript() async -> String {
        
        guard
            recognitionRequest != nil ||
                recognitionTask != nil ||
                isRecognizing
        else {
            return transcript
        }
        
        isStoppingIntentionally = true
        
        recognitionRequest?.endAudio()
        
        let currentTranscript = transcript
        
        let finalTranscript = await withCheckedContinuation {
            (continuation: CheckedContinuation<String, Never>) in
            
            finalResultContinuation = continuation
            
            // Safety timeout.
            Task { [weak self] in
                
                try? await Task.sleep(
                    nanoseconds: 1_500_000_000
                )
                
                guard let self else {
                    return
                }
                
                await MainActor.run {
                    
                    if self.finalResultContinuation != nil {
                        
                        self.finalResultContinuation?
                            .resume(
                                returning: self.transcript.isEmpty
                                ? currentTranscript
                                : self.transcript
                            )
                        
                        self.finalResultContinuation = nil
                    }
                }
            }
        }
        
        recognitionTask?.cancel()
        
        recognitionRequest = nil
        recognitionTask = nil
        
        isRecognizing = false
        
        return finalTranscript
    }
    
    // MARK: - Stop Immediately
    
    func stopRecognition() {
        
        isStoppingIntentionally = true
        
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        recognitionRequest = nil
        recognitionTask = nil
        
        isRecognizing = false
        
        if finalResultContinuation != nil {
            
            finalResultContinuation?
                .resume(
                    returning: transcript
                )
            
            finalResultContinuation = nil
        }
    }
    
    // MARK: - Reset
    
    func reset() {
        
        stopRecognition()
        
        transcript = ""
        errorMessage = nil
    }
}
