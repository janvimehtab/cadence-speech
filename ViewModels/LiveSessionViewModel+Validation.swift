import Foundation

extension LiveSessionViewModel {
    
    var summaryIsValid: Bool {
        
        // No meaningful speech.
        if wordCount == 0 {
            return false
        }
        
        // Too little speech to produce useful analysis.
        if wordCount < 10 {
            return false
        }
        
        // Very slow speech during a longer session.
        if elapsedTime >= 30 &&
            wordsPerMinute < 20 {
            return false
        }
        
        // Extremely little speech even in a shorter session.
        if elapsedTime >= 15 &&
            wordsPerMinute < 10 {
            return false
        }
        
        return true
    }
    
    var summaryValidationMessage: String {
        
        if wordCount == 0 {
            return "Cadence couldn't detect enough speech to analyze this session."
        }
        
        if wordCount < 10 {
            return "There wasn't enough speech to produce a reliable analysis. Try speaking for longer."
        }
        
        if elapsedTime >= 30 &&
            wordsPerMinute < 20 {
            return "There wasn't enough continuous speech to produce a reliable analysis."
        }
        
        if elapsedTime >= 15 &&
            wordsPerMinute < 10 {
            return "Very little speech was detected. Try speaking more continuously next time."
        }
        
        return ""
    }
}
