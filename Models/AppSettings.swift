import Foundation
import SwiftData

enum SpeakingPace: String, CaseIterable, Identifiable {
    
    case fast
    case moderate
    case slow
    
    var id: String {
        rawValue
    }
    
    var title: String {
        switch self {
        case .fast:
            return "Fast / Pitch"
        case .moderate:
            return "Moderate / Presentation"
        case .slow:
            return "Slow / Lecture"
        }
    }
    
    var description: String {
        switch self {
        case .fast:
            return "160–220 WPM"
        case .moderate:
            return "130–160 WPM"
        case .slow:
            return "80–129 WPM"
        }
    }
    
    var targetRange: ClosedRange<Double> {
        switch self {
        case .fast:
            return 160...220
        case .moderate:
            return 130...160
        case .slow:
            return 80...129
        }
    }
}

@Model
final class AppSettings {
    
    var id: UUID
    
    var speakingPaceRawValue: String
    
    var fillersEnabled: Bool
    
    var enabledFillers: [String]
    
    init(
        id: UUID = UUID(),
        speakingPace: SpeakingPace = .moderate,
        fillersEnabled: Bool = true,
        enabledFillers: [String] = FillerWord.allCases.map(\.rawValue)
    ) {
        self.id = id
        self.speakingPaceRawValue = speakingPace.rawValue
        self.fillersEnabled = fillersEnabled
        self.enabledFillers = enabledFillers
    }
    
    var speakingPace: SpeakingPace {
        get {
            SpeakingPace(rawValue: speakingPaceRawValue) ?? .moderate
        }
        set {
            speakingPaceRawValue = newValue.rawValue
        }
    }
    
    var enabledFillerSet: Set<String> {
        Set(enabledFillers)
    }
}
