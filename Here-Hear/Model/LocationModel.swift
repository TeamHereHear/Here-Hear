//
//  LocationModel.swift
//  Here-Hear
//
//  Created by Martin on 2/26/24.
//

import Foundation

struct LocationModel {
    var latitude: Double
    var longitude: Double
    var geohashExact: String // 정확한 지오해쉬 (12글자) 거리 오차범위 ±0.000074 km == 74mm
}

extension LocationModel {
    func toEntity() -> LocationEntity? {
        .init(
            latitude: latitude,
            longitude: longitude,
            geohashExact: geohashExact
        )
    }
}
