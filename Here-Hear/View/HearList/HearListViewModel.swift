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
    private var hears: [HearModel] = [] {
        didSet {
            sortedHears = sortHears(by: sortingOrder, hears)
        }
    }
    @Published var sortingOrder: SortingOrder = .nearest {
        didSet {
            sortedHears = sortHears(by: sortingOrder, hears)
        }
    }
    @Published var sortedHears: [HearModel] = []
    var userNicknames: [String: String] = [:] // @Published 를 제거해도 잘 동작하는지 살펴볼 것
    var musicOfHear: [String: [MusicModel]] = [:]
    
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
    
    @MainActor
    public func fetchHears() async {
        guard let userLocation else { return }
        let fetchingLimit: Int = 20
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
                limit: fetchingLimit
            )
            
            _ = await [fetchUserNicknames(models), fetchMusicOfHears(models)]
            
            DispatchQueue.main.async {
                self.hears.append(contentsOf: models)
            }
            self.lastDocumentID = lastDocumentID
            
            loadingState = models.count == fetchingLimit ? .none : .completed
        } catch {
            loadingState = .failed
        }
    }
    
    public func distanceOfHear(_ hear: HearModel) -> Double? {
        guard let userCoordinate = userLocation?.coordinate else { return nil }
        let hearCoordinate: CLLocationCoordinate2D = .init(geohash: hear.location.geohashExact)
        return userCoordinate.distanceInMeters(with: hearCoordinate)
    }
    
    private func fetchUserNicknames(_ hears: [HearModel]) async {
        let asyncHears = makeAsyncHears(hears)
        
        for await hear in asyncHears {
            print("asyncHears")
            if let userNickname = try? await container.services.userService.fetchUser(ofId: hear.userId)?.nickname {
                DispatchQueue.main.async {
                    self.userNicknames[hear.id] = userNickname
                }
            }
        }
    }
    
    private func fetchMusicOfHears(_ hears: [HearModel]) async {
        let asyncHears = makeAsyncHears(hears)
        
        for await hear in asyncHears {
            if let musics = try? await container.services.musicService.fetchMusic(ofIds: hear.musicIds) {
                DispatchQueue.main.async {
                    self.musicOfHear[hear.id] = musics
                }
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

extension HearListViewModel {
    enum LoadingState {
        case none
        case fetching
        case completed
        case failed
    }
}

// MARK: Sorting
extension HearListViewModel {
    enum SortingOrder: String, CaseIterable {
        case nearest
        case mostLiked
        case newest
        case oldest
        
        var localizedName: String {
            switch self {
            case .nearest:
                String(localized: "hearListView.sorting.order.nearest")
            case .mostLiked:
                String(localized: "hearListView.sorting.order.most.liked")
            case .newest:
                String(localized: "hearListView.sorting.order.newest")
            case .oldest:
                String(localized: "hearListView.sorting.order.oldest")
            }
        }
    }
    
    func sortHears(by sortingOrder: SortingOrder, _ hears: [HearModel]) -> [HearModel] {
        switch sortingOrder {
        case .nearest:
            sortHearsByDistance(hears)
        case .mostLiked:
            sortHearsByLike(hears)
        case .newest:
            sortHearsByDescendingTime(hears)
        case .oldest:
            sortHearsByAscendingTime(hears)
        }
    }
    
    func sortHearsByDistance(_ hears: [HearModel]) -> [HearModel] {
        hears.sorted {
            guard let userCoordinate = userLocation?.coordinate else { return true }
            let coordinate0 = CLLocationCoordinate2D(latitude: $0.location.latitude, longitude: $0.location.longitude)
            let coordinate1 = CLLocationCoordinate2D(latitude: $1.location.latitude, longitude: $1.location.longitude)
            return userCoordinate.distanceInMeters(with: coordinate0) <= userCoordinate.distanceInMeters(with: coordinate1)
        }
    }
    
    func sortHearsByLike(_ hears: [HearModel]) -> [HearModel] {
        hears.sorted { $0.like >= $1.like }
    }
    
    func sortHearsByDescendingTime(_ hears: [HearModel]) -> [HearModel] {
        hears.sorted { $0.createdAt >= $1.createdAt }
    }
    
    func sortHearsByAscendingTime(_ hears: [HearModel]) -> [HearModel] {
        hears.sorted { $0.createdAt <= $1.createdAt }
    }
}
