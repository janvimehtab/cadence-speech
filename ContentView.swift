import SwiftUI

struct ContentView: View {
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "waveform")
                .font(.system(size: 60))
            Text("Cadence")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Your personal speech clarity coach")
                .foregroundStyle(.secondary)
        }
    }
    
}

#Preview {
    ContentView()
}
