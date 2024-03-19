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
    
    private let hear: HearModel
    
    private let container: DIContainer
    private var cancellables = Set<AnyCancellable>()
    
    init(hear: HearModel, container: DIContainer) {
        self.hear = hear
        self.container = container
    }
    
    func fetchMusic() {
        guard let musicId = hear.musicIds.first else { return }
        
        container.services.musicService.fetchMusic(ofIds: [musicId])
            .sink { completion in
                switch completion {
                case .finished: 
                    print("finished")
                case .failure(let error): 
                    print(error)
                }
            } receiveValue: { [weak self] models in
                guard let self else { return }
              
                Task {
                    await self.setMusic(models.first)
                }
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    private func setMusic(_ music: MusicModel?) {
        self.music = music
    }
    
    func fetchHearUser() {
        container.services.userService.fetchUser(ofId: hear.userId)
            .sink { _ in
            } receiveValue: { [weak self] user in
                guard let self else { return }
                Task {
                    await self.setUserNickname(user?.nickname)
                }
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    private func setUserNickname(_ nickname: String?) {
        self.userNickname = nickname
    }
    
}
