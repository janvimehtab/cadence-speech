import Foundation

enum FillerWord: String, CaseIterable, Identifiable, Codable {
    
    case um
    case uh
    case like
    case basically
    case literally
    case so
    case youKnow = "you know"
    var id: String {
        rawValue
    }
    var displayName: String {
        switch self {
        case .um:
            return "Um"
        case .uh:
            return "Uh"
        case .like:
            return "Like"
        case .basically:
            return "Basically"
        case .literally:
            return "Literally"
        case .so:
            return "So"
        case .youKnow:
            return "You know"
        }
    }
    
}
