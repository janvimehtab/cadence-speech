import Foundation

struct SpeechAnalysisResult {
    
    // MARK: - Validity
    
    let isValidSession: Bool
    let validationMessage: String
    
    // MARK: - Speech Metrics
    
    let totalWords: Int
    let wordsPerMinute: Double
    
    let fillerCount: Int
    let fillerWords: [String: Int]
    let fillerFrequency: Double
    
    // MARK: - Pause Metrics
    
    let powerPauses: Int
    let totalSilenceDuration: TimeInterval
    let averagePauseDuration: TimeInterval
    let pauseRatio: Double
    let pauseFrequency: Double
    let pauseQualityScore: Double
    
    // MARK: - Score
    
    let clarityScore: Double
    
    // MARK: - Feedback
    
    let paceFeedback: String
    let fillerFeedback: String
    let pauseFeedback: String
    let overallFeedback: String
}

final class SpeechAnalysisService {
    
    // MARK: - Main Analysis
    
    func analyze(
        transcript: String,
        duration: TimeInterval,
        speakingPace: SpeakingPace,
        enabledFillers: Set<String>?,
        fillersEnabled: Bool,
        powerPauseCount: Int,
        totalSilenceDuration: TimeInterval,
        averagePauseDuration: TimeInterval
    ) -> SpeechAnalysisResult {
        
        let words = countWords(in: transcript)
        let minutes = max(duration / 60.0, 0.01)
        let wordsPerMinute = Double(words) / minutes
        
        // --------------------------------------------------
        // STEP 1: Validate the session BEFORE scoring
        // --------------------------------------------------
        
        let validation = validateSession(
            transcript: transcript,
            duration: duration,
            wordCount: words,
            wordsPerMinute: wordsPerMinute
        )
        
        // --------------------------------------------------
        // If invalid, return ZERO analysis.
        // This prevents fake scores such as 52/100.
        // --------------------------------------------------
        
        guard validation.isValid else {
            
            return SpeechAnalysisResult(
                isValidSession: false,
                validationMessage: validation.message,
                
                totalWords: words,
                wordsPerMinute: wordsPerMinute,
                
                fillerCount: 0,
                fillerWords: [:],
                fillerFrequency: 0,
                
                powerPauses: powerPauseCount,
                totalSilenceDuration: totalSilenceDuration,
                averagePauseDuration: averagePauseDuration,
                pauseRatio: duration > 0
                ? min(
                    max(
                        totalSilenceDuration / duration,
                        0
                    ),
                    1
                )
                : 0,
                pauseFrequency: 0,
                pauseQualityScore: 0,
                
                clarityScore: 0,
                
                paceFeedback: "",
                fillerFeedback: "",
                pauseFeedback: "",
                overallFeedback: ""
            )
        }
        
        // --------------------------------------------------
        // STEP 2: Detect fillers
        // --------------------------------------------------
        
        let detectedFillers: [String: Int]
        
        if fillersEnabled {
            detectedFillers = detectFillerWords(
                in: transcript,
                enabledFillers: enabledFillers
            )
        } else {
            detectedFillers = [:]
        }
        
        let fillerCount =
        detectedFillers.values.reduce(0, +)
        
        let fillerFrequency =
        words > 0
        ? Double(fillerCount)
        / Double(words)
        * 100
        : 0
        
        // --------------------------------------------------
        // STEP 3: Pause analysis
        // --------------------------------------------------
        
        let pauseCount = powerPauseCount
        let safeDuration = max(duration, 0.1)
        
        let pauseRatio = min(
            max(
                totalSilenceDuration / safeDuration,
                0
            ),
            1
        )
        
        let pauseFrequency = duration >= 60
        ? Double(pauseCount) / minutes
        : (
            pauseCount > 0
            ? Double(pauseCount) / minutes
            : 0
        )
        
        let pauseQualityScore =
        calculatePauseQualityScore(
            pauseRatio: pauseRatio,
            averagePauseDuration:
                averagePauseDuration,
            pauseFrequency:
                pauseFrequency,
            pauseCount:
                pauseCount
        )
        
        // --------------------------------------------------
        // STEP 4: Overall score
        // --------------------------------------------------
        
        let clarityScore =
        calculateClarityScore(
            wordsPerMinute:
                wordsPerMinute,
            fillerFrequency:
                fillerFrequency,
            pauseQualityScore:
                pauseQualityScore,
            transcript:
                transcript,
            speakingPace:
                speakingPace
        )
        
        // --------------------------------------------------
        // STEP 5: Feedback
        // --------------------------------------------------
        
        let paceFeedback =
        generatePaceFeedback(
            wordsPerMinute:
                wordsPerMinute,
            speakingPace:
                speakingPace
        )
        
        let fillerFeedback =
        generateFillerFeedback(
            fillerCount:
                fillerCount,
            fillerFrequency:
                fillerFrequency,
            fillerWords:
                detectedFillers
        )
        
        let pauseFeedback =
        generatePauseFeedback(
            pauseRatio:
                pauseRatio,
            averagePauseDuration:
                averagePauseDuration,
            pauseFrequency:
                pauseFrequency,
            pauseQualityScore:
                pauseQualityScore
        )
        
        let overallFeedback =
        generateOverallFeedback(
            score:
                clarityScore,
            paceScore:
                calculatePaceScore(
                    wordsPerMinute:
                        wordsPerMinute,
                    target:
                        speakingPace.targetRange
                ),
            fillerFrequency:
                fillerFrequency,
            pauseQualityScore:
                pauseQualityScore
        )
        
        return SpeechAnalysisResult(
            isValidSession: true,
            validationMessage: "",
            
            totalWords: words,
            wordsPerMinute: wordsPerMinute,
            
            fillerCount: fillerCount,
            fillerWords: detectedFillers,
            fillerFrequency: fillerFrequency,
            
            powerPauses: pauseCount,
            totalSilenceDuration:
                totalSilenceDuration,
            averagePauseDuration:
                averagePauseDuration,
            pauseRatio:
                pauseRatio,
            pauseFrequency:
                pauseFrequency,
            pauseQualityScore:
                pauseQualityScore,
            
            clarityScore:
                clarityScore,
            
            paceFeedback:
                paceFeedback,
            fillerFeedback:
                fillerFeedback,
            pauseFeedback:
                pauseFeedback,
            overallFeedback:
                overallFeedback
        )
    }
    
