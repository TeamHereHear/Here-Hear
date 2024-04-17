//
//  HearModel.swift
//  Here-Hear
//
//  Created by 이원형 on 2/20/24.
//

import Foundation
import CoreLocation

struct HearModel: Identifiable {
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
    
    static let onBoardingPageOneStub: HearModel = .init(
        id: "3",
        userId: "5",
        location: .init(
            latitude: 37.773619,
            longitude: -122.418793,
            geohashExact: "aaaaaa"
        ),
        musicIds: ["10"],
        feeling: .init(expressionText: String(localized: "hearModel.onBoardingPageOneStub.feeling.expressionText")),
        like: 400,
        createdAt: .now
    )
}
