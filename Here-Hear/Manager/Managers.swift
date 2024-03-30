//
//  Managers.swift
//  Here-Hear
//
//  Created by Martin on 3/20/24.
//

import Foundation

protocol ManagersProtocol {
    var musicManager: MusicMangerProtocol { get set }
    var userLocationManager: UserLocationManagerProtocol { get set }
}

final class Managers: ManagersProtocol {
    var musicManager: MusicMangerProtocol
    var userLocationManager: UserLocationManagerProtocol
    
    init() {
        self.musicManager = MusicManger()
        self.userLocationManager = UserLocationManager()
    }
}

final class StubManagers: ManagersProtocol {
    var musicManager: MusicMangerProtocol = StubMusicManager()
    var userLocationManager: UserLocationManagerProtocol = StubUserLocationManager()
}