    // MARK: - Session Validation
    
    private func validateSession(
        transcript: String,
        duration: TimeInterval,
        wordCount: Int,
        wordsPerMinute: Double
    ) -> (
        isValid: Bool,
        message: String
    ) {
        
        if wordCount == 0 {
            return (
                false,
                "Cadence didn't detect any meaningful speech."
            )
        }
        
        // Very tiny recognition results should not receive
        // a score.
        if wordCount < 10 {
            return (
                false,
                "There wasn't enough speech to analyze your delivery."
            )
        }
        
        // A long session with only a few words is effectively
        // a mostly silent session.
        if duration >= 30 && wordsPerMinute < 20 {
            return (
                false,
                "There wasn't enough continuous speech to analyze your delivery."
            )
        }
        
        // Extremely slow recognition output is generally not
        // enough for a meaningful speaking analysis.
        if duration >= 15 && wordsPerMinute < 10 {
            return (
                false,
                "Cadence didn't detect enough meaningful speech to evaluate your delivery."
            )
        }
        
        return (true, "")
    }
    
    // MARK: - Word Counting
    
    private func countWords(
        in text: String
    ) -> Int {
        
        text.split {
            $0.isWhitespace ||
            $0.isNewline
        }.count
    }
    
    // MARK: - Filler Detection
    
