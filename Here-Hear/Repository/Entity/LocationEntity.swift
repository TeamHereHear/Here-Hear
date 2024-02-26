//
//  LocationEntity.swift
//  Here-Hear
//
//  Created by Martin on 2/26/24.
//

import Foundation

struct LocationEntity: Codable {
    var latitude: Double
    var longitude: Double
    var geohashExact: String // 정확한 지오해쉬 (12글자) 거리 오차범위 ±0.000074 km == 74mm
    var geohash2: String // 지오해쉬 (2글자) 거리 오차범위 ±630 km
    var geohash3: String // 지오해쉬 (3글자) 거리 오차범위 ±78 km
    var geohash4: String // 지오해쉬 (4글자) 거리 오차범위 ±20 km
    var geohash5: String // 지오해쉬 (5글자) 거리 오차범위 ±2.4 km
    var geohash6: String // 지오해쉬 (6글자) 거리 오차범위 ±0.61 km == 610m
    var geohash7: String // 지오해쉬 (7글자) 거리 오차범위 ±0.076 km == 76m
    
    init?(latitude: Double, longitude: Double, geohashExact: String) {
        guard geohashExact.count == 12 else {
            return nil
        }
        
        self.latitude = latitude
        self.longitude = longitude
        self.geohashExact = geohashExact
        self.geohash2 = String(geohashExact.prefix(2))
        self.geohash3 = String(geohashExact.prefix(3))
        self.geohash4 = String(geohashExact.prefix(4))
        self.geohash5 = String(geohashExact.prefix(5))
        self.geohash6 = String(geohashExact.prefix(6))
        self.geohash7 = String(geohashExact.prefix(7))
    }
}

extension LocationEntity {
    func toModel() -> LocationModel {
        .init(
            latitude: latitude,
            longitude: longitude,
            geohashExact: geohashExact
        )
    }
}
