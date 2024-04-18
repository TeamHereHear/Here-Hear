//
//  HearPlayView.swift
//  Here-Hear
//
//  Created by Martin on 4/18/24.
//

import SwiftUI
import AVKit

struct HearPlayView: View {
    @State private var player: AVPlayer?
    private let music: MusicModel = .onBoardingPageStubOne
    private let fileUrl: URL? = Bundle.main.url(
        forResource: "OnBoardingPageTwoVideo",
        withExtension: "MOV"
    )
    
    var body: some View {
        ZStack {
            VideoPlayer(player: player)
                .ignoresSafeArea()
                .scaledToFill()
            VStack {
                HStack(spacing: 15) {
                    RemoteImage(
                        path: music.artwork?.absoluteString,
                        isStorageImage: false,
                        transitionDuration: 0.5
                    ) {
                        Rectangle()
                            .foregroundStyle(.hhGray)
                    }
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 85, height: 85)
                    .background(.hhGray)
                    .clipShape(.rect(cornerRadius: 11, style: .continuous))
                    
                    VStack(alignment: .leading) {
                        Text(music.title)
                        Text(music.artist)
                        if let album = music.album {
                            Text(album)
                        }
                    }
                    .lineLimit(1)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Material.ultraThin, in: .rect(cornerRadius: 21, style: .continuous))
                .padding(12)
                Spacer()
                
                VStack(spacing: 24) {
                    Button {
                        
                    } label: {
                        Image(systemName: "music.note")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.hhSecondary)
                    }
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(.hhSecondary)
                            .padding(.vertical, 12)
                            .overlay(alignment: .bottom) {
                                Text(100, format: .number)
                                    .font(.system(size: 10))
                                    .foregroundStyle(.white)
                            }
                    }
                }
                .padding(.trailing, 12)
                .frame(maxWidth: .infinity, alignment: .trailing)

                
                VStack(alignment: .leading) {
                    HStack(spacing: 5) {
                        Circle()
                            .foregroundStyle(.hhGray)
                            .frame(width: 50, height: 50)
                            
                        Text("User Nickname")
                            .foregroundStyle(.white)
                            .font(.caption.weight(.bold))
                        Text("50m")
                            .foregroundStyle(.white)
                            .font(.caption2)
                        Text("24.02.15")
                            .foregroundStyle(.white)
                            .font(.caption2)
                    }
                    
                    Text("행배야! 오늘 날씨 진짜 즥인다.")
                        .foregroundStyle(.white)
                        .padding(.leading, 55)
                }
                .padding(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 150)
                .background {
                    LinearGradient(
                        stops: [.init(color: .clear, location: 0),
                                .init(color: .black, location: 1)
                               ],
                        startPoint: .init(x: 0.5, y: 0),
                        endPoint: .init(x: 0.5, y: 1)
                    )
                }
                
            }
            .frame(maxWidth: UIScreen.main.bounds.width)

            .ignoresSafeArea(edges: .bottom)
           
            
            
            
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
    HearPlayView()
        .environmentObject(
            DIContainer(
                services: StubServices(),
                managers: StubManagers()
            )
        )
}
