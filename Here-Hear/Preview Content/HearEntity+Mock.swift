//
//  HearEntity+Mock.swift
//  Here-Hear
//
//  Created by Martin on 2/22/24.
//

import Foundation
import CoreLocation

extension HearEntity {
    static var mock: HearEntity? {
        guard let location = LocationEntity(
            latitude: 37.566406,
            longitude: 126.977822,
            geohashExact: "wydm9qy2jtws"
        ) else {
            return nil
        }
        
        return .init(
            id: "1",
            userId: "user_1",
            location: location,
            musicIds: [],
            feeling: .mock,
            like: 120,
            createdAt: .distantPast,
            weather: "windy"
        )
    }
}
