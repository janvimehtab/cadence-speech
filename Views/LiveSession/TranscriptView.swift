import SwiftUI

struct TranscriptView: View {
    
    let transcript: String
    
    var body: some View {
        
        VStack(
            alignment: .leading,
            spacing: 12
        ) {
            
            HStack {
                
                Label(
                    "Live Transcript",
                    systemImage: "text.quote"
                )
                .font(.headline)
                
                Spacer()
                
                if !transcript.isEmpty {
                    Text("LIVE")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(.green)
                }
            }
            
            ScrollView {
                
                if transcript.isEmpty {
                    
                    VStack(spacing: 10) {
                        
                        Image(
                            systemName: "waveform"
                        )
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                        
                        Text("Start speaking...")
                            .foregroundStyle(.secondary)
                        
                        Text(
                            "Your transcript will appear here."
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .frame(
                        maxWidth: .infinity,
                        minHeight: 180
                    )
                    
                } else {
                    
                    Text(transcript)
                        .font(.body)
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .padding(.bottom, 20)
                }
            }
            .frame(maxHeight: .infinity)
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(
            RoundedRectangle(cornerRadius: 18)
        )
    }
}

#Preview {
    TranscriptView(
        transcript: "Hello, this is a test speech session."
    )
    .frame(height: 300)
    .padding()
}
