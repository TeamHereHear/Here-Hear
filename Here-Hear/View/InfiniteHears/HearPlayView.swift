//
//  HearPlayView.swift
//  Here-Hear
//
//  Created by Martin on 4/18/24.
//

import SwiftUI
import AVKit

struct HearPlayView: View {
    @StateObject var viewModel: HearPlayViewModel
    @Binding var currentIndex: Int
    let index: Int
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.videoData.hasVideo {
                playingMusicBarView
            }
            
            Spacer()
            
            buttons
            informationView
           
        }
        .background {
            if viewModel.videoData.hasVideo {
                if let videoPlayer = viewModel.videoPlayer {
                    Player(player: videoPlayer, loop: true)
                        .ignoresSafeArea()
                        .scaledToFill()
                        .allowsHitTesting(false)
                } else {
                    RemoteImage(
                        path: viewModel.thumbnailPath,
                        isStorageImage: true,
                        transitionDuration: 1
                    ) {
                        ProgressView()
                    }
                }
            } else {
                RemoteImage(
                    path: viewModel.musicData.music?.artwork?.absoluteString,
                    isStorageImage: false,
                    transitionDuration: 1
                ) {
                    ProgressView()
                }
                .scaledToFill()
                .clipped()
                .blur(radius: 20)
                .overlay {
                    VStack(alignment: .center) {
                        RemoteImage(
                            path: viewModel.musicData.music?.artwork?.absoluteString,
                            isStorageImage: false,
                            transitionDuration: 1
                        ) {
                            ProgressView()
                        }
                        .scaledToFit()
                        .clipShape(.rect(cornerRadius: 12, style: .continuous))
                        .frame(width: 280, height: 280)
                        .shadow(radius: 10)
                        
                        MarqueeText(viewModel.musicData.music?.title ?? "No Title")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.white)
                            .shadow(radius: 2)
                            .frame(width: 280, height: 28)
                
                        MarqueeText(viewModel.musicData.music?.artist ?? "No Artist")
                            .font(.body.weight(.regular))
                            .foregroundStyle(.white)
                            .shadow(radius: 2)
                            .frame(width: 280, height: 28)
                            .padding(.bottom, 56)
                    }
                    .frame(width: UIScreen.current?.bounds.width)
                }
            }
            
        }
        .task {
            await viewModel.fetchAllData()
            if index == 0 {
                await viewModel.playVideo()
                await viewModel.playMusic()
            }
        }
        .onChange(of: currentIndex) { value in
            if index == value {
                Task {
                    await viewModel.playVideo()
                    await viewModel.playMusic()
                }
            } else {
                viewModel.pausePlayer()
            }
        }
        .onDisappear(perform: {
            viewModel.cleanPlayer()
        })
      
    }
    
    @ViewBuilder
    private var progressBar: some View {
        if viewModel.videoData.hasVideo {
            if let progress = viewModel.videoData.videoProgress {
                HHProgressBar(value: progress)
                    .padding(.horizontal)
            }
        } else {
            if let progress = viewModel.musicData.musicPlayBackProgress {
                HHProgressBar(value: progress)
                    .padding(.horizontal)
                
            }
        }
    }
    
    @ViewBuilder
    private var playingMusicBarView: some View {
        if let music = viewModel.musicData.music {
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
        }
    }
    
    private var buttons: some View {
        VStack(spacing: 24) {
            Button {
                // TODO: - 노래 공유 바텀시트
            } label: {
                Image(systemName: "music.note")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.hhSecondary)
                    .shadow(radius: 5)
            }
            
            Button {
                // TODO: - 좋아요
            } label: {
                Image(systemName: "heart.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.hhSecondary)
                    .padding(.vertical, 12)
                    .overlay(alignment: .bottom) {
                        Text(viewModel.hear.like, format: .number)
                            .font(.system(size: 10))
                            .foregroundStyle(.white)
                    }
                    .shadow(radius: 5)
            }
        }
        .padding(.trailing, 12)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    private var informationView: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 5) {
                Circle()
                    .foregroundStyle(.hhGray)
                    .frame(width: 32, height: 32)
                
                Text(viewModel.userNickname ?? "")
                    .foregroundStyle(.white)
                    .font(.caption.weight(.bold))
                if let distance = viewModel.distance {
                    Text(Measurement<UnitLength>(value: distance, unit: .meters), format: .measurement(width: .abbreviated, usage: .general))
                        .foregroundStyle(.white)
                        .font(.caption2)
                }
                Text(viewModel.hear.createdAt, format: .dateTime)
                    .foregroundStyle(.white)
                    .font(.caption2)
                if let weather = viewModel.hear.weather {
                    Image(systemName: weather.imageName)
                        .foregroundStyle(weather.color)
                        .font(.body)
                    
                }
            }
            
            Text(viewModel.hear.feeling.expressionText ?? "")
                .foregroundStyle(.white)
                .padding(.leading, 55)
            VStack {
                progressBar
            }
            .frame(height: 20, alignment: .top)
        }
        .padding(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 160)
        .background {
            LinearGradient(
                stops: [.init(color: .clear, location: 0),
                        .init(color: .black, location: 2)
                ],
                startPoint: .init(x: 0.5, y: 0),
                endPoint: .init(x: 0.5, y: 1)
            )
        }
    }
}

#Preview {
    HearPlayView(viewModel: .init(container: .stub, hear: .onBoardingPageOneStub), currentIndex: .constant(1), index: 1)
        .environmentObject(
            DIContainer.stub
        )
}
