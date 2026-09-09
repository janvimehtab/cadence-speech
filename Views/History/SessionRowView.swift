import SwiftUI

struct SessionRowView: View {
    
    let session: SpeechSession
    
    var body: some View {
        HStack(spacing: 14) {
            
            scoreCircle
            
            VStack(
                alignment: .leading,
                spacing: 6
            ) {
                
                Text(
                    session.date.formatted(
                        date: .abbreviated,
                        time: .shortened
                    )
                )
                .font(.subheadline)
                .fontWeight(.semibold)
                
                HStack(spacing: 12) {
                    
                    Label(
                        formattedDuration,
                        systemImage: "timer"
                    )
                    
                    Label(
                        "\(session.totalWords) words",
                        systemImage: "text.word.spacing"
                    )
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(
                alignment: .trailing,
                spacing: 5
            ) {
                
                Text(
                    "\(Int(session.wordsPerMinute))"
                )
                .font(.subheadline)
                .fontWeight(.bold)
                
                Text("WPM")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
    
    private var scoreCircle: some View {
        ZStack {
            
            Circle()
                .stroke(
                    .quaternary,
                    lineWidth: 5
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
                        lineWidth: 5,
                        lineCap: .round
                    )
                )
                .rotationEffect(
                    .degrees(-90)
                )
            
            Text(
                "\(Int(session.clarityScore))"
            )
            .font(.caption)
            .fontWeight(.bold)
        }
        .frame(
            width: 52,
            height: 52
        )
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
}
