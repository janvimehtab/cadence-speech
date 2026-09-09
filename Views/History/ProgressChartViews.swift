import SwiftUI
import Charts

struct ProgressChartView: View {
    
    let sessions: [SpeechSession]
    
    var body: some View {
        VStack(
            alignment: .leading,
            spacing: 14
        ) {
            
            HStack {
                
                Text("Score Progress")
                    .font(.headline)
                
                Spacer()
                
                Text("Last \(sessions.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if sessions.count < 2 {
                emptyChartMessage
            } else {
                chart
            }
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
    
    private var chart: some View {
        Chart {
            ForEach(
                Array(
                    sessions.enumerated()
                ),
                id: \.element.id
            ) { index, session in
                
                LineMark(
                    x: .value(
                        "Session",
                        index + 1
                    ),
                    y: .value(
                        "Score",
                        session.clarityScore
                    )
                )
                .interpolationMethod(.catmullRom)
                
                PointMark(
                    x: .value(
                        "Session",
                        index + 1
                    ),
                    y: .value(
                        "Score",
                        session.clarityScore
                    )
                )
            }
        }
        .chartYScale(
            domain: 0...100
        )
        .chartYAxis {
            AxisMarks(
                values: [0, 25, 50, 75, 100]
            )
        }
        .chartXAxis {
            AxisMarks()
        }
        .frame(height: 200)
    }
    
    private var emptyChartMessage: some View {
        VStack(spacing: 8) {
            
            Image(
                systemName:
                    "chart.line.uptrend.xyaxis"
            )
            .font(.title2)
            .foregroundStyle(.secondary)
            
            Text(
                "Complete at least two sessions to see your progress."
            )
            .font(.caption)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
        }
        .frame(
            maxWidth: .infinity
        )
        .frame(height: 150)
    }
}
