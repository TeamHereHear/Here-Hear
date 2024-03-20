//
//  MainViewModel.swift
//  Here-Hear
//
//  Created by Martin on 3/20/24.
//

import Foundation
import MapKit

final class MainViewModel: ObservableObject {
    @Published var region: MKCoordinateRegion = .init(
        center: .seoulCityHall,
        latitudinalMeters: MainViewModel.basicRegionDistance,
        longitudinalMeters: MainViewModel.basicRegionDistance
    )
    
    private let container: DIContainer
    
    init(container: DIContainer) {
        self.container = container
        container.managers.userLocationManager.locationPublisher.map { location in
            guard let location else {
                return MKCoordinateRegion(
                    center: .seoulCityHall,
                    latitudinalMeters: Self.basicRegionDistance,
                    longitudinalMeters: Self.basicRegionDistance
                )
            }
            
            return MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: Self.basicRegionDistance,
                longitudinalMeters: Self.basicRegionDistance
            )
        }
        .assign(to: &$region)
    }
}

extension MainViewModel {
    static let basicRegionDistance: CLLocationDistance = 0.05
}

extension CLLocationCoordinate2D {
    static var seoulCityHall: CLLocationCoordinate2D {
        .init(latitude: 37.5652351, longitude: 126.9781868)
    }
}
