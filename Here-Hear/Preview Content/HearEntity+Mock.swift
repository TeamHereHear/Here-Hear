//
//  HearEntity+Mock.swift
//  Here-Hear
//
//  Created by Martin on 2/22/24.
//

import Foundation
import CoreLocation

extension HearEntity {
    static var mock: HearEntity {
        .init(
            id: "1",
            userId: "user_1",
            coordinate: .init(latitude: 33, longitude: 100),
            music: .mock,
            feeling: .mock,
            like: 120,
            createdAt: .distantPast,
            weather: "windy"
        )
    }
}