    private func detectFillerWords(
        in text: String,
        enabledFillers: Set<String>?
    ) -> [String: Int] {
        
        let normalized =
        text
            .lowercased()
            .replacingOccurrences(
                of: "’",
                with: "'"
            )
        
        let tokens =
        tokenize(normalized)
        
        var counts: [String: Int] = [:]
        
        let enabled =
        enabledFillers
        ?? Set(
            FillerWord.allCases.map {
                $0.rawValue
            }
        )
        
        var index = 0
        
        while index < tokens.count {
            
            let current =
            tokens[index].word
            
            // ----------------------------------------------
            // "you know"
            // ----------------------------------------------
            
            if current == "you",
               index + 1 < tokens.count,
               tokens[index + 1].word == "know",
               enabled.contains("you know") {
                
                let previous =
                index > 0
                ? tokens[index - 1].word
                : nil
                
                let next =
                index + 2 < tokens.count
                ? tokens[index + 2].word
                : nil
                
                if isLikelyYouKnowFiller(
                    previous: previous,
                    next: next
                ) {
                    counts[
                        "you know",
                        default: 0
                    ] += 1
                }
                
                index += 2
                continue
            }
            
            // ----------------------------------------------
            // "um" / "uh"
            // ----------------------------------------------
            
            if current == "um" ||
                current == "uh" {
                
                guard enabled.contains(current) else {
                    index += 1
                    continue
                }
                
                counts[
                    current,
                    default: 0
                ] += 1
                
                index += 1
                continue
            }
            
            // ----------------------------------------------
            // "like"
            // ----------------------------------------------
            
            if current == "like" {
                
                if enabled.contains("like") &&
                    isLikelyLikeFiller(
                        tokens: tokens,
                        index: index
                    ) {
                    
                    counts[
                        "like",
                        default: 0
                    ] += 1
                }
                
                index += 1
                continue
            }
            
            // ----------------------------------------------
            // "so"
            // ----------------------------------------------
            
            if current == "so" {
                
                if enabled.contains("so") &&
                    isLikelySoFiller(
                        tokens: tokens,
                        index: index
                    ) {
                    
                    counts[
                        "so",
                        default: 0
                    ] += 1
                }
                
                index += 1
                continue
            }
            
            // ----------------------------------------------
            // "basically"
            // ----------------------------------------------
            
            if current == "basically" {
                
                if enabled.contains("basically") &&
                    isLikelyStandaloneFiller(
                        tokens: tokens,
                        index: index
                    ) {
                    
                    counts[
                        "basically",
                        default: 0
                    ] += 1
                }
                
                index += 1
                continue
            }
            
            // ----------------------------------------------
            // "literally"
            // ----------------------------------------------
            
            if current == "literally" {
                
                if enabled.contains("literally") &&
                    isLikelyStandaloneFiller(
                        tokens: tokens,
                        index: index
                    ) {
                    
                    counts[
                        "literally",
                        default: 0
                    ] += 1
                }
                
                index += 1
                continue
            }
            
            index += 1
        }
        
        return counts
    }
    
    // MARK: - Tokenization
    
    private struct SpeechToken {
        let word: String
        let hadCommaBefore: Bool
        let hadCommaAfter: Bool
    }
    
