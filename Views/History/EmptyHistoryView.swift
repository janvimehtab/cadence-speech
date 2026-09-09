import SwiftUI

struct EmptyHistoryView: View {
    
    var body: some View {
        VStack(spacing: 20) {
            
            Image(
                systemName:
                    "clock.arrow.circlepath"
            )
            .font(.system(size: 60))
            .foregroundStyle(.secondary)
            
            VStack(spacing: 8) {
                
                Text("No Practice Sessions Yet")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text(
                    "Complete your first speaking practice session and your progress will appear here."
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .padding()
    }
}
