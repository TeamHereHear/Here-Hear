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
//        fetchHearsWhenMapRectChanges()
        fetchMockHears()
    }
    
    func fetchMockHears() {
        let calendar = Calendar.current
        self.hears = (1...10).map {
            let latitude: Double = Double.random(in: 37.413294..<37.715133)
            let longitude: Double = Double.random(in: 126.734086..<127.269311)
            let location: LocationModel = .init(
                latitude: latitude,
                longitude: longitude,
                geohashExact: container.services.geohashService.geohashExact(
                    latitude: latitude,
                    longitude: longitude
                )
            )
            
            let feelingModel: FeelingModel = .init(expressionText: "Mock \($0)")
            let weather: Weather? = Weather.allCases.randomElement()
            let hearModel: HearModel = .init(
                id: UUID().uuidString,
                userId: "\($0)",
                location: location,
                musicIds: [],
                feeling: feelingModel,
                like: $0,
                createdAt: calendar.date(byAdding: .day, value: -$0, to: .now) ?? .now,
                weather: weather
            )
            return hearModel
        }
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
                    radiusInMeter: 2000, // TODO: 정책상 어떻게 할지 정해야함
                    searchingIn: overlappedGeoHash
                )
                .eraseToAnyPublisher()
            }
            .sink { _ in
                
            } receiveValue: { [weak self] hears in
                guard let self else { return }
                DispatchQueue.main.async {
                    self.hears = hears
                }
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