    private func tokenize(
        _ text: String
    ) -> [SpeechToken] {
        
        let pattern =
        #"([A-Za-z']+)(\s*,)?(\s*)?"#
        
        guard let regex =
                try? NSRegularExpression(
                    pattern: pattern
                )
        else {
            return text
                .split {
                    $0.isWhitespace
                }
                .map {
                    SpeechToken(
                        word:
                            $0
                            .lowercased()
                            .trimmingCharacters(
                                in:
                                        .punctuationCharacters
                            ),
                        hadCommaBefore: false,
                        hadCommaAfter: false
                    )
                }
        }
        
        let nsText = text as NSString
        
        let matches =
        regex.matches(
            in: text,
            range:
                NSRange(
                    location: 0,
                    length: nsText.length
                )
        )
        
        var result: [SpeechToken] = []
        
        for match in matches {
            
            guard
                let wordRange =
                    Range(
                        match.range(
                            at: 1
                        ),
                        in: text
                    )
            else {
                continue
            }
            
            let word =
            String(
                text[wordRange]
            )
            
            let matchEnd =
            match.range.location
            + match.range.length
            
            let nextCharacter: String?
            
            if matchEnd < nsText.length {
                nextCharacter =
                nsText.substring(
                    with:
                        NSRange(
                            location:
                                matchEnd,
                            length: 1
                        )
                )
            } else {
                nextCharacter = nil
            }
            
            let previousCharacter: String?
            
            if match.range.location > 0 {
                previousCharacter =
                nsText.substring(
                    with:
                        NSRange(
                            location:
                                match.range.location - 1,
                            length: 1
                        )
                )
            } else {
                previousCharacter = nil
            }
            
            result.append(
                SpeechToken(
                    word: word,
                    hadCommaBefore:
                        previousCharacter == ",",
                    hadCommaAfter:
                        nextCharacter == ","
                )
            )
        }
        
        return result
    }
    
    // MARK: - LIKE Detection
    
    private func isLikelyLikeFiller(
        tokens: [SpeechToken],
        index: Int
    ) -> Bool {
        
        let previous =
        index > 0
        ? tokens[index - 1].word
        : nil
        
        let next =
        index + 1 < tokens.count
        ? tokens[index + 1].word
        : nil
        
        let previousTwo =
        index > 1
        ? tokens[index - 2].word
        : nil
        _ =
        index > 2
        ? tokens[index - 3].word
        : nil
        
        // --------------------------------------------------
        // 1. "what is it like..."
        //    "what is life like..."
        //    "what does it look like..."
        // --------------------------------------------------
        
        if previous == "it" &&
            previousTwo == "is" {
            return false
        }
        
        if previous == "it" &&
            previousTwo == "was" {
            return false
        }
        
        if previous == "life" ||
            previous == "someone" ||
            previous == "something" {
            
            if previousTwo == "is" ||
                previousTwo == "was" ||
                previousTwo == "looks" ||
                previousTwo == "looked" {
                return false
            }
        }
        
        // --------------------------------------------------
        // 2. Question patterns:
        //
        // "what is it like"
        // "what was it like"
        // "what are they like"
        // "what is that like"
        // --------------------------------------------------
        
        if previous == "it" ||
            previous == "that" ||
            previous == "this" ||
            previous == "they" ||
            previous == "he" ||
            previous == "she" {
            
            if previousTwo == "is" ||
                previousTwo == "was" ||
                previousTwo == "are" ||
                previousTwo == "were" {
                return false
            }
        }
        
        // --------------------------------------------------
        // 3. Normal verb "like"
        //
        // "I like pizza"
        // "I like this"
        // "people like you"
        // --------------------------------------------------
        
        let normalLikeSubjects: Set<String> = [
            "i",
            "we",
            "you",
            "they",
            "people",
            "everyone",
            "someone",
            "he",
            "she"
        ]
        
        if let previous,
           normalLikeSubjects.contains(previous) {
            
            return false
        }
        
        // --------------------------------------------------
        // 4. "looks like..."
        // "sounds like..."
        // "feels like..."
        // "smells like..."
        // --------------------------------------------------
        
        let comparisonVerbs: Set<String> = [
            "look",
            "looks",
            "looked",
            "looking",
            "sound",
            "sounds",
            "sounded",
            "feels",
            "feel",
            "felt",
            "seems",
            "seem",
            "seemed",
            "smells",
            "smell",
            "smelled",
            "tastes",
            "taste",
            "tasted"
        ]
        
        if let previous,
           comparisonVerbs.contains(previous) {
            return false
        }
        
        // --------------------------------------------------
        // 5. "felt like..."
        // "I felt like I couldn't..."
        // --------------------------------------------------
        
        if previous == "felt" ||
            previous == "feel" ||
            previous == "feels" {
            return false
        }
        
        // --------------------------------------------------
        // 6. "would like..."
        // "I would like..."
        // --------------------------------------------------
        
        if previous == "would" ||
            previous == "could" ||
            previous == "should" {
            return false
        }
        
        // --------------------------------------------------
        // 7. "people like you"
        // "things like this"
        // --------------------------------------------------
        
        let pluralOrObjectWords: Set<String> = [
            "people",
            "things",
            "places",
            "ideas",
            "questions",
            "words",
            "examples",
            "situations",
            "problems"
        ]
        
        if let previous,
           pluralOrObjectWords.contains(previous) {
            return false
        }
        
        // --------------------------------------------------
        // 8. Comma-separated "like"
        //
        // "I was, like, really nervous."
        // "It was, like, impossible."
        //
        // This is a strong filler signal.
        // --------------------------------------------------
        
        if tokens[index].hadCommaBefore ||
            tokens[index].hadCommaAfter {
            return true
        }
        
        // --------------------------------------------------
        // 9. Classic conversational filler patterns
        //
        // "I was like really nervous."
        // "It was like very difficult."
        // --------------------------------------------------
        
        let fillerIntroducers: Set<String> = [
            "was",
            "were",
            "am",
            "is",
            "are",
            "just",
            "really",
            "actually",
            "basically"
        ]
        
        if let previous,
           fillerIntroducers.contains(previous) {
            
            let adjectiveLikeWords: Set<String> = [
                "really",
                "very",
                "so",
                "just",
                "actually",
                "kind",
                "pretty",
                "extremely",
                "quite",
                "totally",
                "completely"
            ]
            
            if let next,
               adjectiveLikeWords.contains(next) {
                return true
            }
        }
        
        // --------------------------------------------------
        // 10. Default
        //
        // We are conservative. If context doesn't strongly
        // suggest a filler, don't count it.
        // --------------------------------------------------
        
        return false
    }
    
