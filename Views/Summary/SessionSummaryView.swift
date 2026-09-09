import SwiftUI

struct SessionSummaryView: View {
    
    // MARK: - Session Data
    
    let transcript: String
    
    let duration: TimeInterval
    let wordCount: Int
    let fillerCount: Int
    let powerPauses: Int
    let wordsPerMinute: Double
    let clarityScore: Double
    
    let fillerWords: [String: Int]
    let fillerFrequency: Double
    
    let pauseQualityScore: Double
    let pauseRatio: Double
    let averagePauseDuration: TimeInterval
    let pauseFrequency: Double
    
    let paceFeedback: String
    let fillerFeedback: String
    let pauseFeedback: String
    let overallFeedback: String
    
    let isValidSession: Bool
    let validationMessage: String
    
    let topic: String
    
    @Environment(\.dismiss)
    private var dismiss
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if isValidSession {
                    validSummary
                } else {
                    invalidSummary
                }
            }
            .navigationTitle("Session Results")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(
                    placement: .topBarTrailing
                ) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Valid Summary
    
    private var validSummary: some View {
        VStack(spacing: 22) {
            
            scoreHeader
            
            topicCard
            
            performanceSection
            
            pauseSection
            
            feedbackSection
            
            doneButton
        }
        .padding()
    }
    
    // MARK: - Score Header
    
    private var scoreHeader: some View {
        VStack(spacing: 10) {
            
            ZStack {
                
                Circle()
                    .stroke(
                        .quaternary,
                        lineWidth: 10
                    )
                    .frame(
                        width: 150,
                        height: 150
                    )
                
                Circle()
                    .trim(
                        from: 0,
                        to: scoreProgress
                    )
                    .stroke(
                        .primary,
                        style: StrokeStyle(
                            lineWidth: 10,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(
                        .degrees(-90)
                    )
                    .frame(
                        width: 150,
                        height: 150
                    )
                
                VStack(spacing: 0) {
                    
                    Text(
                        "\(Int(clarityScore))"
                    )
                    .font(
                        .system(
                            size: 40,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    
                    Text("SCORE")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                }
            }
            
            Text(scoreTitle)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(
                "Your speaking performance for this challenge"
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
        }
        .padding(.top, 12)
    }
    
    private var scoreProgress: Double {
        min(
            max(
                clarityScore / 100,
                0
            ),
            1
        )
    }
    
    private var scoreTitle: String {
        switch clarityScore {
        case 90...:
            return "Excellent work"
        case 80..<90:
            return "Great work"
        case 70..<80:
            return "Good work"
        case 60..<70:
            return "Solid start"
        default:
            return "Room to improve"
        }
    }
    
    // MARK: - Topic
    
    private var topicCard: some View {
        VStack(
            alignment: .leading,
            spacing: 9
        ) {
            
            Text("TOPIC")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
                .tracking(1)
            
            Text(topic)
                .font(.headline)
            
            Text(
                "Your score measures speaking performance, not whether your answer or opinion was correct."
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding(18)
        .background(.thinMaterial)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 18
            )
        )
    }
    
    // MARK: - Performance
    
    private var performanceSection: some View {
        VStack(
            alignment: .leading,
            spacing: 12
        ) {
            
            Text("PERFORMANCE")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
                .tracking(1)
            
            HStack(spacing: 10) {
                
                summaryStat(
                    title: "Words",
                    value: "\(wordCount)",
                    suffix: "",
                    icon: "text.word.spacing"
                )
                
                summaryStat(
                    title: "Pace",
                    value: "\(Int(wordsPerMinute))",
                    suffix: " WPM",
                    icon: "speedometer"
                )
                
                summaryStat(
                    title: "Fillers",
                    value: "\(fillerCount)",
                    suffix: "",
                    icon: "bubble.left"
                )
            }
        }
    }
    
    // MARK: - Pause Section
    
    private var pauseSection: some View {
        VStack(
            alignment: .leading,
            spacing: 14
        ) {
            
            HStack {
                
                Text("PAUSE QUALITY")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                    .tracking(1)
                
                Spacer()
                
                Text(
                    "\(Int(pauseQualityScore))/100"
                )
                .font(.headline)
                .fontWeight(.bold)
            }
            
            HStack(spacing: 8) {
                
                pauseStat(
                    title: "Pauses",
                    value: "\(powerPauses)"
                )
                
                pauseStat(
                    title: "Silent",
                    value:
                        "\(Int(pauseRatio * 100))%"
                )
                
                pauseStat(
                    title: "Average",
                    value:
                        String(
                            format: "%.1fs",
                            averagePauseDuration
                        )
                )
                
                pauseStat(
                    title: "Per min",
                    value:
                        String(
                            format: "%.1f",
                            pauseFrequency
                        )
                )
            }
            
            if !pauseFeedback.isEmpty {
                Text(pauseFeedback)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding(18)
        .background(.thinMaterial)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 18
            )
        )
    }
    
    // MARK: - Feedback
    
    private var feedbackSection: some View {
        VStack(
            alignment: .leading,
            spacing: 14
        ) {
            
            Text("FEEDBACK")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
                .tracking(1)
            
            feedbackCard(
                icon: "speedometer",
                title: "Pace",
                text: paceFeedback
            )
            
            feedbackCard(
                icon: "bubble.left",
                title: "Fillers",
                text: fillerFeedback
            )
            
            feedbackCard(
                icon: "pause.circle",
                title: "Pauses",
                text: pauseFeedback
            )
            
            feedbackCard(
                icon: "sparkles",
                title: "Overall",
                text: overallFeedback
            )
            
            if !fillerWords.isEmpty {
                fillerBreakdown
            }
        }
    }
    
    private func feedbackCard(
        icon: String,
        title: String,
        text: String
    ) -> some View {
        
        HStack(
            alignment: .top,
            spacing: 12
        ) {
            
            Image(systemName: icon)
                .font(.headline)
                .frame(
                    width: 34,
                    height: 34
                )
                .background(.quaternary)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 9
                    )
                )
            
            VStack(
                alignment: .leading,
                spacing: 4
            ) {
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(
                    text.isEmpty
                    ? "No additional feedback."
                    : text
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Filler Breakdown
    
    private var fillerBreakdown: some View {
        let sortedFillers =
        fillerWords.sorted {
            $0.value > $1.value
        }
        
        return VStack(
            alignment: .leading,
            spacing: 10
        ) {
            
            Text("FILLER BREAKDOWN")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
                .tracking(1)
            
            ForEach(
                sortedFillers,
                id: \.key
            ) { item in
                
                HStack {
                    
                    Text(item.key)
                        .font(.subheadline)
                    
                    Spacer()
                    
                    Text("\(item.value)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                if item.key != sortedFillers.last?.key {
                    Divider()
                }
            }
        }
        .padding(18)
        .background(
            .quaternary.opacity(0.5)
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 18
            )
        )
    }
    
    // MARK: - Invalid Summary
    
    private var invalidSummary: some View {
        VStack(spacing: 24) {
            
            Spacer(minLength: 30)
            
            ZStack {
                
                Circle()
                    .fill(.quaternary)
                    .frame(
                        width: 110,
                        height: 110
                    )
                
                Image(
                    systemName: "mic.slash.fill"
                )
                .font(.system(size: 42))
            }
            
            VStack(spacing: 10) {
                
                Text("Not Enough Speech")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(
                    "Cadence couldn't produce a reliable analysis for this session."
                )
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            }
            
            VStack(
                alignment: .leading,
                spacing: 10
            ) {
                
                Text("WHY?")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                    .tracking(1)
                
                Text(
                    validationMessage
                )
                .font(.subheadline)
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .padding(18)
            .background(.thinMaterial)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 18
                )
            )
            
            topicCard
            
            VStack(spacing: 8) {
                
                Label(
                    "Try again",
                    systemImage: "arrow.clockwise"
                )
                .font(.headline)
                
                Text(
                    "Speak continuously and give yourself enough time to develop your thoughts."
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            }
            
            doneButton
            
            Spacer(minLength: 20)
        }
        .padding()
    }
    
    // MARK: - Done
    
    private var doneButton: some View {
        Button {
            dismiss()
        } label: {
            Text("Done")
                .font(.headline)
                .frame(
                    maxWidth: .infinity
                )
                .padding(.vertical, 15)
        }
        .buttonStyle(.borderedProminent)
    }
    
    // MARK: - Small Components
    
    private func summaryStat(
        title: String,
        value: String,
        suffix: String,
        icon: String
    ) -> some View {
        
        VStack(spacing: 6) {
            
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            HStack(
                alignment: .firstTextBaseline,
                spacing: 1
            ) {
                
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                
                if !suffix.isEmpty {
                    Text(suffix)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(
            maxWidth: .infinity
        )
        .padding(.vertical, 13)
        .background(.thinMaterial)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 15
            )
        )
    }
    
    private func pauseStat(
        title: String,
        value: String
    ) -> some View {
        
        VStack(spacing: 4) {
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(
            maxWidth: .infinity
        )
    }
}
