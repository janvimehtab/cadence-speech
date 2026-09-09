import Foundation
import SwiftUI
import AVFoundation
import SwiftData
import Combine

@MainActor
final class LiveSessionViewModel: ObservableObject {
    
    // MARK: - Challenge
    
    static let challengeDuration: TimeInterval = 120
    
    @Published private(set) var currentTopic: SpeechTopic =
    SpeechTopicBank.randomTopic()
    
    @Published private(set) var isSessionActive = false
    @Published private(set) var isPaused = false
    
    // MARK: - Speech
    
    @Published private(set) var transcript = ""
    @Published private(set) var audioLevel: Float = 0
    
    @Published private(set) var elapsedTime: TimeInterval = 0
    
    // MARK: - Live Statistics
    
    @Published private(set) var wordCount = 0
    @Published private(set) var fillerCount = 0
    @Published private(set) var fillerFrequency = 0.0
    @Published private(set) var wordsPerMinute = 0.0
    
    // MARK: - Pause Statistics
    
    @Published private(set) var powerPauses = 0
    @Published private(set) var totalSilenceDuration = 0.0
    @Published private(set) var averagePauseDuration = 0.0
    @Published private(set) var pauseRatio = 0.0
    @Published private(set) var pauseFrequency = 0.0
    @Published private(set) var pauseQualityScore = 0.0
    
    // MARK: - Score
    
    @Published private(set) var clarityScore = 0.0
    
    // MARK: - Filler Details
    
    @Published private(set) var fillerWords: [String: Int] = [:]
    
    // MARK: - Feedback
    
    @Published private(set) var paceFeedback = ""
    @Published private(set) var fillerFeedback = ""
    @Published private(set) var pauseFeedback = ""
    @Published private(set) var overallFeedback = ""
    
    // MARK: - Validation
    
    @Published private(set) var isValidSession = false
    @Published private(set) var validationMessage = ""
    
    // MARK: - Errors
    
    @Published var errorMessage: String?
    
    // MARK: - Services
    
    private let audioEngineService =
    AudioEngineService()
    
    private let speechRecognizerService =
    SpeechRecognizerService()
    
    private let speechAnalysisService =
    SpeechAnalysisService()
    
    private let sessionTimerService =
    SessionTimerService()
    
    // MARK: - Persistence
    
    private var modelContext: ModelContext?
    private var appSettings: AppSettings?
    
    private var cancellables =
    Set<AnyCancellable>()
    
    // MARK: - Internal State
    
    private var finalTranscript = ""
    private var isStoppingSession = false
    private var hasReachedTimeLimit = false
    
    // MARK: - Init
    
    init() {
        setupBindings()
    }
    
    // MARK: - Configuration
    
    func configure(
        context: ModelContext
    ) {
        modelContext = context
        loadSettings()
    }
    
    private func loadSettings() {
        
        guard let modelContext else {
            return
        }
        
        let descriptor =
        FetchDescriptor<AppSettings>()
        
        do {
            
            let existingSettings =
            try modelContext.fetch(
                descriptor
            )
            
            if let existing =
                existingSettings.first {
                
                appSettings =
                existing
                
            } else {
                
                let newSettings =
                AppSettings()
                
                modelContext.insert(
                    newSettings
                )
                
                try modelContext.save()
                
                appSettings =
                newSettings
            }
            
        } catch {
            
            print(
                "Failed to load app settings: \(error)"
            )
        }
    }
    
    // MARK: - Topic
    
    func chooseNewTopic() {
        
        guard !isSessionActive else {
            return
        }
        
        currentTopic =
        SpeechTopicBank.randomTopic()
    }
    
    // MARK: - Bindings
    
