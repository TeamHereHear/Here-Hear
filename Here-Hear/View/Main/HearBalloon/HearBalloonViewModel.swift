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
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished: 
                    print("finished")
                case .failure(let error): 
                    print(error)
                }
            } receiveValue: { [weak self] models in
                guard let self else { return }
                self.music = music
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
