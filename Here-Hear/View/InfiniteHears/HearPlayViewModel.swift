//
//  HearPlayViewModel.swift
//  Here-Hear
//
//  Created by Tyrell_07 on 4/22/24.
//

import Foundation
import Combine

class HearPlayViewModel: ObservableObject {
    private let hear: HearModel
    var thumbnailPath: String {
        "\(StoragePath.Thumbnail)/\(hear.id).jpg"
    }
    private let container: DIContainer
    @Published var music: MusicModel?
    @Published var userNickname: String?
    @Published var error: HearPlayError?
    
    //TODO: 동영상 받아오기
    
    enum HearPlayError: LocalizedError {
        case failedToFetchMusic
        case failedToFetchUserInfo
    }
    
    init(
        container: DIContainer,
        hear: HearModel
    ) {
        self.container = container
        self.hear = hear
    }

    
    @MainActor
    func fetchMusic() async {
        guard let musicId = hear.musicIds.first else { return }
        do {
            self.music = try await container.services.musicService.fetchMusic(ofIds: [musicId])
                .first
        } catch {
            // TODO: 에러핸들링
            print(error)
            self.error = .failedToFetchMusic
        }
        
    }
    
    @MainActor
    func fetchHearUser() async {
        do {
            self.userNickname = try await container.services.userService.fetchUser(ofId: hear.userId)?.nickname
        } catch {
            // TODO: 에러 핸들링
            print(error)
            self.error = .failedToFetchUserInfo
        }
        
    }
}
