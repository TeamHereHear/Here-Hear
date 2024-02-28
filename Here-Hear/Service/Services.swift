//
//  Services.swift
//  Here-Hear
//
//  Created by 이원형 on 2/20/24.
//

import Foundation

protocol ServicesInterface {
    var userService: UserServiceInterface { get set }
    var hearService: HearServiceInterface { get set }
    var musicService: MusicServiceInterface { get set }
    var authService: AuthServiceInterface { get set }
    
}

class Services: ServicesInterface {
    var userService: UserServiceInterface
    var hearService: HearServiceInterface
    var musicService: MusicServiceInterface
    var authService: AuthServiceInterface
    
    init() {
        self.userService = UserService()
        self.hearService = HearService(repository: HearRepository())
        self.musicService = MusicService()
        self.authService = AuthService()
    }
}

class StubServices: ServicesInterface {
    var userService: UserServiceInterface = StubUserService()
    var hearService: HearServiceInterface = StubHearService()
    var musicService: MusicServiceInterface = StubMusicService()
    var authService: AuthServiceInterface = StubAuthService()
}
