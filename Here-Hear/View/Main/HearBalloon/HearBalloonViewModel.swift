//
//  HearBalloonViewModel.swift
//  Here-Hear
//
//  Created by Martin on 3/13/24.
//

import Foundation
import Combine

final class HearBalloonViewModel: ObservableObject {
    @Published var music: MusicModel?
    @Published var userNickname: String?
    public var like: Int {
        hear.like
    }
    
    public let hear: HearModel
    public var location: LocationModel {
        hear.location
    }
    private let container: DIContainer
    private var cancellables = Set<AnyCancellable>()
    
    init(hear: HearModel, container: DIContainer) {
        self.hear = hear
        self.container = container
    }
    
    func fetchMusic() {
        guard let musicId = hear.musicIds.first else { return }
        
        container.services.musicService.fetchMusic(ofIds: [musicId])
            .receive(on: DispatchQueue.main)
            .sink { _ in
            } receiveValue: { [weak self] musicData in
                guard let self else { return }
                self.music = musicData.first
              //  print("HearBallonViewModel 가져온 음악 정보: \(String(describing: music))")
            }
            .store(in: &cancellables)
    }
    
    func fetchHearUser() {
        container.services.userService.fetchUser(ofId: hear.userId)
            .receive(on: DispatchQueue.main)
            .sink { _ in
            } receiveValue: { [weak self] user in
                guard let self else { return }
                self.userNickname = user?.nickname
            }
            .store(in: &cancellables)
    }
}
