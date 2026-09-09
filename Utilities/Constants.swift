import Foundation

enum Constants {
    
    // MARK: - App
    static let appName = "Cadence"
    // MARK: - Speech Analysis
    static let powerPauseThreshold: TimeInterval = 1.0
    static let minimumSpeechLevel: Float = -45.0
    // MARK: - Clarity Score
    static let fillerPenalty: Double = 5.0
    static let powerPauseReward: Double = 2.0
    static let maximumClarityScore: Double = 100.0
    static let minimumClarityScore: Double = 0.0
    // MARK: - Storage Keys
    enum StorageKeys {
        static let selectedSpeakingPace = "selectedSpeakingPace"
        static let enabledFillerWords = "enabledFillerWords"
    }
    // MARK: - Time
    static let secondsPerMinute: Double = 60.0
    
}
