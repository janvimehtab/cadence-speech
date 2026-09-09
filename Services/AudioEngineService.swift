import Foundation
import AVFoundation

struct PauseAnalysisSnapshot {
    
    let pauseCount: Int
    let totalSilenceDuration: TimeInterval
    let averagePauseDuration: TimeInterval
    
    static let empty = PauseAnalysisSnapshot(
        pauseCount: 0,
        totalSilenceDuration: 0,
        averagePauseDuration: 0
    )
}

final class AudioEngineService: ObservableObject {
    
    // MARK: - Published State
    
    @Published private(set) var isRecording = false
    @Published private(set) var audioLevel: Float = 0
    
    @Published private(set) var powerPauseCount: Int = 0
    @Published private(set) var totalSilenceDuration: TimeInterval = 0
    @Published private(set) var averagePauseDuration: TimeInterval = 0
    
    // MARK: - Audio Callback
    
    var audioBufferHandler: ((AVAudioPCMBuffer) -> Void)?
    
    // MARK: - Audio Engine
    
    private let audioEngine = AVAudioEngine()
    
    // MARK: - Pause Detection
    
    private let silenceThreshold: Float = 0.035
    
    private let minimumPauseDuration: TimeInterval = 0.4
    
    private let maximumTrackedPauseDuration: TimeInterval = 8.0
    
    private var silenceStartTime: Date?
    
    private var hasDetectedSpeech = false
    
    private var pauseCurrentlyBeingCounted = false
    
    private var pauseDurations: [TimeInterval] = []
    
    // MARK: - Start Recording
    
    func startRecording() throws {
        
        guard !isRecording else {
            return
        }
        
        // Reset only transient detection state.
        //
        // IMPORTANT:
        // We do NOT clear pauseDurations here because resumeSession()
        // should preserve the pauses accumulated earlier in the session.
        resetTransientPauseState()
        
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
        
        let inputNode =
        audioEngine.inputNode
        
        let recordingFormat =
        inputNode.outputFormat(forBus: 0)
        
        inputNode.removeTap(onBus: 0)
        
        inputNode.installTap(
            onBus: 0,
            bufferSize: 1024,
            format: recordingFormat
        ) {
            [weak self] audioBuffer, _ in
            
            guard let self else {
                return
            }
            
            let level =
            self.calculateAudioLevel(
                from: audioBuffer
            )
            
            self.processAudioLevel(level)
            
            DispatchQueue.main.async {
                self.audioLevel = level
            }
            
            self.audioBufferHandler?(
                audioBuffer
            )
        }
        
        audioEngine.prepare()
        
        try audioEngine.start()
        
        DispatchQueue.main.async {
            self.isRecording = true
        }
    }
    
    // MARK: - Stop Recording
    
    @discardableResult
    func stopRecording() -> PauseAnalysisSnapshot {
        
        guard isRecording else {
            return currentPauseSnapshot()
        }
        
        // Finalize any silence that is still happening.
        finalizeCurrentPause()
        
        audioEngine.stop()
        
        audioEngine.inputNode.removeTap(
            onBus: 0
        )
        
        try? AVAudioSession.sharedInstance()
            .setActive(
                false,
                options:
                        .notifyOthersOnDeactivation
            )
        
        let snapshot =
        currentPauseSnapshot()
        
        DispatchQueue.main.async {
            
            self.isRecording = false
            
            self.audioLevel = 0
        }
        
        return snapshot
    }
    
    // MARK: - Reset All Pause Data
    
    func resetPauseData() {
        
        silenceStartTime = nil
        hasDetectedSpeech = false
        pauseCurrentlyBeingCounted = false
        
        pauseDurations.removeAll()
        
        DispatchQueue.main.async {
            
            self.powerPauseCount = 0
            
            self.totalSilenceDuration = 0
            
            self.averagePauseDuration = 0
        }
    }
    
    // MARK: - Reset Transient State
    
