import SwiftUI
import SwiftData

@main
struct CadenceApp: App {
    
    var body: some Scene {
        
        WindowGroup {
            MainTabView()
        }
        .modelContainer(
            for: [
                SpeechSession.self,
                AppSettings.self
            ]
        )
    }
}
