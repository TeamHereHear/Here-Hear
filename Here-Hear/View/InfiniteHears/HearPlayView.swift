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
    @State private var progress: CGFloat?
    private let hear: HearModel
    private let music: MusicModel = .onBoardingPageStubOne
    private let fileUrl: URL? = Bundle.main.url(
        forResource: "OnBoardingPageTwoVideo",
        withExtension: "MOV"
    )
    
    init(hear: HearModel) {
        self.hear = hear
    }
    
    var body: some View {
        ZStack {
            if let player {
                Player(player: player, loop: true)
                    .ignoresSafeArea()
                    .scaledToFill()
                    .allowsHitTesting(false)
            }
            VStack(spacing: 0) {
                if let progress {
                    HHProgressBar(value: progress)
                        .padding(.horizontal)
                }
                
                HStack {
                    Button {
                        
                    } label: {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 25))
                            .foregroundStyle(.white)
                    }
                    if let weather = hear.weather {
                        Image(systemName: weather.imageName)
                            .foregroundStyle(weather.color)
                            .font(.system(size: 35))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 11)
                .padding(.horizontal)
                
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
                            .font(.headline)
                        Text(music.artist)
                            .font(.caption)
                            .foregroundStyle(Color(hexString: "757575"))
                        if let album = music.album {
                            Text(album)
                                .font(.caption)
                                .foregroundStyle(Color(hexString: "757575"))
                        }
                    }
                    .lineLimit(1)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Material.thin, in: .rect(cornerRadius: 21, style: .continuous))
                .padding(.horizontal, 12)
                
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
        .task {
            guard let fileUrl else { return }
            player = AVPlayer(url: fileUrl)
           
            player?.isMuted = true
            
            player?.play()
            
            let interval = CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            let totalTime = try? await player?.currentItem?.asset.load(.duration)
            player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { time in
                let currentTimeSeconds = CMTimeGetSeconds(time)
                if let totalTime {
                    let totalTimeSeconds = CMTimeGetSeconds(totalTime)
                    self.progress = CGFloat(currentTimeSeconds) / CGFloat(totalTimeSeconds)
                }
            }
            
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }
}

#Preview {
    HearPlayView(hear: .onBoardingPageOneStub)
        .environmentObject(
            DIContainer(
                services: StubServices(),
                managers: StubManagers()
            )
        )
}
