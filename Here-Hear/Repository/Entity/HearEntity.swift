//
//  HearEntity.swift
//  Here-Hear
//
//  Created by 이원형 on 2/20/24.
//

import Foundation
import CoreLocation

struct HearEntity: Codable {
    var id: String
    var userId: String
    var location: LocationEntity
    var musicIds: [String]
    var feeling: FeelingEntity
    var like: Int
    var createdAt: Date
    var weather: String?
    
}

extension HearEntity {
    func toModel() -> HearModel {
        .init(
            id: id,
            userId: userId,
            location: location.toModel(),
            musicIds: musicIds,
            feeling: feeling.toModel(),
            like: like,
            createdAt: createdAt,
            weather: .init(rawValue: weather ?? "sunny")
        )
    }
}
