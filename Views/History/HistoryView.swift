import SwiftUI
import SwiftData

struct HistoryView: View {
    
    @Environment(\.modelContext)
    private var modelContext
    
    @StateObject private var viewModel =
    HistoryViewModel()
    
    var body: some View {
        NavigationStack {
            
            Group {
                
                if viewModel.sessions.isEmpty {
                    EmptyHistoryView()
                } else {
                    historyContent
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                viewModel.configure(
                    context: modelContext
                )
            }
        }
    }
    
    // MARK: - History Content
    
    private var historyContent: some View {
        ScrollView {
            VStack(spacing: 22) {
                
                overviewSection
                
                if viewModel.sessions.count >= 2 {
                    ProgressChartView(
                        sessions:
                            viewModel.scoreTrend
                    )
                }
                
                sessionList
            }
            .padding(.vertical)
        }
    }
    
    // MARK: - Overview
    
    private var overviewSection: some View {
        VStack(
            alignment: .leading,
            spacing: 14
        ) {
            
            Text("Your Progress")
                .font(.headline)
                .padding(.horizontal)
            
            HStack(spacing: 10) {
                
                overviewCard(
                    title: "Sessions",
                    value:
                        "\(viewModel.totalSessions)",
                    icon: "waveform"
                )
                
                overviewCard(
                    title: "Avg. Score",
                    value:
                        "\(Int(viewModel.averageScore))",
                    icon: "chart.bar"
                )
                
                overviewCard(
                    title: "Best",
                    value:
                        "\(Int(viewModel.bestScore))",
                    icon: "star"
                )
            }
            .padding(.horizontal)
            
            HStack(spacing: 10) {
                
                overviewCard(
                    title: "Practice",
                    value:
                        viewModel.practiceTimeText,
                    icon: "timer"
                )
                
                overviewCard(
                    title: "Avg. WPM",
                    value:
                        "\(Int(viewModel.averageWPM))",
                    icon: "speedometer"
                )
                
                overviewCard(
                    title: "Avg. Fillers",
                    value:
                        String(
                            format:
                                "%.1f",
                            viewModel.averageFillersPerSession
                        ),
                    icon: "bubble.left"
                )
            }
            .padding(.horizontal)
            
            if viewModel.previousSession != nil {
                scoreChangeCard
                    .padding(.horizontal)
            }
        }
    }
    
    private func overviewCard(
        title: String,
        value: String,
        icon: String
    ) -> some View {
        
        VStack(spacing: 7) {
            
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.thinMaterial)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 14
            )
        )
    }
    
    // MARK: - Score Change
    
    private var scoreChangeCard: some View {
        HStack(spacing: 12) {
            
            Image(
                systemName:
                    viewModel.scoreChangeIsPositive
                ? "arrow.up.right"
                : "arrow.down.right"
            )
            .font(.headline)
            
            VStack(
                alignment: .leading,
                spacing: 3
            ) {
                
                Text("Latest Score")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(
                    viewModel.scoreChangeText
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if let latest =
                viewModel.latestSession {
                
                Text(
                    "\(Int(latest.clarityScore))"
                )
                .font(.title3)
                .fontWeight(.bold)
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 16
            )
        )
    }
    
    // MARK: - Sessions
    
    private var sessionList: some View {
        VStack(
            alignment: .leading,
            spacing: 12
        ) {
            
            Text("Practice Sessions")
                .font(.headline)
                .padding(.horizontal)
            
            LazyVStack(
                spacing: 0
            ) {
                
                ForEach(
                    viewModel.sessions
                ) { session in
                    
                    NavigationLink {
                        SessionDetailView(
                            session: session
                        )
                    } label: {
                        SessionRowView(
                            session: session
                        )
                        .padding(.horizontal)
                    }
                    .buttonStyle(.plain)
                    
                    Divider()
                        .padding(.leading, 80)
                }
                .onDelete {
                    viewModel.deleteSessions(
                        at: $0
                    )
                }
            }
            .background(.thinMaterial)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 20
                )
            )
            .padding(.horizontal)
        }
    }
}
