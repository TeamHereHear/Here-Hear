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
}

final class Managers: ManagersProtocol {
    var musicManager: MusicManagerProtocol
    var userLocationManager: UserLocationManagerProtocol
    
    init() {
        self.musicManager = MusicManager()
        self.userLocationManager = UserLocationManager()
    }
}

final class StubManagers: ManagersProtocol {
    var musicManager: MusicManagerProtocol = StubMusicManager()
    var userLocationManager: UserLocationManagerProtocol = StubUserLocationManager()
}
