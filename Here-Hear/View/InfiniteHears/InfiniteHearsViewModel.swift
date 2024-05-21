//
//  InfiniteHearsViewModel.swift
//  Here-Hear
//
//  Created by Tyrell_07 on 5/21/24.
//

import Foundation
import Combine
import CoreLocation

// TODO: 정책상 정해야하는 부분
enum InfiniteHearsSearchingRadius: Double {
    case fiveHundredMeters = 500
    case oneKillometer = 1_000
    case twoKillometers = 2_000
    case fiveKillometers = 5_000
    case tenKillometers = 10_000
}

class InfiniteHearsViewModel: ObservableObject {
    @Published var hears: [HearModel] = []
    @Published var loadingState: LoadingState = .none
    @Published var userLocation: CLLocation? // Published 값이 아니어도 될지 살펴보기
    
    @Published var searchingRadius: InfiniteHearsSearchingRadius = .fiveHundredMeters

    private let fetchingLimit: Int = 10
    private let container: DIContainer
    private var cancellables = Set<AnyCancellable>()
    private var lastDocumentID: String?
    
    init(container: DIContainer) {
        self.container = container
        self.userLocation = container.managers.userLocationManager.userLocation
    }
    
    @MainActor
    private func updateLoadingState(to state: LoadingState) {
        self.loadingState = state
    }
    
    @MainActor
    func fetchHears() async {
        guard loadingState != .fetchedAll else { return }
        guard let userLocation else {
            updateLoadingState(to: .failed(.unknownUserLocation))
            return
        }
        guard let geohashPrecision = GeohashPrecision
             .minimumGeohashPrecisionLength(when: searchingRadius.rawValue) else {
            updateLoadingState(to: .failed(.unexpected))
            return
        }
        
        updateLoadingState(to: .fetching)
        
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        let overlappingGeohashes: [String] = container.services.geohashService.overlappingGeohash(
            latitude: latitude,
            longitude: longitude,
            precision: geohashPrecision
        )
        
        do {
            let (models, lastDocumentID) = try await container.services.hearService.fetchAroundHears(
                latitude: latitude,
                longitude: longitude,
                radiusInMeter: searchingRadius.rawValue,
                inGeohashes: overlappingGeohashes,
                startAt: self.lastDocumentID,
                limit: fetchingLimit
            )
            
            DispatchQueue.main.async {
                self.hears.append(contentsOf: models)
            }
            self.lastDocumentID = lastDocumentID
            
            updateLoadingState(to: models.count == fetchingLimit ? .none : .fetchedAll)
            // TODO: .fetchedAll 일경우 범위를 늘려서 탐색을 해야함
            
        } catch {
            // TODO: 에러의 종류에 따라서 세분화 하기
            updateLoadingState(to: .failed(.unexpected))
        }
        
    }
    
}

extension InfiniteHearsViewModel {
    enum LoadingState: Hashable {
        case none, fetching, fetchedAll, failed(InfiniteHearsViewModelError)
    }
    
    enum InfiniteHearsViewModelError: Error {
        case failedToFetchHears
        case unknownUserLocation
        case unexpected
    }
}
