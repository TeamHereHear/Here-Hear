//
//  WeatherChoiceButtonStyle.swift
//  Here-Hear
//
//  Created by 이원형 on 3/25/24.
//

import SwiftUI

struct WeatherChoiceButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .frame(width: 325, height: 65)
            .background(Color.gray.opacity(0.45))
            .foregroundColor(.white)
            .cornerRadius(50)
    }
}

extension View {
    func weatherChoiceButtonStyle() -> some View {
        self.modifier(WeatherChoiceButtonModifier())
    }
    
}
