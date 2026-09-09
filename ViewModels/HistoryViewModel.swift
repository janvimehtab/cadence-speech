import Foundation
import SwiftUI
import SwiftData

@MainActor
final class HistoryViewModel: ObservableObject {
    
    @Published private(set) var sessions: [SpeechSession] = []
    
    @Published private(set) var totalSessions: Int = 0
    @Published private(set) var averageScore: Double = 0
    @Published private(set) var bestScore: Double = 0
    @Published private(set) var averageWPM: Double = 0
    @Published private(set) var totalPracticeTime: TimeInterval = 0
    @Published private(set) var totalFillers: Int = 0
    
    private var modelContext: ModelContext?
    
    // MARK: - Configure
    
    func configure(context: ModelContext) {
        modelContext = context
        loadSessions()
    }
    
    // MARK: - Load
    
    func loadSessions() {
        guard let modelContext else {
            sessions = []
            calculateStatistics()
            return
        }
        
        let descriptor = FetchDescriptor<SpeechSession>(
            sortBy: [
                SortDescriptor(
                    \SpeechSession.date,
                     order: .reverse
                )
            ]
        )
        
        do {
            sessions = try modelContext.fetch(descriptor)
            calculateStatistics()
        } catch {
            print(
                "Failed to load speech sessions: \(error)"
            )
            
            sessions = []
            calculateStatistics()
        }
    }
    
    // MARK: - Delete
    
    func deleteSession(_ session: SpeechSession) {
        guard let modelContext else {
            return
        }
        
        modelContext.delete(session)
        
        do {
            try modelContext.save()
            loadSessions()
        } catch {
            print(
                "Failed to delete speech session: \(error)"
            )
        }
    }
    
    func deleteSessions(at offsets: IndexSet) {
        guard let modelContext else {
            return
        }
        
        for index in offsets {
            guard sessions.indices.contains(index) else {
                continue
            }
            
            let session = sessions[index]
            modelContext.delete(session)
        }
        
        do {
            try modelContext.save()
            loadSessions()
        } catch {
            print(
                "Failed to delete speech sessions: \(error)"
            )
        }
    }
    
    // MARK: - Statistics
    
    private func calculateStatistics() {
        
        totalSessions = sessions.count
        
        guard !sessions.isEmpty else {
            averageScore = 0
            bestScore = 0
            averageWPM = 0
            totalPracticeTime = 0
            totalFillers = 0
            return
        }
        
        // Average score
        
        let scores = sessions.map {
            $0.clarityScore
        }
        
        averageScore =
        scores.reduce(0, +)
        / Double(scores.count)
        
        // Best score
        
        bestScore =
        scores.max() ?? 0
        
        // Average WPM
        
        let sessionsWithWPM =
        sessions.filter {
            $0.wordsPerMinute > 0
        }
        
        if sessionsWithWPM.isEmpty {
            averageWPM = 0
        } else {
            averageWPM =
            sessionsWithWPM
                .map {
                    $0.wordsPerMinute
                }
                .reduce(0, +)
            / Double(sessionsWithWPM.count)
        }
        
        // Total practice time
        
        totalPracticeTime =
        sessions
            .map {
                $0.duration
            }
            .reduce(0, +)
        
        // Total fillers
        
        totalFillers =
        sessions
            .map {
                $0.fillerCount
            }
            .reduce(0, +)
    }
    
    // MARK: - Recent Sessions
    
    var recentSessions: [SpeechSession] {
        Array(
            sessions.prefix(7)
        )
    }
    
    // Oldest → newest for chart
    
    var scoreTrend: [SpeechSession] {
        Array(
            sessions
                .reversed()
                .prefix(10)
        )
    }
    
    // MARK: - Latest / Previous
    
    var latestSession: SpeechSession? {
        sessions.first
    }
    
    var previousSession: SpeechSession? {
        guard sessions.count >= 2 else {
            return nil
        }
        
        return sessions[1]
    }
    
    // MARK: - Score Change
    
    var scoreChange: Double {
        guard
            let latest = latestSession,
            let previous = previousSession
        else {
            return 0
        }
        
        return latest.clarityScore
        - previous.clarityScore
    }
    
    var scoreChangeText: String {
        let change = scoreChange
        
        if abs(change) < 0.5 {
            return "No significant change"
        }
        
        if change > 0 {
            return String(
                format:
                    "+%.0f from your last session",
                change
            )
        }
        
        return String(
            format:
                "%.0f from your last session",
            change
        )
    }
    
    var scoreChangeIsPositive: Bool {
        scoreChange >= 0
    }
    
    // MARK: - Pause Statistics
    
    var averagePauseQuality: Double {
        let validSessions =
        sessions.filter {
            $0.pauseQualityScore > 0
        }
        
        guard !validSessions.isEmpty else {
            return 0
        }
        
        return validSessions
            .map {
                $0.pauseQualityScore
            }
            .reduce(0, +)
        / Double(validSessions.count)
    }
    
    // MARK: - Filler Statistics
    
    var averageFillersPerSession: Double {
        guard !sessions.isEmpty else {
            return 0
        }
        
        return Double(totalFillers)
        / Double(sessions.count)
    }
    
    // MARK: - Practice Time
    
    var practiceTimeText: String {
        
        let totalMinutes =
        Int(totalPracticeTime / 60)
        
        if totalMinutes < 60 {
            return "\(totalMinutes)m"
        }
        
        let hours =
        totalMinutes / 60
        
        let minutes =
        totalMinutes % 60
        
        if minutes == 0 {
            return "\(hours)h"
        }
        
        return "\(hours)h \(minutes)m"
    }
}
