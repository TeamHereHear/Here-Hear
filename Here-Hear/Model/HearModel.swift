//
//  HearModel.swift
//  Here-Hear
//
//  Created by 이원형 on 2/20/24.
//

import Foundation
import CoreLocation

struct HearModel {
    var id: String
    var userId: String
    var coordinate: CLLocationCoordinate2D
    var music: MusicModel
    var feeling: FeelingModel
    var like: Int
    var createdAt: Date
    var weather: Weather?
}

extension HearModel {
    func toEntity() -> HearEntity {
        .init(
            id: id,
            userId: userId,
            coordinate: .init(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            ),
            music: music.toEntity(),
            feeling: feeling.toEntity(),
            like: like,
            createdAt: createdAt
        )
    }
}
