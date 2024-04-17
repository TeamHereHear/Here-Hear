//
//  HearResultView.swift
//  Here-Hear
//
//  Created by 이원형 on 3/26/24.
//

import SwiftUI
import AVKit

struct FinalSummaryHearView: View {
    @Binding var videoURL: URL?
    @Binding var selectedSong: MusicModel?
    @Binding var selectedWeather: WeatherOption?
    @EnvironmentObject var cameraViewModel: CameraViewModel
    @StateObject var hearViewModel = HearViewModel()
    @EnvironmentObject private var container: DIContainer

    var musicPlayer = AVPlayer()
    
    var body: some View {
        ZStack {
            if let videoURL = videoURL {
                Player(player: AVPlayer(url: videoURL), loop: true)
                    .ignoresSafeArea(.all)
            } else {
                Color("HHTertiary")
                    .edgesIgnoringSafeArea(.all)
            }
            VStack {
                Spacer()
                VStack(spacing: 16) {
                     // 아트워크 이미지
                     if let artworkURL = selectedSong?.artwork {
                         AsyncImage(url: artworkURL) { image in
                             image
                                 .resizable()
                         } placeholder: {
                             ProgressView()
                         }
                         .frame(width: 85, height: 85)
                         .cornerRadius(10)
                     }

                     // 음악 제목
                     Text(selectedSong?.title ?? "제목 없음")
                        .font(.headline)
                         .fontWeight(.bold)
                         .foregroundColor(.white)
                         .shadow(radius: 10)

                    // 앨범
                    Text(selectedSong?.album ?? "")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .shadow(radius: 10)
                    
                     // 아티스트 이름
                     Text(selectedSong?.artist ?? "아티스트 정보 없음")
                         .font(.headline)
                         .foregroundColor(.white)
                         .shadow(radius: 10)
                    
                     // 날씨 정보
                     HStack {
                         Image(systemName: selectedWeather?.systemImage ?? "questionmark.circle")
                             .resizable()
                             .scaledToFit()
                             .frame(width: 30, height: 30)
                             .foregroundColor(selectedWeather?.color ?? .white)
                         
                         Text(selectedWeather?.title ?? "날씨 정보 없음")
                             .foregroundColor(.white)
                             .shadow(radius: 10)
                     }
                    // Hear 저장하기
                 }
                .padding()
                .background(Color.gray.opacity(0.35))
                .cornerRadius(10)
                .shadow(radius: 10)
                
                Spacer()

                HStack {
                    Spacer()
                    Button(action: {
                        hearViewModel.selectedSong = selectedSong
                        hearViewModel.selectedWeather = selectedWeather
                        hearViewModel.videoURL = videoURL
                        
                        hearViewModel.saveHearToFirebase()
                        
                    }) {
                        Text("내 Hear 저장하기")
                            .font(.headline)
                            .foregroundColor(.white)
                            .shadow(radius: 10)
                            .padding()
                    }
                    .padding([.bottom, .trailing], 15)
                    .padding(.bottom, 5)
                    
                    NavigationLink(
                        destination: MainView(viewModel: MainViewModel(container: container)).navigationBarBackButtonHidden(true),
                        isActive: $hearViewModel.isSaveCompleted
                    ) { EmptyView() }

                }
            }
         }
        .onAppear {
            if let previewURL = selectedSong?.previewURL {
                musicPlayer .replaceCurrentItem(with: AVPlayerItem(url: previewURL))
                musicPlayer.play()
            }
        }
        .onDisappear {
            musicPlayer.pause()
        }
     }
 }
