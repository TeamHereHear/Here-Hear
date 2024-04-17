//
//  LoginButtonStyle.swift
//  Here-Hear
//
//  Created by 이원형 on 2/24/24.
//

import SwiftUI

struct LoginButtonStyle: ButtonStyle {
    
    let textColor: Color
    let borderColor: Color
    let backgroundColor: Color
    
    init(textColor: Color, borderColor: Color? = nil, backgroundColor: Color? = nil) {
        self.textColor = textColor
        self.borderColor = borderColor ?? .white
        self.backgroundColor = backgroundColor ?? .white
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity, maxHeight: 45)
            .background(backgroundColor)
            .cornerRadius(5)
            .padding(.horizontal, 40)
            .opacity(configuration.isPressed ? 0.5 : 1)
    }

}