    // MARK: - SO Detection
    
    private func isLikelySoFiller(
        tokens: [SpeechToken],
        index: Int
    ) -> Bool {
        
        let next =
        index + 1 < tokens.count
        ? tokens[index + 1].word
        : nil
        
        let previous =
        index > 0
        ? tokens[index - 1].word
        : nil
        
        // "so much", "so many", "so good", etc.
        let normalSoWords: Set<String> = [
            "much",
            "many",
            "good",
            "bad",
            "fast",
            "slow",
            "important",
            "different",
            "easy",
            "hard",
            "far",
            "long",
            "quickly",
            "well",
            "happy",
            "sad",
            "beautiful",
            "interesting",
            "difficult",
            "simple"
        ]
        
        if let next,
           normalSoWords.contains(next) {
            return false
        }
        
        // "and so on"
        if next == "on" {
            return false
        }
        
        // "so that"
        if next == "that" {
            return false
        }
        
        // "so I", "so we", "so you" can be a normal
        // conjunction introducing the next thought.
        let pronouns: Set<String> = [
            "i",
            "we",
            "you",
            "he",
            "she",
            "they"
        ]
        
        if let next,
           pronouns.contains(next) {
            
            if previous == "and" {
                return false
            }
            
            // Sentence-opening "so I..." is usually a
            // discourse transition rather than a filler.
            if index == 0 {
                return false
            }
        }
        
        // "So, ..." is commonly used as a transition.
        // We don't automatically call every "so" a filler.
        if tokens[index].hadCommaAfter {
            return false
        }
        
        return false
    }
    
    // MARK: - You Know
    
