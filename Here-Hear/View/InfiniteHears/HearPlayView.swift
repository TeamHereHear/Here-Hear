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
    
    var body: some View {
        ZStack {
            if let videoPlayer = viewModel.videoPlayer {
                Player(player: videoPlayer, loop: true)
                    .ignoresSafeArea()
                    .scaledToFill()
                    .allowsHitTesting(false)
            } else {
                RemoteImage(
                    path: "Thumbnails/\(viewModel.hear.id).jpg",
                    isStorageImage: true,
                    transitionDuration: 1
                ) {
                    ProgressView()
                }
            }
            VStack(spacing: 0) {
                progressBar
                
                topBar
                
                playingMusicView
                
                Spacer()
                
                buttons

                informationView
            }
            .frame(maxWidth: UIScreen.main.bounds.width)
            .ignoresSafeArea(edges: .bottom)
           
        }
        .task {
            await viewModel.fetchAllData()
        }
        .onDisappear {
            viewModel.cleanPlayer()
        }
    }
    
    @ViewBuilder
    private var progressBar: some View {
        if let progress = viewModel.videoProgress {
            HHProgressBar(value: progress)
                .padding(.horizontal)
        }
    }
    
    private var topBar: some View {
        HStack {
            Button {
                // TODO: 뒤로가기
            } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 25))
                    .foregroundStyle(.white)
            }
            if let weather = viewModel.hear.weather {
                Image(systemName: weather.imageName)
                    .foregroundStyle(weather.color)
                    .font(.system(size: 35))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 11)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var playingMusicView: some View {
        if let music = viewModel.viewData.music {
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
            }
            
            Button {
                // TODO: - 좋아요
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
    }
    
    private var informationView: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 5) {
                Circle()
                    .foregroundStyle(.hhGray)
                    .frame(width: 50, height: 50)
                    
                Text(viewModel.viewData.userNickname ?? "")
                    .foregroundStyle(.white)
                    .font(.caption.weight(.bold))
                Text("50m")
                    .foregroundStyle(.white)
                    .font(.caption2)
                Text(viewModel.hear.createdAt, format: .dateTime)
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
}

#Preview {
    HearPlayView(viewModel: .init(container: .stub, hear: .onBoardingPageOneStub))
        .environmentObject(
            DIContainer.stub
        )
}
