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
    var coordinate: Coordinate
    var music: MusicEntity
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
            coordinate: .init(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            ),
            music: music.toModel(),
            feeling: feeling.toModel(),
            like: like,
            createdAt: createdAt,
            weather: .init(rawValue: weather ?? "sunny")
        )
    }
}

extension HearEntity {
    struct Coordinate: Codable {
        var latitude: Double
        var longitude: Double
    }
}