    private func isLikelyYouKnowFiller(
        previous: String?,
        next: String?
    ) -> Bool {
        
        if next == "how" ||
            next == "what" ||
            next == "why" ||
            next == "where" ||
            next == "when" {
            return false
        }
        
        if previous == "if" ||
            previous == "when" ||
            previous == "because" ||
            previous == "unless" {
            return false
        }
        
        return true
    }
    
    // MARK: - Basically / Literally
    
    private func isLikelyStandaloneFiller(
        tokens: [SpeechToken],
        index: Int
    ) -> Bool {
        
        if index == 0 {
            return true
        }
        
        let previous =
        tokens[index - 1].word
        
        let transitionWords: Set<String> = [
            "and",
            "but",
            "well",
            "okay",
            "actually",
            "anyway"
        ]
        
        if transitionWords.contains(previous) {
            return true
        }
        
        return true
    }
    
    // MARK: - Pace
    
    private func calculatePaceScore(
        wordsPerMinute: Double,
        target: ClosedRange<Double>
    ) -> Double {
        
        guard wordsPerMinute > 0 else {
            return 0
        }
        
        if target.contains(wordsPerMinute) {
            return 100
        }
        
        if wordsPerMinute < target.lowerBound {
            let difference =
            target.lowerBound
            - wordsPerMinute
            
            return max(
                0,
                100 - difference * 1.2
            )
        }
        
        let difference =
        wordsPerMinute
        - target.upperBound
        
        return max(
            0,
            100 - difference * 1.2
        )
    }
    
    // MARK: - Filler Score
    
    private func calculateFillerScore(
        fillerFrequency: Double
    ) -> Double {
        
        switch fillerFrequency {
        case 0:
            return 100
        case 0..<1:
            return 95
        case 1..<2:
            return 88
        case 2..<3:
            return 78
        case 3..<5:
            return 65
        case 5..<8:
            return 50
        default:
            return 30
        }
    }
    
    // MARK: - Pause Quality
    
    private func calculatePauseQualityScore(
        pauseRatio: Double,
        averagePauseDuration: TimeInterval,
        pauseFrequency: Double,
        pauseCount: Int
    ) -> Double {
        
        guard pauseCount > 0 else {
            return 72
        }
        
        let ratioScore: Double
        
        switch pauseRatio {
        case 0.18...0.35:
            ratioScore = 100
        case 0.15..<0.18:
            ratioScore = 95
        case 0.12..<0.15:
            ratioScore = 88
        case 0.08..<0.12:
            ratioScore = 75
        case 0..<0.08:
            ratioScore =
            75 * (pauseRatio / 0.08)
        case 0.35..<0.40:
            ratioScore = 92
        case 0.40..<0.45:
            ratioScore = 80
        case 0.45..<0.50:
            ratioScore = 68
        case 0.50..<0.60:
            ratioScore = 52
        default:
            ratioScore = 35
        }
        
        let durationScore: Double
        
        switch averagePauseDuration {
        case 0.4..<1.0:
            durationScore = 100
        case 1.0..<1.5:
            durationScore = 95
        case 1.5..<2.0:
            durationScore = 88
        case 2.0..<3.0:
            durationScore = 72
        case 3.0..<4.0:
            durationScore = 55
        case 4.0...:
            durationScore = 35
        default:
            durationScore = 60
        }
        
        let frequencyScore: Double
        
        switch pauseFrequency {
        case 2...10:
            frequencyScore = 100
        case 1..<2:
            frequencyScore = 90
        case 0..<1:
            frequencyScore = 75
        case 10..<15:
            frequencyScore = 88
        case 15..<20:
            frequencyScore = 70
        default:
            frequencyScore = 50
        }
        
        return min(
            max(
                ratioScore * 0.50
                + durationScore * 0.30
                + frequencyScore * 0.20,
                0
            ),
            100
        )
    }
    
    // MARK: - Overall Score
    
