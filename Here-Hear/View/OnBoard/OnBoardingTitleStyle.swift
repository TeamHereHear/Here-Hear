//
//  OnBoardingTitleStyle.swift
//  Here-Hear
//
//  Created by Martin on 3/14/24.
//

import SwiftUI

struct OnBoardingTitleStyle: ViewModifier {
    private let fontSize: CGFloat = 31
    private let horizontalPadding: CGFloat = 21
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.system(size: fontSize, weight: .semibold))
            .foregroundStyle(.hhAccent)
            .padding(.horizontal, horizontalPadding)
    }
}

extension View {
    func onBoadingTitleStyle() -> some View {
        modifier(OnBoardingTitleStyle())
    }
}
