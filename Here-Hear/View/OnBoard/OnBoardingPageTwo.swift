//
//  OnBoardingPageTwo.swift
//  Here-Hear
//
//  Created by Martin on 3/14/24.
//

import SwiftUI
import AVKit

struct OnBoardingPageTwo: View {
    @Binding private var tabSelection: Int
    @State private var player: AVPlayer?
    private let fileUrl: URL? = Bundle.main.url(
        forResource: "OnBoardingPageTwoVideo",
        withExtension: "MOV"
    )
    
    init(_ tabSelection: Binding<Int>) {
        self._tabSelection = tabSelection
    }
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 85)
            
            VideoPlayer(player: player)
                .scaleEffect(CGSize(width: 3.0, height: 3.0))
                .offset(x: 100)
                .clipShape(.rect(cornerRadius: 30, style: .continuous))
                .frame(width: 352, height: 352)
                .allowsHitTesting(false)
            
            Spacer()
                .frame(height: 37)
            
            Text("onBoardingPageTwo.title")
                .onBoadingTitleStyle()
            
            Spacer()
            
            HStack {
                Spacer()
                Button {
                    withAnimation(.linear) {
                        tabSelection += 1
                    }
                } label: {
                    Text("onBoadingPageTwo.Next")
                        .font(.system(size: 19, weight: .semibold))
                }
            }
            .padding(.horizontal, 21)
        }
        .onAppear {
            guard let fileUrl else { return }
            player = AVPlayer(url: fileUrl)
            player?.isMuted = true
            player?.play()
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }
}

#Preview {
    OnBoardingPageTwo(.constant(1))
}