    private func calculateClarityScore(
        wordsPerMinute: Double,
        fillerFrequency: Double,
        pauseQualityScore: Double,
        transcript: String,
        speakingPace: SpeakingPace
    ) -> Double {
        
        let fillerScore =
        calculateFillerScore(
            fillerFrequency:
                fillerFrequency
        )
        
        let paceScore =
        calculatePaceScore(
            wordsPerMinute:
                wordsPerMinute,
            target:
                speakingPace.targetRange
        )
        
        let consistencyScore =
        calculateConsistencyScore(
            transcript:
                transcript
        )
        
        let fluencyScore =
        calculateFluencyScore(
            transcript:
                transcript
        )
        
        let score =
        fillerScore * 0.30
        + paceScore * 0.30
        + pauseQualityScore * 0.15
        + consistencyScore * 0.15
        + fluencyScore * 0.10
        
        return min(
            max(score, 0),
            100
        )
    }
    
    private func calculateConsistencyScore(
        transcript: String
    ) -> Double {
        
        let words =
        transcript.split {
            $0.isWhitespace ||
            $0.isNewline
        }
        
        guard words.count >= 10 else {
            return 70
        }
        
        let sentences =
        transcript
            .components(
                separatedBy:
                    CharacterSet(
                        charactersIn:
                            ".!?"
                    )
            )
            .map {
                $0.split {
                    $0.isWhitespace ||
                    $0.isNewline
                }.count
            }
            .filter {
                $0 > 0
            }
        
        guard sentences.count >= 2 else {
            return 80
        }
        
        let values =
        sentences.map(Double.init)
        
        let mean =
        values.reduce(0, +)
        / Double(values.count)
        
        guard mean > 0 else {
            return 80
        }
        
        let variance =
        values
            .map {
                pow($0 - mean, 2)
            }
            .reduce(0, +)
        / Double(values.count)
        
        let standardDeviation =
        sqrt(variance)
        
        let coefficient =
        standardDeviation / mean
        
        if coefficient < 0.35 {
            return 100
        }
        
        if coefficient < 0.50 {
            return 90
        }
        
        if coefficient < 0.70 {
            return 78
        }
        
        if coefficient < 1.0 {
            return 65
        }
        
        return 50
    }
    
    private func calculateFluencyScore(
        transcript: String
    ) -> Double {
        
        let words =
        transcript.split {
            $0.isWhitespace ||
            $0.isNewline
        }
        
        guard !words.isEmpty else {
            return 0
        }
        
        let punctuationCount =
        transcript.filter {
            ".!?,;:".contains($0)
        }.count
        
        let punctuationRate =
        Double(punctuationCount)
        / Double(words.count)
        
        if punctuationRate < 0.03 {
            return 72
        }
        
        if punctuationRate < 0.08 {
            return 88
        }
        
        if punctuationRate < 0.18 {
            return 100
        }
        
        if punctuationRate < 0.30 {
            return 92
        }
        
        return 80
    }
    
    // MARK: - Feedback
    
    private func generatePaceFeedback(
        wordsPerMinute: Double,
        speakingPace: SpeakingPace
    ) -> String {
        
        let range =
        speakingPace.targetRange
        
        if range.contains(wordsPerMinute) {
            return String(
                format:
                    "Your pace is right in your target range at %.0f WPM.",
                wordsPerMinute
            )
        }
        
        if wordsPerMinute < range.lowerBound {
            return String(
                format:
                    "You're speaking a little slowly at %.0f WPM. Try keeping your delivery slightly more continuous.",
                wordsPerMinute
            )
        }
        
        return String(
            format:
                "You're speaking quickly at %.0f WPM. Try slowing down slightly and giving important ideas more space.",
            wordsPerMinute
        )
    }
    
