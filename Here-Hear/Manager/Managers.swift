//
//  Managers.swift
//  Here-Hear
//
//  Created by Martin on 3/20/24.
//

import Foundation

protocol ManagersProtocol {
    var musicManager: MusicManagerProtocol { get set }
    var userLocationManager: UserLocationManagerProtocol { get set }
    var audioSessionManager: AudioSessionManagerProtocol { get set }
}

final class Managers: ManagersProtocol {
    var musicManager: MusicManagerProtocol
    var userLocationManager: UserLocationManagerProtocol
    var audioSessionManager: AudioSessionManagerProtocol
    
    init() {
        self.musicManager = MusicManager()
        self.userLocationManager = UserLocationManager()
        self.audioSessionManager = AudioSessionManager()
    }
}

final class StubManagers: ManagersProtocol {
    var musicManager: MusicManagerProtocol = StubMusicManager()
    var userLocationManager: UserLocationManagerProtocol = StubUserLocationManager()
    var audioSessionManager: AudioSessionManagerProtocol = StubAudioSessionManager()
}
