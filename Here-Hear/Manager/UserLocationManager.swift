//
//  UserLocationManager.swift
//  Here-Hear
//
//  Created by Martin on 3/20/24.
//

import Foundation
import CoreLocation

protocol UserLocationManagerProtocol {
    var authorizationStatusPublisher: Published<CLAuthorizationStatus?>.Publisher { get }
    var locationPublisher: Published<CLLocation?>.Publisher { get }
}

class UserLocationManager: NSObject, CLLocationManagerDelegate, ObservableObject, UserLocationManagerProtocol {
    @Published private var authorizationStatus: CLAuthorizationStatus?
    var authorizationStatusPublisher: Published<CLAuthorizationStatus?>.Publisher {
        $authorizationStatus
    }
    
    @Published private var location: CLLocation?
    var locationPublisher: Published<CLLocation?>.Publisher {
        $location
    }
    
    
    private let manager: CLLocationManager = .init()
    
    override init() {
        super.init()
        manager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.first else { return }
        self.location = currentLocation
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print(error.localizedDescription)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            manager.requestLocation()
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        default:
            break
        }
    }
}

final class StubUserLocationManager: UserLocationManagerProtocol {
    @Published private var authorizationStatus: CLAuthorizationStatus?
    var authorizationStatusPublisher: Published<CLAuthorizationStatus?>.Publisher {
        $authorizationStatus
    }
    
    @Published private var location: CLLocation?
    var locationPublisher: Published<CLLocation?>.Publisher {
        $location
    }
}
