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
    var location: LocationModel
    var musicIds: [String]
    var feeling: FeelingModel
    var like: Int
    var createdAt: Date
    var weather: Weather?
}

extension HearModel {
    func toEntity() -> HearEntity? {
        guard let locationEntity = location.toEntity() else {
            return nil
        }
        
        return .init(
            id: id,
            userId: userId,
            location: locationEntity,
            musicIds: musicIds,
            feeling: feeling.toEntity(),
            like: like,
            createdAt: createdAt
        )
    }
}
