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
        Task {
            let mapRect = await setInitialUserLocation()
            fetchHears(whenMapRectIs: mapRect)
        }
    }
    
    @MainActor
    private func setInitialUserLocation() -> MKMapRect? {
        guard let location = container.managers.userLocationManager.userLocation else {
            self.mapRect = .init(origin: .init(.seoulCityHall), size: Self.basicMapSize)
            return nil
        }
        let mapRect: MKMapRect = .init(origin: .init(location.coordinate), size: Self.basicMapSize)
        self.mapRect = mapRect
        return mapRect
    }
    
    func fetchHears(whenMapRectIs rect: MKMapRect?) {
        guard let rect else { return }
        let coordinate = rect.origin.coordinate
        let mapWidthInMeter = rect.width / Double(10)
        
        let overlappedGeoHash = container.services.geohashService.overlappingGeohash(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            precision: .twentyFourHundredMeters
        )
        container.services.hearService.fetchAroundHears(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            radiusInMeter: 1000, // TODO: 정책상 어떻게 할지 정해야함
            searchingIn: overlappedGeoHash
        )
        .receive(on: DispatchQueue.main)
        .sink { _ in
            
        } receiveValue: { hears in
            self.hears = hears
        }
        .store(in: &cancellables)
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
