//
//  MainViewModel.swift
//  Here-Hear
//
//  Created by Martin on 3/20/24.
//

import Foundation
import MapKit
import Combine

final class MainViewModel: ObservableObject {
    @Published var mapRect: MKMapRect = .init(
        origin: .init(.seoulCityHall),
        size: .init(width: 500, height: 500)
    )
    
    @Published var region: MKCoordinateRegion = .init(
        center: .seoulCityHall,
        latitudinalMeters: MainViewModel.basicRegionDistance,
        longitudinalMeters: MainViewModel.basicRegionDistance
    )
    
    @Published var hears: [HearModel] = []
    
    private let container: DIContainer
    private var cancellables = Set<AnyCancellable>()
    
    init(container: DIContainer) {
        self.container = container
        subscribeUserLocation()
        fetchHearsWhenMapRectChanges()
    }
    
    private func subscribeUserLocation() {
        container.managers.userLocationManager.locationPublisher
            .map { location in
                MKMapRect(origin: .init(location?.coordinate ?? .seoulCityHall), size: Self.basicMapSize)
            }
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            } receiveValue: { mapRect in
                    self.mapRect = mapRect
            }
            .store(in: &cancellables)
    }
    
    private func fetchHearsWhenMapRectChanges() {
        $mapRect
            .debounce(for: 1, scheduler: RunLoop.main)
            .flatMap { [weak self] rect in
                guard let self else {
                    return Just([HearModel]()).setFailureType(to: ServiceError.self).eraseToAnyPublisher()
                }
                
                return self.fetchHears(whenMapRectIs: rect)
            }
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            } receiveValue: { [weak self] hears in
                guard let self else { return }
                self.hears = hears
            }
            .store(in: &cancellables)
    }
    
    private func fetchHears(whenMapRectIs rect: MKMapRect) -> AnyPublisher<[HearModel], ServiceError> {
        let coordinate = rect.origin.coordinate
        let mapWidthInMeter = rect.width / Double(10)
        
        let overlappedGeoHash = container.services.geohashService.overlappingGeohash(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            precision: .twentyFourHundredMeters
        )
        return container.services.hearService.fetchAroundHears(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            radiusInMeter: 1000, // TODO: 정책상 어떻게 할지 정해야함
            searchingIn: overlappedGeoHash
        )
        .eraseToAnyPublisher()
    }
}

extension MainViewModel {
    static let basicRegionDistance: CLLocationDistance = 1
    static let basicMapSize: MKMapSize = .init(width: 500, height: 500)
}

extension CLLocationCoordinate2D {
    static var seoulCityHall: CLLocationCoordinate2D {
        .init(latitude: 37.5652351, longitude: 126.9781868)
    }
}
