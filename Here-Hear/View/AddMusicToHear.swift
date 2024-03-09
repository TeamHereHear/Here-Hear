//
//  AddMusicToHear.swift
//  Here-Hear
//
//  Created by 이원형 on 3/2/24.
//

import SwiftUI

struct AddMusicToHear: View {
    @StateObject private var musicViewModel = MusicViewModel()
    @State private var showingVideoCapture = false
    @State private var videoURL: URL?

    var body: some View {
        NavigationView { // NavigationView 시작
            VStack(alignment: .leading) { // VStack 시작
                
                // 옵셔널로 표시된 텍스트 제목
                // Text("우선, 다른 사람들과 공유할 음악을 찾아 볼까요?")
                // .font(.title)
                // .padding(.leading)
                if musicViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    List(musicViewModel.songs) { song in // List 시작
                        Button(action: {
                            // 노래 선택 시 카메라 인터페이스 표시
                            showingVideoCapture = true
                        }) {
                            HStack { // HStack 시작
                                AsyncImage(url: song.artwork) { phase in // AsyncImage 시작
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                            .frame(width: 70, height: 70)
                                    case .success(let image):
                                        image.resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 70, height: 70)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    case .failure:
                                        Image(systemName: "photo")
                                            .frame(width: 70, height: 70)
                                    @unknown default:
                                        EmptyView()
                                    } // switch 종료
                                } // AsyncImage 종료
                                VStack(alignment: .leading) { // VStack 시작
                                    Text(song.title)
                                        .lineLimit(1)
                                        .font(.title3)
                                    Text(song.artist)
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                } // VStack 종료
                                Spacer()
                                if let previewUrl = song.previewURL {
                                    Button(action: {
                                        musicViewModel.pauseMusic(url: previewUrl)
                                    }) {
                                        Image(systemName: musicViewModel.currentlyPlayingURL == previewUrl ? "pause.circle" : "play.circle")
                                            .resizable()
                                            .frame(width: 25, height: 25)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                } // if let 종료
                            } // HStack 종료
                            if let previewUrl = song.previewURL, musicViewModel.currentlyPlayingURL == song.previewURL {
                                ProgressView(value: min(max(musicViewModel.playbackProgress, 0), 1))
                                    .progressViewStyle(LinearProgressViewStyle(tint: Color("HHAccent2")))
                            }
                        } // Button 종료
                    } // List 종료 //List
                    .navigationTitle("우선, 다른 사람들과 공유할 음악을 찾아 볼까요?")
                    .searchable(text: $musicViewModel.searchText)
                    .onSubmit(of: .search, musicViewModel.searchMusic)
                }
                
            } // VStack 종료
            .sheet(isPresented: $showingVideoCapture) {
                CustomCameraView(isPresented: $showingVideoCapture, videoURL: $videoURL)
            }
        } // NavigationView 종료
       // .onAppear(perform: musicViewModel.searchMusic)
    } // body 종료
} // AddMusicToHear View 종료

#Preview {
    AddMusicToHear()
}
