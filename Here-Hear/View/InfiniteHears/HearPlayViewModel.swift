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
    private let container: DIContainer
    @Published var music: MusicModel?
    @Published var userNickname: String?
    
    init(
        container: DIContainer,
        hear: HearModel
    ) {
        self.container = container
        self.hear = hear
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchMusic() {
        guard let musicId = hear.musicIds.first else { return }
        
        container.services.musicService.fetchMusic(ofIds: [musicId])
            .receive(on: DispatchQueue.main)
            .sink { _ in
            } receiveValue: { [weak self] musicData in
                guard let self else { return }
                self.music = musicData.first
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
