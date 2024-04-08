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
    @Published var showFetchAroundHearButton: Bool = false
    
    private let container: DIContainer
    private var cancellables = Set<AnyCancellable>()
    private var lastFetchingCoordinate: CLLocationCoordinate2D = .seoulCityHall
    
    init(container: DIContainer) {
        self.container = container
        Task {
            let mapRect = await setInitialUserLocation()
            fetchHears(whenMapRectIs: mapRect)
            handleMapRectChange()
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
        self.lastFetchingCoordinate = mapRect.origin.coordinate
        
        return mapRect
    }
    
    private func fetchHears(whenMapRectIs rect: MKMapRect?) {
        guard let rect else { return }
        let coordinate = rect.origin.coordinate
        
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
            // TODO: 에러대응
        } receiveValue: { [weak self] hears in
            guard let self else { return }
            self.hears = hears
            self.lastFetchingCoordinate = coordinate
        }
        .store(in: &cancellables)
    }
    
    private func handleMapRectChange() {
        $mapRect
            .debounce(for: 1, scheduler: DispatchQueue.main)
            .map(\.origin.coordinate)
            .map { [weak self] coordinate in
                guard let self else { return false }
                return self.lastFetchingCoordinate.distanceInMeters(with: coordinate) >= 500
            }
            .assign(to: &$showFetchAroundHearButton)
    }
    
    func fetchAroundHears() {
        let coordinate = mapRect.origin.coordinate
        
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
            // TODO: 에러대응
        } receiveValue: { [weak self] hears in
            guard let self else { return }
            self.hears = hears
            self.lastFetchingCoordinate = coordinate
            self.showFetchAroundHearButton = false
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
