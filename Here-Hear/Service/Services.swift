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
    var imageUploadService: ImageUploadServiceProtocol { get set }
    
}

class Services: ServicesInterface {
    var userService: UserServiceInterface
    var geohashService: GeohashServiceInterface
    var hearService: HearServiceInterface
    var musicService: MusicServiceInterface
    var authService: AuthServiceInterface
    var imageUploadService: ImageUploadServiceProtocol
    
    init() {
        self.userService = UserService(repository: UserRepository())
        self.geohashService = GeohashService()
        self.hearService = HearService(repository: HearRepository())
        self.musicService = MusicService(repository: MusicRepository())
        self.authService = AuthService()
        self.imageUploadService = ImageUploadService()
    }
}

class StubServices: ServicesInterface {
    var userService: UserServiceInterface = StubUserService()
    var geohashService: GeohashServiceInterface = StubGeohashService()
    var hearService: HearServiceInterface = StubHearService()
    var musicService: MusicServiceInterface = StubMusicService()
    var authService: AuthServiceInterface = StubAuthService()
    var imageUploadService: ImageUploadServiceProtocol = StubImageUploadService()
}
