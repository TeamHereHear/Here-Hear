//
//  HearBalloonBackground.swift
//  Here-Hear
//
//  Created by Martin on 3/13/24.
//

import SwiftUI

struct HearBalloonBackground: View {
    private let width: CGFloat
    private let height: CGFloat
    private let cornerRadius: CGFloat
    private let tipHeight: CGFloat
    
    init(
        width: CGFloat,
        height: CGFloat,
        cornerRadius: CGFloat,
        tipHeight: CGFloat
    ) {
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
        self.tipHeight = tipHeight
    }
    
    var body: some View {
        Path { path in
            path.addRoundedRect(
                in: .init(x: 0, y: 0, width: width, height: height),
                cornerSize: .init(width: cornerRadius, height: cornerRadius),
                style: .continuous
            )
            
            path.move(to: .init(x: width / 2, y: height + tipHeight))
            
            path.addLine(
                to: .init(
                    x: (width / 2) - (tipHeight / 2),
                    y: height
                )
            )
            
            path.addLine(
                to: .init(
                    x: (width / 2) + (tipHeight / 2),
                    y: height
                )
            )
            
            path.closeSubpath()
        }
        .foregroundStyle(.hhSecondary)
    }
}
