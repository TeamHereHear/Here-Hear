import AVFoundation

protocol AudioSessionManagerProtocol {
    func configureAudioSession()
    func activateAudioSession()
    func deactivateAudioSession()
}

class AudioSessionManager: AudioSessionManagerProtocol {

    static let shared = AudioSessionManager()
    private let session = AVAudioSession.sharedInstance()

    init() {
        configureAudioSession()
        setupNotifications()
    }
    
    func configureAudioSession() {
        do {
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers, .interruptSpokenAudioAndMixWithOthers])
            try session.setActive(true)
            print("Audio session configured successfully.")
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }

    func activateAudioSession() {
        serialQueue.sync {
            do {
                try session.setActive(true, options: .notifyOthersOnDeactivation)
                print("Audio session activated successfully.")
            } catch {
                print("Failed to activate audio session: \(error.localizedDescription)")
            }
        }
    }

    func deactivateAudioSession() {
        serialQueue.sync {
            do {
                try session.setActive(false)
                print("Audio session deactivated successfully.")
            } catch {
                print("Failed to deactivate audio session: \(error.localizedDescription)")
            }
        }
    }


    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleAudioSessionInterruption),
            name: AVAudioSession.interruptionNotification, object: session
        )
    }

    @objc private func handleAudioSessionInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        if type == .began {
            print("Audio session interruption began.")
        } else if type == .ended {
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    try? session.setActive(true)
                    print("Audio session resumed after interruption.")
                }
            }
        }
    }
}
final class StubAudioSessionManager: AudioSessionManagerProtocol {
    func configureAudioSession() {
        print("Stub: Setup audio session.")
    }
    func activateAudioSession() {
        print("Stub: Activate audio session.")
    }
    func deactivateAudioSession() {
        print("Stub: Deactivate audio session.")
    }
}
