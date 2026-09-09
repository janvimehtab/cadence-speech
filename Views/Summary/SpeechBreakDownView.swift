import SwiftUI

struct SpeechBreakdownView: View {
    
    let wordsPerMinute: Double
    let fillerCount: Int
    let fillerFrequency: Double
    let pauseQualityScore: Double
    let pauseRatio: Double
    let averagePauseDuration: TimeInterval
    let pauseFrequency: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Text("Speech Breakdown")
                .font(.headline)
            
            breakdownRow(
                title: "Speaking Pace",
                value: "\(Int(wordsPerMinute)) WPM",
                detail: paceDescription,
                icon: "speedometer"
            )
            
            breakdownRow(
                title: "Filler Words",
                value: "\(fillerCount)",
                detail: String(
                    format:
                        "%.1f%% of your words",
                    fillerFrequency
                ),
                icon: "bubble.left"
            )
            
            breakdownRow(
                title: "Pause Quality",
                value: "\(Int(pauseQualityScore))/100",
                detail: pauseDescription,
                icon: "pause.circle"
            )
            
            breakdownRow(
                title: "Silent Time",
                value: String(
                    format:
                        "%.0f%%",
                    pauseRatio * 100
                ),
                detail: String(
                    format:
                        "%.1fs average · %.1f/min",
                    averagePauseDuration,
                    pauseFrequency
                ),
                icon: "waveform"
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
    
    private var paceDescription: String {
        
        if wordsPerMinute <= 0 {
            return "Not enough speech data"
        }
        
        if wordsPerMinute < 130 {
            return "A little slow"
        }
        
        if wordsPerMinute <= 160 {
            return "Good presentation pace"
        }
        
        return "A little fast"
    }
    
    private var pauseDescription: String {
        
        if pauseQualityScore >= 90 {
            return "Excellent use of pauses"
        }
        
        if pauseQualityScore >= 75 {
            return "Generally well controlled"
        }
        
        if pauseQualityScore >= 60 {
            return "Could be more consistent"
        }
        
        return "Pauses need attention"
    }
    
    private func breakdownRow(
        title: String,
        value: String,
        detail: String,
        icon: String
    ) -> some View {
        
        HStack(spacing: 14) {
            
            Image(systemName: icon)
                .font(.title3)
                .frame(
                    width: 34,
                    height: 34
                )
                .background(
                    .quaternary
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 10
                    )
                )
            
            VStack(
                alignment: .leading,
                spacing: 3
            ) {
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.bold)
        }
    }
}
