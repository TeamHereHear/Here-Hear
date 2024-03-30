//
//  HearModel+Mock.swift
//  Here-Hear
//
//  Created by Martin on 3/19/24.
//

import Foundation

extension HearModel {
    static var mocks: [HearModel] {
        let calendar = Calendar.current
        return [
            .init(
                id: "mock1",
                userId: "mockUser1",
                location: .init(latitude: 37.5110483, longitude: 127.0592780, geohashExact: "wydm7k9txy0t"),
                musicIds: [],
                feeling: .init(expressionText: "코엑스 별마당 도서관 여기서 듣고 있어요"),
                like: 5,
                createdAt: calendar.date(byAdding: .day, value: -7, to: .now) ?? .now,
                weather: .cloudy
            ),
            .init(
                id: "mock2",
                userId: "mockUser2",
                location: .init(latitude: 37.508033, longitude: 127.051945, geohashExact: "wydm7hhkhuhs"),
                musicIds: [],
                feeling: .init(expressionText: "선정릉에서 가벼운 산책"),
                like: 50,
                createdAt: calendar.date(byAdding: .day, value: -1, to: .now) ?? .now,
                weather: .cloudy
            ),
            .init(
                id: "mock3",
                userId: "mockUser3",
                location: .init(latitude: 37.5147486, longitude: 127.0568445, geohashExact: "wydm7jrgr01d"),
                musicIds: [],
                feeling: .init(expressionText: "점심시간에 봉은사 산책하기 딱 좋네"),
                like: 15,
                createdAt: calendar.date(byAdding: .day, value: -5, to: .now) ?? .now,
                weather: .sunny
            ),
        ]
    }
}
