import SwiftUI
import Speech
import AVFoundation

struct CadenceTestView: View {
    
    @State private var transcript = ""
    @State private var isListening = false
    @State private var status = "Ready"
    @State private var errorMessage = ""
    
    private let audioEngine = AVAudioEngine()
    
    @State private var recognitionRequest:
    SFSpeechAudioBufferRecognitionRequest?
    
    @State private var recognitionTask:
    SFSpeechRecognitionTask?
    
    private let speechRecognizer =
    SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                
                VStack(spacing: 8) {
                    Text("Speech Recognition Test")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(status)
                        .foregroundStyle(
                            isListening ? .green : .secondary
                        )
                }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        
                        Text("Transcript")
                            .font(.headline)
                        
                        if transcript.isEmpty {
                            Text("Start speaking...")
                                .foregroundStyle(.secondary)
                        } else {
                            Text(transcript)
                                .font(.body)
                        }
                    }
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .padding()
                }
                .frame(maxHeight: .infinity)
                .background(.regularMaterial)
                .clipShape(
                    RoundedRectangle(cornerRadius: 16)
                )
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                }
                
                Button {
                    if isListening {
                        stopListening()
                    } else {
                        startListening()
                    }
                } label: {
                    Label(
                        isListening ? "Stop Test" : "Start Test",
                        systemImage: isListening
                        ? "stop.fill"
                        : "mic.fill"
                    )
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("Speech Test")
        }
        .onDisappear {
            stopListening()
        }
    }
    
    // MARK: - Start
    
    private func startListening() {
        
        errorMessage = ""
        transcript = ""
        status = "Requesting microphone permission..."
        
        if #available(iOS 17.0, *) {
            
            AVAudioApplication.requestRecordPermission { granted in
                
                DispatchQueue.main.async {
                    
                    guard granted else {
                        errorMessage =
                        "Microphone permission was denied."
                        status =
                        "Microphone permission denied"
                        return
                    }
                    
                    requestSpeechPermission()
                }
            }
            
        } else {
            
            AVAudioSession.sharedInstance()
                .requestRecordPermission { granted in
                    
                    DispatchQueue.main.async {
                        
                        guard granted else {
                            errorMessage =
                            "Microphone permission was denied."
                            status =
                            "Microphone permission denied"
                            return
                        }
                        
                        requestSpeechPermission()
                    }
                }
        }
    }
    
    // MARK: - Speech Permission
    
    private func requestSpeechPermission() {
        
        status = "Requesting speech permission..."
        
        SFSpeechRecognizer.requestAuthorization { authorizationStatus in
            
            DispatchQueue.main.async {
                
                guard authorizationStatus == .authorized else {
                    
                    errorMessage =
                    "Speech recognition permission was not granted."
                    
                    status =
                    "Speech permission denied"
                    
                    return
                }
                
                beginRecognition()
            }
        }
    }
    
    // MARK: - Begin Recognition
    
    private func beginRecognition() {
        
        guard let recognizer = speechRecognizer else {
            
            errorMessage =
            "Speech recognizer could not be created."
            
            status =
            "Recognizer unavailable"
            
            return
        }
        
        guard recognizer.isAvailable else {
            
            errorMessage =
            "Speech recognizer is currently unavailable."
            
            status =
            "Recognizer unavailable"
            
            return
        }
        
        do {
            
            let audioSession =
            AVAudioSession.sharedInstance()
            
            try audioSession.setCategory(
                .record,
                mode: .measurement,
                options: [.duckOthers]
            )
            
            try audioSession.setActive(
                true,
                options: .notifyOthersOnDeactivation
            )
            
            let request =
            SFSpeechAudioBufferRecognitionRequest()
            
            request.shouldReportPartialResults = true
            
            if #available(iOS 13.0, *) {
                request.requiresOnDeviceRecognition = false
            }
            
            recognitionRequest = request
            
            recognitionTask =
            recognizer.recognitionTask(
                with: request
            ) { result, error in
                
                DispatchQueue.main.async {
                    
                    if let result = result {
                        
                        transcript =
                        result.bestTranscription
                            .formattedString
                        
                        status = "Listening..."
                    }
                    
                    if let error = error {
                        
                        if isListening {
                            
                            errorMessage =
                            "Recognition error: \(error.localizedDescription)"
                            
                            status =
                            "Recognition error"
                            
                            isListening = false
                        }
                    }
                }
            }
            
            let inputNode =
            audioEngine.inputNode
            
            let recordingFormat =
            inputNode.outputFormat(forBus: 0)
            
            inputNode.removeTap(onBus: 0)
            
            inputNode.installTap(
                onBus: 0,
                bufferSize: 1024,
                format: recordingFormat
            ) { buffer, _ in
                
                request.append(buffer)
            }
            
            audioEngine.prepare()
            
            try audioEngine.start()
            
            isListening = true
            status = "Listening..."
            
        } catch {
            
            errorMessage =
            "Could not start audio engine: \(error.localizedDescription)"
            
            status =
            "Failed to start"
            
            cleanupAudio()
        }
    }
    
    // MARK: - Stop
    
    private func stopListening() {
        
        isListening = false
        
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        cleanupAudio()
        
        status = "Stopped"
    }
    
    // MARK: - Cleanup
    
    private func cleanupAudio() {
        
        audioEngine.stop()
        
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionRequest = nil
        recognitionTask = nil
        
        try? AVAudioSession.sharedInstance()
            .setActive(
                false,
                options: .notifyOthersOnDeactivation
            )
    }
}

#Preview {
    CadenceTestView()
}
