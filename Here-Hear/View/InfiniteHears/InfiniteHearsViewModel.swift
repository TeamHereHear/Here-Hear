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
        //TODO: hear 하나를 받아오고 그 위치로부터 반경을 넓혀가며 보이는 것으로
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
             .minimumGeohashPrecisionLength(when: searchingRadius.meter) else {
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
                radiusInMeter: searchingRadius.meter,
                inGeohashes: overlappingGeohashes,
                startAt: self.lastDocumentID,
                limit: fetchingLimit
            )
            
            DispatchQueue.main.async {
                self.hears.append(contentsOf: models)
            }
            self.lastDocumentID = lastDocumentID
            
            if models.count == fetchingLimit {
                updateLoadingState(to: .none)
                return
            }
            
            if searchingRadius.expand() {
                updateLoadingState(to: .none)
                return
            }
            
            updateLoadingState(to: .fetchedAll)
            
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
