import SwiftUI

struct MainTabView: View {
    
    @State private var selectedTab = 0
    
    @StateObject private var challengeLock =
    ChallengeLock()
    
    var body: some View {
        TabView(
            selection: $selectedTab
        ) {
            
            LiveSessionView()
                .tabItem {
                    Label(
                        "Practice",
                        systemImage: "mic.fill"
                    )
                }
                .tag(0)
            
            HistoryView()
                .tabItem {
                    Label(
                        "History",
                        systemImage:
                            "clock.arrow.circlepath"
                    )
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Label(
                        "Settings",
                        systemImage:
                            "gearshape.fill"
                    )
                }
                .tag(2)
        }
        .environmentObject(challengeLock)
        .onChange(
            of: challengeLock.isLocked
        ) { _, locked in
            
            if locked {
                // A challenge can only be started
                // from the Practice tab.
                selectedTab = 0
            }
        }
        .onChange(
            of: selectedTab
        ) { _, newTab in
            
            // Safety net:
            // if something attempts to change tabs
            // during a challenge, return to Practice.
            if challengeLock.isLocked && newTab != 0 {
                selectedTab = 0
            }
        }
    }
}
