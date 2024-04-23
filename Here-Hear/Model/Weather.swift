//
//  Weather.swift
//  Here-Hear
//
//  Created by 이원형 on 2/21/24.
//

import SwiftUI

enum Weather: String, CaseIterable {
    case sunny, cloudy, rainy, snowy, windy, foggy, dusty
    
    var optionTitle: String {
        switch self {
        case .sunny:
            String(localized: "weather.optionTitle.sunny", defaultValue: "It's sunny")
        case .cloudy:
            String(localized: "weather.optionTitle.cloudy", defaultValue: "It's cloudy")
        case .rainy:
            String(localized: "weather.optionTitle.rainy", defaultValue: "It's rainy")
        case .snowy:
            String(localized: "weather.optionTitle.snowy", defaultValue: "It's snowy")
        case .windy:
            String(localized: "weather.optionTitle.windy", defaultValue: "It's windy")
        case .foggy:
            String(localized: "weather.optionTitle.foggy", defaultValue: "It's foggy")
        case .dusty:
            String(localized: "weather.optionTitle.dusty", defaultValue: "It's dusty")
        }
    }
    
    var imageName: String {
        switch self {
        case .sunny:
            "sun.max.fill"
        case .cloudy:
            "cloud"
        case .rainy:
            "cloud.rain"
        case .snowy:
            "snowflake"
        case .windy:
            "wind"
        case .foggy:
            "cloud.fog"
        case .dusty:
            "sun.dust"
        }
    }
    
    var color: Color {
        switch self {
        case .sunny:
                .weatherSunny
        case .cloudy:
                .weatherCloudy
        case .rainy:
                .weatherRainy
        case .snowy:
                .weatherSnowy
        case .windy:
                .weatherWindy
        case .foggy:
                .weatherFoggy
        case .dusty:
                .weatherDusty
        }   
    }
}