    private func setupBindings() {
        
        audioEngineService.$audioLevel
            .receive(
                on: DispatchQueue.main
            )
            .sink {
                [weak self] level in
                
                self?.audioLevel =
                level
            }
            .store(
                in: &cancellables
            )
        
        audioEngineService.$powerPauseCount
            .receive(
                on: DispatchQueue.main
            )
            .sink {
                [weak self] count in
                
                guard let self else {
                    return
                }
                
                self.powerPauses =
                count
                
                self.updateLiveAnalysis()
            }
            .store(
                in: &cancellables
            )
        
        audioEngineService.$totalSilenceDuration
            .receive(
                on: DispatchQueue.main
            )
            .sink {
                [weak self] duration in
                
                guard let self else {
                    return
                }
                
                self.totalSilenceDuration =
                duration
                
                self.updateLiveAnalysis()
            }
            .store(
                in: &cancellables
            )
        
        audioEngineService.$averagePauseDuration
            .receive(
                on: DispatchQueue.main
            )
            .sink {
                [weak self] duration in
                
                guard let self else {
                    return
                }
                
                self.averagePauseDuration =
                duration
                
                self.updateLiveAnalysis()
            }
            .store(
                in: &cancellables
            )
        
        speechRecognizerService.$transcript
            .receive(
                on: DispatchQueue.main
            )
            .sink {
                [weak self] newTranscript in
                
                guard let self else {
                    return
                }
                
                self.transcript =
                newTranscript
                
                if self.isSessionActive &&
                    !self.isStoppingSession {
                    
                    self.updateLiveAnalysis()
                }
            }
            .store(
                in: &cancellables
            )
        
        sessionTimerService.$elapsedTime
            .receive(
                on: DispatchQueue.main
            )
            .sink {
                [weak self] time in
                
                guard let self else {
                    return
                }
                
                self.elapsedTime =
                min(
                    time,
                    Self.challengeDuration
                )
                
                if self.isSessionActive &&
                    !self.isStoppingSession {
                    
                    self.updateLiveAnalysis()
                }
                
                // ------------------------------------------
                // AUTOMATIC 2-MINUTE STOP
                // ------------------------------------------
                
                if self.isSessionActive &&
                    !self.isStoppingSession &&
                    !self.hasReachedTimeLimit &&
                    time >= Self.challengeDuration {
                    
                    self.hasReachedTimeLimit = true
                    
                    Task {
                        _ = await self.stopSession()
                    }
                }
            }
            .store(
                in: &cancellables
            )
    }
    
    // MARK: - Permissions
    
    func requestPermissions(
        completion: @escaping (Bool) -> Void
    ) {
        
        requestMicrophonePermission {
            [weak self] microphoneGranted in
            
            guard microphoneGranted else {
                
                DispatchQueue.main.async {
                    
                    self?.errorMessage =
                    "Microphone permission is required to practice."
                    
                    completion(false)
                }
                
                return
            }
            
            self?.speechRecognizerService
                .requestPermission {
                    [weak self] speechGranted in
                    
                    DispatchQueue.main.async {
                        
                        if !speechGranted {
                            self?.errorMessage =
                            "Speech recognition permission is required."
                        }
                        
                        completion(
                            speechGranted
                        )
                    }
                }
        }
    }
    
