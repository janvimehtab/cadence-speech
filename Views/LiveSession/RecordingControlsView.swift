import SwiftUI

struct RecordingControlsView: View {
    
    let onStop: () -> Void
    
    @State private var showingStopConfirmation = false
    
    var body: some View {
        VStack(spacing: 10) {
            
            Button {
                showingStopConfirmation = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "stop.fill")
                    Text("Finish Early")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
            }
            .buttonStyle(.bordered)
            
            Text(
                "You can finish whenever you're ready."
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 10)
        .confirmationDialog(
            "Finish Practice?",
            isPresented:
                $showingStopConfirmation,
            titleVisibility: .visible
        ) {
            
            Button(
                "Finish Session",
                role: .destructive
            ) {
                onStop()
            }
            
            Button(
                "Continue",
                role: .cancel
            ) {
            }
            
        } message: {
            Text(
                "Cadence will analyze the speech you've given so far."
            )
        }
    }
}
