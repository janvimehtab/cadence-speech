import Foundation
import SwiftData

@Model
final class SpeechSession {
    
    var id: UUID
    var date: Date
    var duration: TimeInterval
    
    var totalWords: Int
    var fillerCount: Int
    
    var powerPauseCount: Int
    
    var wordsPerMinute: Double
    var clarityScore: Double
    
    var transcript: String
    
    var fillerWordCounts: [String: Int]
    
    // MARK: - Pause Analysis
    
    var totalSilenceDuration: TimeInterval
    var averagePauseDuration: TimeInterval
    var pauseRatio: Double
    var pauseQualityScore: Double
    
    init(
        id: UUID = UUID(),
        date: Date = .now,
        duration: TimeInterval,
        totalWords: Int,
        fillerCount: Int,
        powerPauseCount: Int,
        wordsPerMinute: Double,
        clarityScore: Double,
        transcript: String,
        fillerWordCounts: [String: Int] = [:],
        totalSilenceDuration: TimeInterval = 0,
        averagePauseDuration: TimeInterval = 0,
        pauseRatio: Double = 0,
        pauseQualityScore: Double = 0
    ) {
        
        self.id = id
        self.date = date
        self.duration = duration
        
        self.totalWords = totalWords
        self.fillerCount = fillerCount
        
        self.powerPauseCount = powerPauseCount
        
        self.wordsPerMinute = wordsPerMinute
        self.clarityScore = clarityScore
        
        self.transcript = transcript
        
        self.fillerWordCounts =
        fillerWordCounts
        
        self.totalSilenceDuration =
        totalSilenceDuration
        
        self.averagePauseDuration =
        averagePauseDuration
        
        self.pauseRatio =
        pauseRatio
        
        self.pauseQualityScore =
        pauseQualityScore
    }
}
