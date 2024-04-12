//
//  OpenInOtherMusicServiceView.swift
//  Here-Hear
//
//  Created by martin on 4/11/24.
//

import SwiftUI

struct OpenInOtherMusicServiceView: View {
    private let music: MusicModel
    
    init(music: MusicModel) {
        self.music = music
    }
    
    var body: some View {
        HStack {
            
            if let appleMusicIconImage = UIImage(named: "AppleMusicIcon"),
               let url = URL(string: "music://music.apple.com/kr/songs/1734500886?i=1734500896") {
                Button {
                    Task {
                        await UIApplication.shared.open(url)
                    }
                } label: {
                    VStack {
                        Image(uiImage: appleMusicIconImage)
                            .otherMusicServiceIconModifier()
                        Text("Apple Music")
                            .font(.caption)
                    }
                }
                
            }
            
            VStack {
                Image("SpotifyIcon")
                    .otherMusicServiceIconModifier()
                Text("Spotify")
                    .font(.caption)
            }
            
            VStack {
                Image("YoutubeMusicIcon")
                    .otherMusicServiceIconModifier()
                Text("Youtube Music")
                    .font(.caption)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.hhSecondary)
        .background(ignoresSafeAreaEdges: .all)
    }
}

extension Image {
    func otherMusicServiceIconModifier() -> some View {
        self
            .resizable()
            .aspectRatio(1, contentMode: .fit)
            .frame(width: 45)
            .frame(width: 75, height: 75)
            .background(.white, in: .circle)
    }
}

#Preview {
    OpenInOtherMusicServiceView(music: .onBoardingPageStubOne)
}
