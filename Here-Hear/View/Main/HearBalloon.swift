//
//  HearBalloon.swift
//  Here-Hear
//
//  Created by Martin on 3/12/24.
//

import SwiftUI

struct HearBalloon: View {
    private let width: CGFloat = 185
    private let height: CGFloat = 63
    private let cornerRadius: CGFloat = 10
    private let tipHeight: CGFloat = 20
    
    private let albumArtWidth: CGFloat = 63
    
    var body: some View {
        HStack(spacing: 0) {
            albumArt
                .padding(.trailing, 5)
            
            informations
            
            Spacer()
        }
        .frame(width: width, height: height)
        .clipShape(.rect(cornerRadius: cornerRadius, style: .continuous))
        .padding(.bottom, tipHeight)
        .background {
            HearBalloonBackground(
                width: width,
                height: height,
                cornerRadius: cornerRadius,
                tipHeight: tipHeight
            )
        }
    }
    
    private var albumArt: some View {
        RemoteImage(
            path: "",
            isStorageImage: false,
            transitionDuration: 1) { ProgressView() }
            .frame(
                width: albumArtWidth,
                height: albumArtWidth
            )
            .background(.hhGray)
    }
    
    private var informations: some View {
        VStack(alignment: .leading, spacing: 0) {
            musicInfo
            
            hearInfo
        }
        .frame(width: 110)
    }
    
    @ViewBuilder
    private var musicInfo: some View {
        Text("I Like you")
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(.black)
        
        Text("Post Malone")
            .font(.system(size: 14, weight: .regular))
            .foregroundStyle(.white)
    }
    
    private var hearInfo: some View {
        HStack(spacing: 0) {
            Text("Wonhyeong")
                .foregroundStyle(.white)
            
            Spacer()
            
            Image(systemName: "heart.fill")
                .foregroundStyle(.hhAccent2)
                .padding(.trailing, 3)
            
            Text(120, format: .number)
                .foregroundStyle(.white)
        }
        .font(.system(size: 11, weight: .regular))
    }
}

private struct HearBalloonBackground: View {
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

#Preview {
    HearBalloon()
        .padding()
        .environmentObject(DIContainer(services: StubServices()))
}
