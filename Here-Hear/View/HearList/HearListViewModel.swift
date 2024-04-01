//
//  HearListViewModel.swift
//  Here-Hear
//
//  Created by Martin on 3/25/24.
//

import Foundation
import Combine
import CoreLocation

final class HearListViewModel: ObservableObject {
    @Published var hears: [HearModel] = []
    @Published var userNicknames: [String: String] = [:] // @Published 를 제거해도 잘 동작하는지 살펴볼 것
    @Published var musicOfHear: [String: [MusicModel]] = [:]
    @Published var loadingState: LoadingState = .none
    private var userLocation: CLLocation?
    
    private let container: DIContainer
    private var cancellables = Set<AnyCancellable>()
    private var lastDocumentID: String?
    
    init(
        container: DIContainer
    ) {
        self.container = container
        self.userLocation = container.managers.userLocationManager.userLocation
    }
    
    enum LoadingState {
        case none
        case fetching
        case completed
        case failed
    }
    
    @MainActor
    func fetchHears() async {
        guard let userLocation else { return }
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        
        loadingState = .fetching
        
        do {
            let overlappingGeohashes: [String] = container.services.geohashService.overlappingGeohash(
                latitude: latitude,
                longitude: longitude,
                precision: .twentyFourHundredMeters
            )
            
            let (models, lastDocumentID) = try await container.services.hearService.fetchAroundHears(
                latitude: latitude,
                longitude: longitude,
                radiusInMeter: 1000,
                inGeohashes: overlappingGeohashes,
                startAt: self.lastDocumentID,
                limit: 20
            )
            
            _ = await [fetchUserNicknames(hears), fetchMusicOfHears(hears)]
            
            self.hears.append(contentsOf: models)
            self.lastDocumentID = lastDocumentID
            
            loadingState = .completed
        } catch {
            loadingState = .failed
        }
    }
    
    private func fetchUserNicknames(_ hears: [HearModel]) async {
        let asyncHears = makeAsyncHears(hears)
        
        for await hear in asyncHears {
            if let userNickname = try? await container.services.userService.fetchUser(ofId: hear.userId)?.nickname {
                self.userNicknames[hear.id] = userNickname
            }
        }
    }
    
    private func fetchMusicOfHears(_ hears: [HearModel]) async {
        let asyncHears = makeAsyncHears(hears)
        
        for await hear in asyncHears {
            if let musics = try? await container.services.musicService.fetchMusic(ofIds: hear.musicIds) {
                self.musicOfHear[hear.id] = musics
            }
        }
    }
    
    private func makeAsyncHears(_ hears: [HearModel]) -> AsyncStream<HearModel> {
        AsyncStream<HearModel> { continuation in
            for hear in hears {
                continuation.yield(hear)
            }
            continuation.finish()
        }
    }

}
