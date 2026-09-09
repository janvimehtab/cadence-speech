import Foundation
import SwiftUI

@MainActor
final class ChallengeLock: ObservableObject {
    
    @Published private(set) var isLocked = false
    
    func lock() {
        isLocked = true
    }
    
    func unlock() {
        isLocked = false
    }
}
