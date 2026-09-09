import SwiftUI

struct FeedbackView: View {
    
    let paceFeedback: String
    let fillerFeedback: String
    let pauseFeedback: String
    let overallFeedback: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Text("Coaching Feedback")
                .font(.headline)
            
            feedbackCard(
                title: "Overall",
                text: overallFeedback,
                icon: "sparkles"
            )
            
            feedbackCard(
                title: "Pace",
                text: paceFeedback,
                icon: "speedometer"
            )
            
            feedbackCard(
                title: "Filler Words",
                text: fillerFeedback,
                icon: "bubble.left"
            )
            
            feedbackCard(
                title: "Pauses",
                text: pauseFeedback,
                icon: "pause.circle"
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
    
    private func feedbackCard(
        title: String,
        text: String,
        icon: String
    ) -> some View {
        
        HStack(
            alignment: .top,
            spacing: 12
        ) {
            
            Image(systemName: icon)
                .font(.headline)
                .frame(
                    width: 32,
                    height: 32
                )
                .background(
                    .quaternary
                )
                .clipShape(
                    Circle()
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
                    ? "Keep practicing to generate feedback."
                    : text
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(
                    horizontal: false,
                    vertical: true
                )
            }
        }
    }
}
