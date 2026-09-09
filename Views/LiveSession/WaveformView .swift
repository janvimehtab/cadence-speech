import SwiftUI

struct WaveformView: View {
    
    let audioLevel: Float
    
    @State private var isAnimating = false
    
    private let barCount = 28
    
    var body: some View {
        ZStack {
            
            RoundedRectangle(cornerRadius: 24)
                .fill(.thinMaterial)
            
            HStack(
                alignment: .center,
                spacing: 4
            ) {
                
                ForEach(
                    0..<barCount,
                    id: \.self
                ) { index in
                    
                    Capsule()
                        .fill(.primary.opacity(0.7))
                        .frame(
                            width: 4,
                            height: barHeight(
                                for: index
                            )
                        )
                        .animation(
                            .easeInOut(
                                duration: 0.12
                            ),
                            value: audioLevel
                        )
                }
            }
            .padding(.horizontal, 18)
            
            VStack {
                Spacer()
                
                HStack {
                    Circle()
                        .fill(
                            audioLevel > 0.04
                            ? .red
                            : .secondary
                        )
                        .frame(
                            width: 7,
                            height: 7
                        )
                    
                    Text(
                        audioLevel > 0.04
                        ? "Listening"
                        : "Waiting for speech"
                    )
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }
                .padding(.bottom, 8)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
    
    private func barHeight(
        for index: Int
    ) -> CGFloat {
        
        let normalized =
        CGFloat(
            max(
                min(
                    audioLevel,
                    1
                ),
                0
            )
        )
        
        let center =
        CGFloat(barCount - 1) / 2
        
        let distance =
        abs(
            CGFloat(index) - center
        )
        
        let positionFactor =
        max(
            0.35,
            1 - distance / center
        )
        
        let baseHeight: CGFloat = 8
        let maximumHeight: CGFloat = 52
        
        let level =
        baseHeight
        + (
            maximumHeight
            - baseHeight
        )
        * normalized
        * positionFactor
        
        return max(
            baseHeight,
            level
        )
    }
}

#Preview {
    WaveformView(
        audioLevel: 0.45
    )
    .frame(height: 110)
    .padding()
}
