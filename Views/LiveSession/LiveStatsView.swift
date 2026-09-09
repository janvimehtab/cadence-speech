import SwiftUI

struct LiveStatsView: View {
    
    let wordCount: Int
    let wordsPerMinute: Double
    let fillerCount: Int
    let clarityScore: Double
    
    var powerPauses: Int = 0
    var pauseQualityScore: Double = 0
    var pauseRatio: Double = 0
    var averagePauseDuration: TimeInterval = 0
    
    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 12
        ) {
            
            HStack {
                
                Text("Live Analysis")
                    .font(.headline)
                
                Spacer()
                
                if clarityScore > 0 {
                    Text(
                        "\(Int(clarityScore))/100"
                    )
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                }
            }
            
            HStack(spacing: 10) {
                
                statCard(
                    title: "Words",
                    value: "\(wordCount)",
                    icon: "text.word.spacing"
                )
                
                statCard(
                    title: "Pace",
                    value:
                        wordsPerMinute > 0
                    ? "\(Int(wordsPerMinute))"
                    : "—",
                    suffix:
                        wordsPerMinute > 0
                    ? " WPM"
                    : "",
                    icon: "speedometer"
                )
                
                statCard(
                    title: "Fillers",
                    value: "\(fillerCount)",
                    icon: "bubble.left"
                )
            }
            
            HStack(spacing: 10) {
                
                statCard(
                    title: "Pauses",
                    value: "\(powerPauses)",
                    icon: "pause.circle"
                )
                
                statCard(
                    title: "Silent",
                    value:
                        pauseRatio > 0
                    ? "\(Int(pauseRatio * 100))%"
                    : "—",
                    icon: "waveform"
                )
                
                statCard(
                    title: "Clarity",
                    value:
                        clarityScore > 0
                    ? "\(Int(clarityScore))"
                    : "—",
                    icon: "sparkles"
                )
            }
            
            if powerPauses > 0 {
                pauseDetail
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Pause Detail
    
    private var pauseDetail: some View {
        HStack(spacing: 10) {
            
            Image(
                systemName:
                    "pause.circle.fill"
            )
            .foregroundStyle(.secondary)
            
            VStack(
                alignment: .leading,
                spacing: 2
            ) {
                
                Text(
                    String(
                        format:
                            "%.1fs average pause",
                        averagePauseDuration
                    )
                )
                .font(.caption)
                .fontWeight(.semibold)
                
                Text(
                    "\(Int(pauseQualityScore))/100 pause quality"
                )
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(.quaternary.opacity(0.6))
        .clipShape(
            RoundedRectangle(
                cornerRadius: 14
            )
        )
    }
    
    // MARK: - Card
    
    private func statCard(
        title: String,
        value: String,
        suffix: String = "",
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
        .frame(maxWidth: .infinity)
        .padding(.vertical, 13)
        .background(.thinMaterial)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 16
            )
        )
    }
}

#Preview {
    LiveStatsView(
        wordCount: 142,
        wordsPerMinute: 148,
        fillerCount: 3,
        clarityScore: 87,
        powerPauses: 12,
        pauseQualityScore: 92,
        pauseRatio: 0.22,
        averagePauseDuration: 0.8
    )
    .padding()
}
