//
//  WeatherSystemImageModifier.swift
//  Here-Hear
//
//  Created by 이원형 on 3/25/24.
//

import SwiftUI

struct WeatherSystemImageModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 24)
    }
}

