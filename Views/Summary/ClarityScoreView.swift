import SwiftUI

struct ClarityScoreView: View {
    
    let score: Double
    
    var body: some View {
        VStack(spacing: 12) {
            
            ZStack {
                
                Circle()
                    .stroke(
                        .quaternary,
                        lineWidth: 14
                    )
                
                Circle()
                    .trim(
                        from: 0,
                        to: min(
                            max(score / 100, 0),
                            1
                        )
                    )
                    .stroke(
                        .primary,
                        style: StrokeStyle(
                            lineWidth: 14,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(
                        .degrees(-90)
                    )
                
                VStack(spacing: 2) {
                    
                    Text(
                        "\(Int(score))"
                    )
                    .font(
                        .system(
                            size: 42,
                            weight: .bold
                        )
                    )
                    
                    Text("/ 100")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(
                width: 150,
                height: 150
            )
            
            Text(scoreTitle)
                .font(.headline)
            
            Text(scoreDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
    
    private var scoreTitle: String {
        
        switch score {
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
    
    private var scoreDescription: String {
        
        switch score {
        case 90...:
            return "Your pace, fillers, pauses, and fluency are working together very well."
        case 80..<90:
            return "Your delivery is strong with a few areas that can still be refined."
        case 70..<80:
            return "You have a solid foundation. Consistency will make your delivery stronger."
        case 60..<70:
            return "There are several useful areas to work on. Focus on one improvement at a time."
        default:
            return "Don't worry about the score. Use each practice session to improve gradually."
        }
    }
}
