//
//  CLLocationCoordinate2D+Extension.swift
//  Here-Hear
//
//  Created by Martin on 4/3/24.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        (lhs.latitude == rhs.latitude) && (rhs.longitude == rhs.longitude)
    }
    
    func distanceInMeters(with other: CLLocationCoordinate2D) -> Double {
        let location: CLLocation = .init(latitude: self.latitude, longitude: self.longitude)
        let comparingLocation: CLLocation = .init(latitude: other.latitude, longitude: other.longitude)
        return location.distance(from: comparingLocation)
    }
}
