//
//  Services.swift
//  Here-Hear
//
//  Created by 이원형 on 2/20/24.
//

import Foundation

protocol ServicesInterface {
    var userService: UserServiceInterface { get set }
    var geohashService: GeohashServiceInterface { get set }
    var hearService: HearServiceInterface { get set }
    var musicService: MusicServiceInterface { get set }
    var authService: AuthServiceInterface { get set }
    
}

class Services: ServicesInterface {
    var userService: UserServiceInterface
    var geohashService: GeohashServiceInterface
    var hearService: HearServiceInterface
    var musicService: MusicServiceInterface
    var authService: AuthServiceInterface
    
    init() {
        self.userService = UserService()
        self.geohashService = GeohashService()
        self.hearService = HearService(repository: HearRepository(), geohashService: geohashService)
        self.musicService = MusicService()
        self.authService = AuthService()
    }
}

class StubServices: ServicesInterface {
    var userService: UserServiceInterface = StubUserService()
    var geohashService: GeohashServiceInterface = StubGeohashService()
    var hearService: HearServiceInterface = StubHearService()
    var musicService: MusicServiceInterface = StubMusicService()
    var authService: AuthServiceInterface = StubAuthService()
}
