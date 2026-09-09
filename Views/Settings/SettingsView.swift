import SwiftUI
import SwiftData

struct SettingsView: View {
    
    @Environment(\.modelContext)
    private var modelContext
    
    @StateObject private var viewModel =
    SettingsViewModel()
    
    var body: some View {
        NavigationStack {
            Form {
                
                speakingPaceSection
                
                fillerDetectionSection
                
                fillerWordsSection
                
                privacySection
                
                resetSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                viewModel.configure(
                    context: modelContext
                )
            }
            .confirmationDialog(
                "Reset Settings?",
                isPresented:
                    $viewModel.showResetConfirmation,
                titleVisibility: .visible
            ) {
                
                Button(
                    "Reset Settings",
                    role: .destructive
                ) {
                    viewModel.resetSettings()
                }
                
                Button(
                    "Cancel",
                    role: .cancel
                ) {
                    
                }
                
            } message: {
                Text(
                    "This will restore Cadence's default speaking pace and filler-word settings."
                )
            }
        }
    }
    
    // MARK: - Speaking Pace
    
    private var speakingPaceSection: some View {
        Section {
            
            Picker(
                "Speaking Mode",
                selection:
                    Binding(
                        get: {
                            viewModel.selectedSpeakingPace
                        },
                        set: {
                            viewModel.setSpeakingPace($0)
                        }
                    )
            ) {
                
                ForEach(
                    SpeakingPace.allCases
                ) { pace in
                    
                    Text(
                        pace.title
                    )
                    .tag(pace)
                }
            }
            
            VStack(
                alignment: .leading,
                spacing: 6
            ) {
                
                Text(
                    viewModel.selectedSpeakingPace.description
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
                
                Text(
                    speakingPaceExplanation
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
            
        } header: {
            
            Label(
                "Speaking Pace",
                systemImage: "speedometer"
            )
            
        } footer: {
            
            Text(
                "Cadence uses this target range when calculating your pace score and feedback."
            )
        }
    }
    
    // MARK: - Filler Detection
    
    private var fillerDetectionSection: some View {
        Section {
            
            Toggle(
                "Detect Filler Words",
                isOn:
                    Binding(
                        get: {
                            viewModel.fillersEnabled
                        },
                        set: {
                            viewModel.setFillersEnabled($0)
                        }
                    )
            )
            
            if viewModel.fillersEnabled {
                
                HStack {
                    
                    Text("Tracked Fillers")
                    
                    Spacer()
                    
                    Text(
                        "\(viewModel.enabledFillerCount)"
                    )
                    .foregroundStyle(.secondary)
                }
            }
            
        } header: {
            
            Label(
                "Filler Detection",
                systemImage: "bubble.left.and.bubble.right"
            )
            
        } footer: {
            
            Text(
                "Turn this off if you don't want filler words to affect your analysis score."
            )
        }
    }
    
    // MARK: - Filler Words
    
    private var fillerWordsSection: some View {
        Section {
            
            if viewModel.fillersEnabled {
                
                ForEach(
                    FillerWord.allCases
                ) { filler in
                    
                    Toggle(
                        filler.displayName,
                        isOn:
                            Binding(
                                get: {
                                    viewModel.isFillerEnabled(
                                        filler
                                    )
                                },
                                set: { _ in
                                    viewModel.toggleFiller(
                                        filler
                                    )
                                }
                            )
                    )
                }
                
            } else {
                
                Text(
                    "Enable filler detection to customize tracked words."
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            
        } header: {
            
            Label(
                "Filler Words to Track",
                systemImage: "text.bubble"
            )
        }
    }
    
    // MARK: - Privacy
    
    private var privacySection: some View {
        Section {
            
            VStack(
                alignment: .leading,
                spacing: 12
            ) {
                
                privacyRow(
                    icon: "iphone",
                    title: "Stored on this device",
                    description:
                        "Your practice history and settings are stored locally on your device."
                )
                
                privacyRow(
                    icon: "mic.slash",
                    title: "No cloud recording storage",
                    description:
                        "Cadence does not save your microphone recordings as cloud files."
                )
                
                privacyRow(
                    icon: "lock.shield",
                    title: "Your practice stays private",
                    description:
                        "Your session history is stored using Apple's local data storage."
                )
            }
            .padding(.vertical, 6)
            
        } header: {
            
            Label(
                "Privacy",
                systemImage: "lock"
            )
        }
    }
    
    private func privacyRow(
        icon: String,
        title: String,
        description: String
    ) -> some View {
        
        HStack(
            alignment: .top,
            spacing: 12
        ) {
            
            Image(systemName: icon)
                .font(.headline)
                .frame(
                    width: 30
                )
            
            VStack(
                alignment: .leading,
                spacing: 3
            ) {
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    // MARK: - Reset
    
    private var resetSection: some View {
        Section {
            
            Button(
                role: .destructive
            ) {
                viewModel.showResetConfirmation =
                true
            } label: {
                
                HStack {
                    
                    Spacer()
                    
                    Text("Reset Settings")
                    
                    Spacer()
                }
            }
            
        } footer: {
            
            Text(
                "Resetting settings will not delete your practice history."
            )
        }
    }
    
    // MARK: - Explanation
    
    private var speakingPaceExplanation: String {
        
        switch viewModel.selectedSpeakingPace {
            
        case .fast:
            return "Designed for pitches, quick explanations, and energetic delivery."
            
        case .moderate:
            return "Designed for presentations, interviews, and general speaking."
            
        case .slow:
            return "Designed for lectures, teaching, and detailed explanations."
        }
    }
}

#Preview {
    SettingsView()
}