    private func resetTransientPauseState() {
        
        silenceStartTime = nil
        
        hasDetectedSpeech = false
        
        pauseCurrentlyBeingCounted = false
    }
    
    // MARK: - Pause Detection
    
    private func processAudioLevel(
        _ level: Float
    ) {
        
        let now = Date()
        
        // --------------------------------------------------
        // SPEECH DETECTED
        // --------------------------------------------------
        
        if level > silenceThreshold {
            
            if pauseCurrentlyBeingCounted {
                
                finalizeCurrentPause(
                    at: now
                )
            }
            
            hasDetectedSpeech = true
            
            silenceStartTime = nil
            
            pauseCurrentlyBeingCounted = false
            
            return
        }
        
        // --------------------------------------------------
        // SILENCE BEFORE FIRST SPEECH
        // --------------------------------------------------
        
        guard hasDetectedSpeech else {
            return
        }
        
        // Start measuring silence.
        if silenceStartTime == nil {
            
            silenceStartTime = now
            
            return
        }
        
        guard let silenceStartTime else {
            return
        }
        
        let silenceDuration =
        now.timeIntervalSince(
            silenceStartTime
        )
        
        // Ignore tiny gaps.
        guard silenceDuration >= minimumPauseDuration else {
            return
        }
        
        // Don't count the same pause repeatedly.
        guard !pauseCurrentlyBeingCounted else {
            return
        }
        
        pauseCurrentlyBeingCounted = true
    }
    
    // MARK: - Finalize Pause
    
    private func finalizeCurrentPause(
        at endTime: Date = Date()
    ) {
        
        guard
            hasDetectedSpeech,
            let silenceStartTime
        else {
            
            self.silenceStartTime = nil
            
            self.pauseCurrentlyBeingCounted = false
            
            return
        }
        
        let duration =
        endTime.timeIntervalSince(
            silenceStartTime
        )
        
        self.silenceStartTime = nil
        
        self.pauseCurrentlyBeingCounted = false
        
        guard duration >= minimumPauseDuration else {
            return
        }
        
        let trackedDuration =
        min(
            duration,
            maximumTrackedPauseDuration
        )
        
        pauseDurations.append(
            trackedDuration
        )
        
        publishPauseMetrics()
    }
    
    // MARK: - Pause Metrics
    
    private func publishPauseMetrics() {
        
        let count =
        pauseDurations.count
        
        let total =
        pauseDurations.reduce(
            0,
            +
        )
        
        let average =
        count > 0
        ? total / Double(count)
        : 0
        
        DispatchQueue.main.async {
            
            self.powerPauseCount =
            count
            
            self.totalSilenceDuration =
            total
            
            self.averagePauseDuration =
            average
        }
    }
    
    // MARK: - Snapshot
    
    private func currentPauseSnapshot()
    -> PauseAnalysisSnapshot {
        
        let count =
        pauseDurations.count
        
        let total =
        pauseDurations.reduce(
            0,
            +
        )
        
        let average =
        count > 0
        ? total / Double(count)
        : 0
        
        return PauseAnalysisSnapshot(
            pauseCount: count,
            totalSilenceDuration: total,
            averagePauseDuration: average
        )
    }
    
    // MARK: - Audio Level
    
    private func calculateAudioLevel(
        from audioBuffer: AVAudioPCMBuffer
    ) -> Float {
        
        guard
            let channelData =
                audioBuffer.floatChannelData
        else {
            return 0
        }
        
        let channel =
        channelData[0]
        
        let frameCount =
        Int(
            audioBuffer.frameLength
        )
        
        guard frameCount > 0 else {
            return 0
        }
        
        var sum: Float = 0
        
        for index in 0..<frameCount {
            
            let sample =
            channel[index]
            
            sum += sample * sample
        }
        
        let rms =
        sqrt(
            sum / Float(frameCount)
        )
        
        return min(
            max(
                rms * 10,
                0
            ),
            1
        )
    }
}
