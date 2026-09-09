import SwiftUI
import SwiftData

struct LiveSessionView: View {
    
    @Environment(\.modelContext)
    private var modelContext
    
    @EnvironmentObject
    private var challengeLock: ChallengeLock
    
    @StateObject private var viewModel =
    LiveSessionViewModel()
    
    @State private var showingSummary = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                if viewModel.isSessionActive {
                    activeChallengeView
                } else {
                    readyView
                }
            }
            .navigationTitle("Practice")
            .navigationBarTitleDisplayMode(.large)
            
            // Hide the application's tab bar while
            // the challenge is active.
            .toolbar(
                challengeLock.isLocked
                ? .hidden
                : .visible,
                for: .tabBar
            )
            
            .onAppear {
                viewModel.configure(
                    context: modelContext
                )
            }
            
            .onChange(
                of: viewModel.isSessionActive
            ) { _, isActive in
                
                if isActive {
                    challengeLock.lock()
                } else {
                    challengeLock.unlock()
                    
                    // The session has ended.
                    showingSummary = true
                }
            }
            
            .alert(
                "Permission Required",
                isPresented: Binding<Bool>(
                    get: {
                        viewModel.errorMessage != nil
                    },
                    set: { isPresented in
                        if !isPresented {
                            viewModel.errorMessage = nil
                        }
                    }
                )
            ) {
                Button("OK", role: .cancel) {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(
                    viewModel.errorMessage
                    ?? "Something went wrong."
                )
            }
            
            .sheet(
                isPresented: $showingSummary
            ) {
                SessionSummaryView(
                    transcript: "",
                    duration: viewModel.elapsedTime,
                    wordCount: viewModel.wordCount,
                    fillerCount: viewModel.fillerCount,
                    powerPauses: viewModel.powerPauses,
                    wordsPerMinute:
                        viewModel.wordsPerMinute,
                    clarityScore:
                        viewModel.clarityScore,
                    fillerWords:
                        viewModel.fillerWords,
                    fillerFrequency:
                        viewModel.fillerFrequency,
                    pauseQualityScore:
                        viewModel.pauseQualityScore,
                    pauseRatio:
                        viewModel.pauseRatio,
                    averagePauseDuration:
                        viewModel.averagePauseDuration,
                    pauseFrequency:
                        viewModel.pauseFrequency,
                    paceFeedback:
                        viewModel.paceFeedback,
                    fillerFeedback:
                        viewModel.fillerFeedback,
                    pauseFeedback:
                        viewModel.pauseFeedback,
                    overallFeedback:
                        viewModel.overallFeedback,
                    isValidSession:
                        viewModel.summaryIsValid,
                    validationMessage:
                        viewModel.summaryValidationMessage,
                    topic:
                        viewModel.currentTopic.title
                )
            }
        }
    }
    
    // MARK: - Ready Screen
    
    private var readyView: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                Spacer(minLength: 20)
                
                Image(
                    systemName:
                        "bubble.left.and.text.bubble.right.fill"
                )
                .font(.system(size: 64))
                .symbolRenderingMode(.hierarchical)
                
                VStack(spacing: 8) {
                    
                    Text("2-Minute Challenge")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(
                        "Speak naturally about the topic for two minutes. Cadence will analyze how you speak."
                    )
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                }
                
                topicCard
                
                challengeRules
                
                startButton
                
                Spacer(minLength: 20)
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Topic Card
    
    private var topicCard: some View {
        VStack(
            alignment: .leading,
            spacing: 14
        ) {
            
            HStack {
                
                Label(
                    viewModel.currentTopic.category.title,
                    systemImage:
                        viewModel.currentTopic.category.icon
                )
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                
                Spacer()
                
                Button {
                    viewModel.chooseNewTopic()
                } label: {
                    Image(
                        systemName: "arrow.clockwise"
                    )
                    .font(.subheadline)
                }
                .buttonStyle(.bordered)
            }
            
            Text(
                viewModel.currentTopic.title
            )
            .font(.title3)
            .fontWeight(.bold)
            
            Text(
                "You don't need to prepare an exact answer. Just explain your thoughts naturally."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .background(.thinMaterial)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 24
            )
        )
    }
    
    // MARK: - Challenge Rules
    
    private var challengeRules: some View {
        VStack(
            alignment: .leading,
            spacing: 12
        ) {
            
            ruleRow(
                icon: "timer",
                title: "2 minutes",
                description:
                    "The challenge ends automatically."
            )
            
            ruleRow(
                icon: "mic.fill",
                title: "Keep speaking",
                description:
                    "Speak naturally and don't worry about perfection."
            )
            
            ruleRow(
                icon: "chart.bar.fill",
                title: "Get your analysis",
                description:
                    "See your pace, fillers, pauses and clarity afterward."
            )
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding(.horizontal, 6)
    }
    
    private func ruleRow(
        icon: String,
        title: String,
        description: String
    ) -> some View {
        
        HStack(
            alignment: .top,
            spacing: 14
        ) {
            
            Image(systemName: icon)
                .font(.headline)
                .frame(
                    width: 30,
                    height: 30
                )
                .background(.quaternary)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 9
                    )
                )
            
            VStack(
                alignment: .leading,
                spacing: 2
            ) {
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Start
    
    private var startButton: some View {
        Button {
            startSession()
        } label: {
            Label(
                "Start Challenge",
                systemImage: "mic.fill"
            )
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
        .buttonStyle(.borderedProminent)
        .padding(.top, 4)
    }
    
    // MARK: - Active Challenge
    
    private var activeChallengeView: some View {
        ScrollView {
            VStack(spacing: 18) {
                
                activeTopicCard
                
                timerView
                
                challengeProgress
                
                WaveformView(
                    audioLevel:
                        viewModel.audioLevel
                )
                .frame(height: 100)
                .padding(.horizontal, 2)
                
                LiveStatsView(
                    wordCount:
                        viewModel.wordCount,
                    wordsPerMinute:
                        viewModel.wordsPerMinute,
                    fillerCount:
                        viewModel.fillerCount,
                    clarityScore:
                        viewModel.clarityScore,
                    powerPauses:
                        viewModel.powerPauses,
                    pauseQualityScore:
                        viewModel.pauseQualityScore,
                    pauseRatio:
                        viewModel.pauseRatio,
                    averagePauseDuration:
                        viewModel.averagePauseDuration
                )
                
                finishButton
            }
            .padding()
        }
    }
    
    // MARK: - Active Topic
    
    private var activeTopicCard: some View {
        VStack(
            alignment: .leading,
            spacing: 7
        ) {
            
            Text("YOUR TOPIC")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
                .tracking(1)
            
            Text(
                viewModel.currentTopic.title
            )
            .font(.title3)
            .fontWeight(.bold)
            
            Text(
                viewModel.currentTopic.category.title
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding(18)
        .background(.thinMaterial)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 20
            )
        )
    }
    
    // MARK: - Timer
    
    private var timerView: some View {
        VStack(spacing: 4) {
            
            Text(
                viewModel.formattedRemainingTime
            )
            .font(
                .system(
                    size: 46,
                    weight: .bold,
                    design: .monospaced
                )
            )
            
            Text("Time remaining")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 4)
    }
    
    // MARK: - Progress
    
    private var challengeProgress: some View {
        ProgressView(
            value:
                viewModel.challengeProgress
        )
        .progressViewStyle(.linear)
        .tint(.primary)
        .scaleEffect(
            x: 1,
            y: 1.4,
            anchor: .center
        )
    }
    
    // MARK: - Finish
    
    private var finishButton: some View {
        Button {
            stopSession()
        } label: {
            HStack(spacing: 10) {
                
                Image(
                    systemName: "stop.fill"
                )
                
                Text("Finish Early")
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
        }
        .buttonStyle(.bordered)
        .padding(.top, 4)
    }
    
    // MARK: - Actions
    
    private func startSession() {
        showingSummary = false
        viewModel.startSession()
    }
    
    private func stopSession() {
        Task {
            _ = await viewModel.stopSession()
        }
    }
}

#Preview {
    LiveSessionView()
        .environmentObject(
            ChallengeLock()
        )
}
