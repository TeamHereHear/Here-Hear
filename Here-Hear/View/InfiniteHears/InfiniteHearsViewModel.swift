//
//  InfiniteHearsViewModel.swift
//  Here-Hear
//
//  Created by Tyrell_07 on 5/21/24.
//

import Foundation
import Combine
import CoreLocation
import Logging

// TODO: 정책상 정해야하는 부분
enum InfiniteHearsSearchingRadius: Int {
    case fiveHundredMeters = 0
    case oneKillometer
    case twoKillometers
    case fiveKillometers
    case tenKillometers
    
    mutating func expand() -> Bool {
        guard self != .tenKillometers else { return false }
        guard let expanded = InfiniteHearsSearchingRadius(rawValue: self.rawValue + 1) else { return false }
        self = expanded
        return true
    }
    
    var meter: Double {
        switch self {
        case .fiveHundredMeters:
            500
        case .oneKillometer:
            1_000
        case .twoKillometers:
            2_000
        case .fiveKillometers:
            5_000
        case .tenKillometers:
            10_000
        }
    }
}

@Logging
class InfiniteHearsViewModel: ObservableObject {
    @Published var error: InfiniteHearsViewModelError?
    private var startingHear: HearModel?
    @Published var hears: [HearModel] = []
    
    @Published var loadingState: LoadingState = .none
    
    private var location: LocationModel
    @Published var searchingRadius: InfiniteHearsSearchingRadius = .fiveHundredMeters

    private let fetchingLimit: Int = 10
    private let container: DIContainer
    private var cancellables = Set<AnyCancellable>()
    private var lastDocumentID: String?
    
    init(container: DIContainer, hear: HearModel? = nil, location: LocationModel) {
        self.container = container
        self.location = location
        self.startingHear = hear

        if let hear {
            hears.append(hear)
        }
    }
    
    @MainActor
    private func updateLoadingState(to state: LoadingState) {
        self.loadingState = state
    }
    
    private func setError(_ error: InfiniteHearsViewModelError) {
        logger.error("\(error.localizedDescription)")
        self.error = error
    }
    
    @MainActor
    func fetchHears() async {
        guard loadingState != .fetchedAll else { return }
     
        guard let geohashPrecision = GeohashPrecision
             .minimumGeohashPrecisionLength(when: searchingRadius.meter) else {
            updateLoadingState(to: .failed)
            setError(.unknownUserLocation)
            return
        }
        
        updateLoadingState(to: .fetching)
        
        let latitude = location.latitude
        let longitude = location.longitude
        let overlappingGeohashes: [String] = container.services.geohashService.overlappingGeohash(
            latitude: latitude,
            longitude: longitude,
            precision: geohashPrecision
        )
        
        do {
            let (models, lastDocumentID) = try await container.services.hearService.fetchAroundHears(
                latitude: latitude,
                longitude: longitude,
                radiusInMeter: searchingRadius.meter,
                inGeohashes: overlappingGeohashes,
                startAt: self.lastDocumentID,
                excludingHear: startingHear?.id,
                limit: fetchingLimit
            )
            
            DispatchQueue.main.async {
                self.hears.append(contentsOf: models)
            }
            
            /// 범위를 늘려도 더이상 불러올게 없을 경우 lastDocumentID 가 nil 일 수 있으므로
            if let lastDocumentID {
                self.lastDocumentID = lastDocumentID
            }
            
            if models.count == fetchingLimit {
                updateLoadingState(to: .none)
                return
            }
            
            if searchingRadius.expand() {
                updateLoadingState(to: .none)
                await fetchHears()
                return
            }
            
            updateLoadingState(to: .fetchedAll)
            
        } catch {
            // TODO: 에러의 종류에 따라서 세분화 하기
            updateLoadingState(to: .failed)
            setError(.failedToFetchHears(error))
        }
        
    }
  
}

extension InfiniteHearsViewModel {
    enum LoadingState: Hashable {
        case none, fetching, fetchedAll, failed
    }
    
    enum InfiniteHearsViewModelError: Error {
        case failedToFetchHears(Error)
        case unknownUserLocation
        case unexpected
    }
}