    private func generateFillerFeedback(
        fillerCount: Int,
        fillerFrequency: Double,
        fillerWords: [String: Int]
    ) -> String {
        
        guard fillerCount > 0 else {
            return "Excellent — no noticeable filler words were detected."
        }
        
        let mostCommon =
        fillerWords.max {
            $0.value < $1.value
        }
        
        let commonName =
        mostCommon?.key
        ?? "filler words"
        
        if fillerFrequency < 1 {
            return String(
                format:
                    "Very good filler control. You used %d filler word%@, with \"%@\" appearing most often.",
                fillerCount,
                fillerCount == 1
                ? ""
                : "s",
                commonName
            )
        }
        
        if fillerFrequency < 3 {
            return String(
                format:
                    "Your filler usage is fairly low, but \"%@\" is worth watching.",
                commonName
            )
        }
        
        if fillerFrequency < 5 {
            return String(
                format:
                    "You're using fillers fairly often. \"%@\" appears most frequently. Try replacing it with a short pause.",
                commonName
            )
        }
        
        return String(
            format:
                "Filler usage is high. \"%@\" is your most common filler. Slow down and replace fillers with intentional pauses.",
            commonName
        )
    }
    
    private func generatePauseFeedback(
        pauseRatio: Double,
        averagePauseDuration: TimeInterval,
        pauseFrequency: Double,
        pauseQualityScore: Double
    ) -> String {
        
        let percentage =
        pauseRatio * 100
        
        if pauseQualityScore >= 90 {
            return String(
                format:
                    "Great use of pauses — about %.0f%% of your speaking time was silent, with pauses averaging %.1f seconds.",
                percentage,
                averagePauseDuration
            )
        }
        
        if pauseRatio < 0.12 {
            return String(
                format:
                    "You're leaving very little space between ideas. Your silent time was only %.0f%%. Try adding short intentional pauses.",
                percentage
            )
        }
        
        if pauseRatio >= 0.40 {
            return String(
                format:
                    "Your pauses are becoming frequent or long. About %.0f%% of your time was silent, so aim for shorter, more intentional pauses.",
                percentage
            )
        }
        
        if averagePauseDuration >= 3.0 {
            return String(
                format:
                    "Some pauses are quite long, averaging %.1f seconds. Try keeping most pauses shorter unless you're intentionally emphasizing an idea.",
                averagePauseDuration
            )
        }
        
        if pauseFrequency > 15 {
            return String(
                format:
                    "You're pausing very frequently — about %.0f pauses per minute. Try combining some shorter pauses into smoother phrases.",
                pauseFrequency
            )
        }
        
        return "Your pauses are generally useful, but there is room to make their timing more consistent."
    }
    
    private func generateOverallFeedback(
        score: Double,
        paceScore: Double,
        fillerFrequency: Double,
        pauseQualityScore: Double
    ) -> String {
        
        if score >= 90 {
            return "Excellent delivery. Your pace, filler control, and pauses are working together very well."
        }
        
        if score >= 80 {
            
            if paceScore < 70 {
                return "Strong overall performance. Your biggest opportunity is improving your speaking pace."
            }
            
            if fillerFrequency >= 3 {
                return "Strong overall performance. Reducing filler words would make your delivery noticeably cleaner."
            }
            
            if pauseQualityScore < 70 {
                return "Strong overall performance. Work on making your pauses shorter and more intentional."
            }
            
            return "Very solid delivery. A few small improvements could make your speech even clearer."
        }
        
        if score >= 70 {
            
            if fillerFrequency >= 5 {
                return "Your main focus should be reducing filler words. Replace them with short, intentional pauses."
            }
            
            if paceScore < 65 {
                return "Your main focus should be your speaking pace. Aim for a steadier, more controlled rhythm."
            }
            
            if pauseQualityScore < 65 {
                return "Your main focus should be pause control. Try to make pauses deliberate rather than hesitant."
            }
            
            return "You're building a good foundation. Focus on consistency and controlled delivery."
        }
        
        return "There is plenty of room to improve, which is completely normal. Focus on one area at a time — pace, fillers, and intentional pauses."
    }
}
