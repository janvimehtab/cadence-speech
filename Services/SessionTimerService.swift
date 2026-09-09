import Foundation

final class SessionTimerService: ObservableObject {
    
    @Published private(set) var elapsedTime: TimeInterval = 0
    @Published private(set) var isRunning = false
    @Published private(set) var isPaused = false
    
    private var timer: Timer?
    private var startDate: Date?
    private var accumulatedTime: TimeInterval = 0
    
    // MARK: - Start
    
    func start() {
        
        stopTimerOnly()
        
        accumulatedTime = 0
        elapsedTime = 0
        
        startDate = Date()
        
        isRunning = true
        isPaused = false
        
        startTimer()
    }
    
    // MARK: - Pause
    
    func pause() {
        
        guard isRunning && !isPaused else {
            return
        }
        
        updateElapsedTime()
        
        accumulatedTime = elapsedTime
        
        stopTimerOnly()
        
        isPaused = true
    }
    
    // MARK: - Resume
    
    func resume() {
        
        guard isRunning && isPaused else {
            return
        }
        
        startDate = Date()
        
        isPaused = false
        
        startTimer()
    }
    
    // MARK: - Stop
    
    func stop() {
        
        updateElapsedTime()
        
        stopTimerOnly()
        
        isRunning = false
        isPaused = false
        
        startDate = nil
    }
    
    // MARK: - Reset
    
    func reset() {
        
        stopTimerOnly()
        
        elapsedTime = 0
        accumulatedTime = 0
        
        startDate = nil
        
        isRunning = false
        isPaused = false
    }
    
    // MARK: - Timer
    
    private func startTimer() {
        
        timer = Timer.scheduledTimer(
            withTimeInterval: 0.1,
            repeats: true
        ) { [weak self] _ in
            
            self?.updateElapsedTime()
        }
    }
    
    private func stopTimerOnly() {
        
        timer?.invalidate()
        timer = nil
    }
    
    private func updateElapsedTime() {
        
        guard let startDate = startDate else {
            return
        }
        
        elapsedTime =
        accumulatedTime +
        Date().timeIntervalSince(startDate)
    }
    
    // MARK: - Display Time
    
    var formattedTime: String {
        
        let totalSeconds = Int(elapsedTime)
        
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        
        return String(
            format: "%02d:%02d",
            minutes,
            seconds
        )
    }
    
    deinit {
        timer?.invalidate()
    }
}
