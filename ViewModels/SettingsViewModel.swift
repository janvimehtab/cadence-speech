import Foundation
import SwiftData
import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    
    @Published private(set) var settings: AppSettings?
    
    @Published var selectedSpeakingPace: SpeakingPace = .moderate
    @Published var fillersEnabled: Bool = true
    @Published var enabledFillers: Set<String> = []
    
    @Published var showResetConfirmation = false
    
    private var modelContext: ModelContext?
    
    // MARK: - Configure
    
    func configure(context: ModelContext) {
        modelContext = context
        
        if settings == nil {
            loadSettings()
        }
    }
    
    // MARK: - Load Settings
    
    func loadSettings() {
        guard let modelContext else {
            return
        }
        
        let descriptor =
        FetchDescriptor<AppSettings>()
        
        do {
            let existingSettings =
            try modelContext.fetch(descriptor)
            
            if let existing =
                existingSettings.first {
                
                settings = existing
                
                selectedSpeakingPace =
                existing.speakingPace
                
                fillersEnabled =
                existing.fillersEnabled
                
                enabledFillers =
                existing.enabledFillerSet
                
            } else {
                
                let newSettings =
                AppSettings()
                
                modelContext.insert(
                    newSettings
                )
                
                try modelContext.save()
                
                settings = newSettings
                
                selectedSpeakingPace =
                newSettings.speakingPace
                
                fillersEnabled =
                newSettings.fillersEnabled
                
                enabledFillers =
                newSettings.enabledFillerSet
            }
            
        } catch {
            print(
                "Failed to load settings: \(error)"
            )
        }
    }
    
    // MARK: - Speaking Pace
    
    func setSpeakingPace(
        _ pace: SpeakingPace
    ) {
        selectedSpeakingPace = pace
        
        guard let settings else {
            return
        }
        
        settings.speakingPace = pace
        
        save()
    }
    
    // MARK: - Filler Detection
    
    func setFillersEnabled(
        _ enabled: Bool
    ) {
        fillersEnabled = enabled
        
        guard let settings else {
            return
        }
        
        settings.fillersEnabled =
        enabled
        
        save()
    }
    
    // MARK: - Individual Fillers
    
    func isFillerEnabled(
        _ filler: FillerWord
    ) -> Bool {
        enabledFillers.contains(
            filler.rawValue
        )
    }
    
    func toggleFiller(
        _ filler: FillerWord
    ) {
        if enabledFillers.contains(
            filler.rawValue
        ) {
            enabledFillers.remove(
                filler.rawValue
            )
        } else {
            enabledFillers.insert(
                filler.rawValue
            )
        }
        
        guard let settings else {
            return
        }
        
        settings.enabledFillers =
        Array(enabledFillers)
        
        save()
    }
    
    // MARK: - Reset
    
    func resetSettings() {
        guard let settings else {
            return
        }
        
        selectedSpeakingPace =
            .moderate
        
        fillersEnabled =
        true
        
        enabledFillers =
        Set(
            FillerWord.allCases.map {
                $0.rawValue
            }
        )
        
        settings.speakingPace =
            .moderate
        
        settings.fillersEnabled =
        true
        
        settings.enabledFillers =
        Array(enabledFillers)
        
        save()
    }
    
    // MARK: - Save
    
    private func save() {
        guard let modelContext else {
            return
        }
        
        do {
            try modelContext.save()
        } catch {
            print(
                "Failed to save settings: \(error)"
            )
        }
    }
    
    // MARK: - Filler Count
    
    var enabledFillerCount: Int {
        enabledFillers.count
    }
}