    private func requestMicrophonePermission(
        completion: @escaping (Bool) -> Void
    ) {
        
        if #available(iOS 17.0, *) {
            
            AVAudioApplication
                .requestRecordPermission {
                    granted in
                    
                    DispatchQueue.main.async {
                        completion(granted)
                    }
                }
            
        } else {
            
            AVAudioSession
                .sharedInstance()
                .requestRecordPermission {
                    granted in
                    
                    DispatchQueue.main.async {
                        completion(granted)
                    }
                }
        }
    }
    
    // MARK: - Start Challenge
    
    func startSession() {
        
        guard !isSessionActive else {
            return
        }
        
        errorMessage = nil
        
        requestPermissions {
            [weak self] granted in
            
            guard let self else {
                return
            }
            
            guard granted else {
                return
            }
            
            do {
                
                self.resetAnalysis()
                
                self.transcript = ""
                self.finalTranscript = ""
                
                self.isStoppingSession = false
                self.hasReachedTimeLimit = false
                
                self.audioEngineService
                    .resetPauseData()
                
                self.speechRecognizerService
                    .reset()
                
                self.audioEngineService
                    .audioBufferHandler = {
                        [weak self] buffer in
                        
                        guard let self else {
                            return
                        }
                        
                        self.speechRecognizerService
                            .appendAudioBuffer(
                                buffer
                            )
                    }
                
                self.speechRecognizerService
                    .startRecognition()
                
                try self.audioEngineService
                    .startRecording()
                
                self.sessionTimerService
                    .reset()
                
                self.sessionTimerService
                    .start()
                
                self.isSessionActive = true
                self.isPaused = false
                
                self.updateLiveAnalysis()
                
            } catch {
                
                self.errorMessage =
                "Unable to start recording: \(error.localizedDescription)"
                
                self.audioEngineService
                    .stopRecording()
                
                self.speechRecognizerService
                    .stopRecognition()
                
                self.sessionTimerService
                    .stop()
            }
        }
    }
    
    // MARK: - Pause Disabled
    
    func pauseSession() {
        // Intentionally disabled.
        //
        // Cadence now uses a fixed 2-minute speaking challenge.
        // Natural pauses in speech are still measured automatically.
    }
    
    func resumeSession() {
        // Intentionally disabled.
    }
    
    // MARK: - Stop Challenge
    
    func stopSession() async
    -> SpeechAnalysisResult {
        
        guard isSessionActive else {
            
            return analyzeTranscript(
                transcript:
                    finalTranscript,
                duration:
                    elapsedTime
            )
        }
        
        guard !isStoppingSession else {
            
            return analyzeTranscript(
                transcript:
                    finalTranscript,
                duration:
                    elapsedTime
            )
        }
        
        isStoppingSession = true
        
        sessionTimerService
            .stop()
        
        let pauseSnapshot =
        audioEngineService
            .stopRecording()
        
        powerPauses =
        pauseSnapshot.pauseCount
        
        totalSilenceDuration =
        pauseSnapshot.totalSilenceDuration
        
        averagePauseDuration =
        pauseSnapshot.averagePauseDuration
        
        let recognizedTranscript =
        await speechRecognizerService
            .stopAndGetFinalTranscript()
        
        finalTranscript =
        recognizedTranscript
        
        transcript =
        recognizedTranscript
        
        isSessionActive = false
        isPaused = false
        
        // Make sure manually finished sessions don't
        // accidentally exceed the challenge limit.
        elapsedTime =
        min(
            elapsedTime,
            Self.challengeDuration
        )
        
        let result =
        analyzeTranscript(
            transcript:
                finalTranscript,
            duration:
                elapsedTime
        )
        
        applyAnalysisResult(
            result
        )
        
        if result.isValidSession {
            saveSession(
                result:
                    result
            )
        }
        
        isStoppingSession = false
        
        return result
    }
    
    // MARK: - Pause Metrics
    
    private func syncPauseMetrics() {
        
        powerPauses =
        audioEngineService
            .powerPauseCount
        
        totalSilenceDuration =
        audioEngineService
            .totalSilenceDuration
        
        averagePauseDuration =
        audioEngineService
            .averagePauseDuration
    }
    
    // MARK: - Live Analysis
    
    private func updateLiveAnalysis() {
        
        guard isSessionActive else {
            return
        }
        
        guard !isStoppingSession else {
            return
        }
        
        let result =
        analyzeTranscript(
            transcript:
                transcript,
            duration:
                elapsedTime
        )
        
        applyAnalysisResult(
            result
        )
    }
    
    // MARK: - Analyze
    
    private func analyzeTranscript(
        transcript: String,
        duration: TimeInterval
    ) -> SpeechAnalysisResult {
        
        speechAnalysisService.analyze(
            transcript:
                transcript,
            duration:
                duration,
            speakingPace:
                appSettings?.speakingPace
            ?? .moderate,
            enabledFillers:
                appSettings?.enabledFillerSet,
            fillersEnabled:
                appSettings?.fillersEnabled
            ?? true,
            powerPauseCount:
                powerPauses,
            totalSilenceDuration:
                totalSilenceDuration,
            averagePauseDuration:
                averagePauseDuration
        )
    }
    
    // MARK: - Apply Analysis
    
    private func applyAnalysisResult(
        _ result: SpeechAnalysisResult
    ) {
        
        isValidSession =
        result.isValidSession
        
        validationMessage =
        result.validationMessage
        
        wordCount =
        result.totalWords
        
        fillerCount =
        result.fillerCount
        
        fillerFrequency =
        result.fillerFrequency
        
        wordsPerMinute =
        result.wordsPerMinute
        
        powerPauses =
        result.powerPauses
        
        totalSilenceDuration =
        result.totalSilenceDuration
        
        averagePauseDuration =
        result.averagePauseDuration
        
        pauseRatio =
        result.pauseRatio
        
        pauseFrequency =
        result.pauseFrequency
        
        pauseQualityScore =
        result.pauseQualityScore
        
        clarityScore =
        result.clarityScore
        
        fillerWords =
        result.fillerWords
        
        paceFeedback =
        result.paceFeedback
        
        fillerFeedback =
        result.fillerFeedback
        
        pauseFeedback =
        result.pauseFeedback
        
        overallFeedback =
        result.overallFeedback
    }
    
    // MARK: - Save
    
    private func saveSession(
        result: SpeechAnalysisResult
    ) {
        
        guard let modelContext else {
            return
        }
        
        guard result.isValidSession else {
            return
        }
        
        let session =
        SpeechSession(
            date:
                    .now,
            duration:
                elapsedTime,
            totalWords:
                result.totalWords,
            fillerCount:
                result.fillerCount,
            powerPauseCount:
                result.powerPauses,
            wordsPerMinute:
                result.wordsPerMinute,
            clarityScore:
                result.clarityScore,
            transcript:
                finalTranscript,
            fillerWordCounts:
                result.fillerWords,
            totalSilenceDuration:
                result.totalSilenceDuration,
            averagePauseDuration:
                result.averagePauseDuration,
            pauseRatio:
                result.pauseRatio,
            pauseQualityScore:
                result.pauseQualityScore
        )
        
        modelContext.insert(
            session
        )
        
        do {
            try modelContext.save()
        } catch {
            print(
                "Failed to save speech session: \(error)"
            )
        }
    }
    
    // MARK: - Reset
    
    func reset() {
        
        audioEngineService
            .stopRecording()
        
        audioEngineService
            .resetPauseData()
        
        speechRecognizerService
            .reset()
        
        sessionTimerService
            .reset()
        
        isSessionActive = false
        isPaused = false
        isStoppingSession = false
        hasReachedTimeLimit = false
        
        transcript = ""
        finalTranscript = ""
        
        audioLevel = 0
        elapsedTime = 0
        
        resetAnalysis()
        
        errorMessage = nil
    }
    
    private func resetAnalysis() {
        
        isValidSession = false
        validationMessage = ""
        
        wordCount = 0
        fillerCount = 0
        fillerFrequency = 0
        wordsPerMinute = 0
        
        powerPauses = 0
        totalSilenceDuration = 0
        averagePauseDuration = 0
        pauseRatio = 0
        pauseFrequency = 0
        pauseQualityScore = 0
        
        clarityScore = 0
        
        fillerWords = [:]
        
        paceFeedback = ""
        fillerFeedback = ""
        pauseFeedback = ""
        overallFeedback = ""
    }
    
    // MARK: - Formatted Time
    
    var formattedTime: String {
        
        let totalSeconds =
        Int(elapsedTime)
        
        let minutes =
        totalSeconds / 60
        
        let seconds =
        totalSeconds % 60
        
        return String(
            format:
                "%02d:%02d",
            minutes,
            seconds
        )
    }
    
    // MARK: - Remaining Time
    
    var remainingTime: TimeInterval {
        max(
            Self.challengeDuration
            - elapsedTime,
            0
        )
    }
    
    var formattedRemainingTime: String {
        
        let totalSeconds =
        Int(remainingTime)
        
        let minutes =
        totalSeconds / 60
        
        let seconds =
        totalSeconds % 60
        
        return String(
            format:
                "%02d:%02d",
            minutes,
            seconds
        )
    }
    
    // MARK: - Challenge Progress
    
    var challengeProgress: Double {
        
        min(
            max(
                elapsedTime
                / Self.challengeDuration,
                0
            ),
            1
        )
    }
    
    // MARK: - Pace Status
    
    var paceStatus: String {
        
        let target =
        appSettings?.speakingPace
            .targetRange
        ?? SpeakingPace
            .moderate
            .targetRange
        
        if wordsPerMinute <= 0 {
            return "Waiting"
        }
        
        if target.contains(
            wordsPerMinute
        ) {
            return "On target"
        }
        
        if wordsPerMinute <
            target.lowerBound {
            
            return "A little slow"
        }
        
        return "A little fast"
    }
    
    // MARK: - Pause Status
    
    var pauseStatus: String {
        
        guard powerPauses > 0 else {
            
            if elapsedTime < 5 {
                return "Building data"
            }
            
            return "Few pauses"
        }
        
        if pauseQualityScore >= 90 {
            return "Excellent"
        }
        
        if pauseQualityScore >= 75 {
            return "Good"
        }
        
        if pauseQualityScore >= 60 {
            return "Needs attention"
        }
        
        return "Too interrupted"
    }
    
    // MARK: - Filler Status
    
    var fillerStatus: String {
        
        if fillerCount == 0 {
            return "Excellent"
        }
        
        if fillerFrequency < 1 {
            return "Very low"
        }
        
        if fillerFrequency < 3 {
            return "Low"
        }
        
        if fillerFrequency < 5 {
            return "Moderate"
        }
        
        return "High"
    }
    
    // MARK: - Pause Display
    
    var silencePercentageText: String {
        
        String(
            format:
                "%.0f%% silent",
            pauseRatio * 100
        )
    }
    
    var averagePauseText: String {
        
        String(
            format:
                "%.1fs avg",
            averagePauseDuration
        )
    }
    
    var pauseFrequencyText: String {
        
        String(
            format:
                "%.1f/min",
            pauseFrequency
        )
    }
}
