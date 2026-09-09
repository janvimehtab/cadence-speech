import SwiftUI

struct SessionDetailView: View {
    
    let session: SpeechSession
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                scoreSection
                
                mainStats
                
                pauseSection
                
                fillerSection
                
                transcriptSection
            }
            .padding(.vertical)
        }
        .navigationTitle("Session")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Score
    
    private var scoreSection: some View {
        VStack(spacing: 10) {
            
            ZStack {
                
                Circle()
                    .stroke(
                        .quaternary,
                        lineWidth: 12
                    )
                
                Circle()
                    .trim(
                        from: 0,
                        to: min(
                            max(
                                session.clarityScore / 100,
                                0
                            ),
                            1
                        )
                    )
                    .stroke(
                        .primary,
                        style: StrokeStyle(
                            lineWidth: 12,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(
                        .degrees(-90)
                    )
                
                VStack(spacing: 2) {
                    
                    Text(
                        "\(Int(session.clarityScore))"
                    )
                    .font(
                        .system(
                            size: 38,
                            weight: .bold
                        )
                    )
                    
                    Text("/100")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(
                width: 140,
                height: 140
            )
            
            Text(scoreTitle)
                .font(.headline)
            
            Text(
                session.date.formatted(
                    date: .long,
                    time: .shortened
                )
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding()
    }
    
    // MARK: - Main Stats
    
    private var mainStats: some View {
        HStack(spacing: 10) {
            
            stat(
                title: "Duration",
                value: formattedDuration,
                icon: "timer"
            )
            
            stat(
                title: "Words",
                value: "\(session.totalWords)",
                icon: "text.word.spacing"
            )
            
            stat(
                title: "WPM",
                value: "\(Int(session.wordsPerMinute))",
                icon: "speedometer"
            )
        }
        .padding(.horizontal)
    }
    
    // MARK: - Pause Section
    
    private var pauseSection: some View {
        VStack(
            alignment: .leading,
            spacing: 14
        ) {
            
            Text("Pause Analysis")
                .font(.headline)
            
            detailRow(
                title: "Pause Quality",
                value:
                    "\(Int(session.pauseQualityScore))/100"
            )
            
            detailRow(
                title: "Pauses",
                value:
                    "\(session.powerPauseCount)"
            )
            
            detailRow(
                title: "Silent Time",
                value:
                    String(
                        format:
                            "%.0f%%",
                        session.pauseRatio * 100
                    )
            )
            
            detailRow(
                title: "Average Pause",
                value:
                    String(
                        format:
                            "%.1f seconds",
                        session.averagePauseDuration
                    )
            )
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 20
            )
        )
        .padding(.horizontal)
    }
    
    // MARK: - Filler Section
    
    private var fillerSection: some View {
        VStack(
            alignment: .leading,
            spacing: 14
        ) {
            
            Text("Filler Words")
                .font(.headline)
            
            HStack {
                
                Text(
                    "\(session.fillerCount)"
                )
                .font(.title2)
                .fontWeight(.bold)
                
                Text("detected")
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
            
            if session.fillerWordCounts.isEmpty {
                
                Text(
                    "No filler words detected."
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
                
            } else {
                
                ForEach(
                    session.fillerWordCounts.sorted {
                        $0.value > $1.value
                    },
                    id: \.key
                ) { item in
                    
                    HStack {
                        
                        Text(
                            item.key.capitalized
                        )
                        
                        Spacer()
                        
                        Text(
                            "\(item.value)"
                        )
                        .fontWeight(.semibold)
                    }
                    
                    Divider()
                }
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 20
            )
        )
        .padding(.horizontal)
    }
    
    // MARK: - Transcript
    
    private var transcriptSection: some View {
        VStack(
            alignment: .leading,
            spacing: 10
        ) {
            
            Text("Transcript")
                .font(.headline)
            
            if session.transcript.isEmpty {
                
                Text(
                    "No transcript was captured."
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
                
            } else {
                
                Text(session.transcript)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
            }
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding()
        .background(.thinMaterial)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 20
            )
        )
        .padding(.horizontal)
    }
    
    // MARK: - Helpers
    
    private func stat(
        title: String,
        value: String,
        icon: String
    ) -> some View {
        
        VStack(spacing: 7) {
            
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.thinMaterial)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 14
            )
        )
    }
    
    private func detailRow(
        title: String,
        value: String
    ) -> some View {
        
        HStack {
            
            Text(title)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.semibold)
        }
        .font(.subheadline)
    }
    
    private var formattedDuration: String {
        
        let totalSeconds =
        Int(session.duration)
        
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
    
    private var scoreTitle: String {
        
        switch session.clarityScore {
        case 90...:
            return "Excellent Delivery"
        case 80..<90:
            return "Strong Delivery"
        case 70..<80:
            return "Good Foundation"
        case 60..<70:
            return "Room to Improve"
        default:
            return "Keep Practicing"
        }
    }
}
