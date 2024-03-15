//
//  AddMusicToHear.swift
//  Here-Hear
//
//  Created by 이원형 on 3/2/24.
//

import SwiftUI

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
struct AddMusicToHear: View {
    @StateObject private var musicViewModel = MusicViewModel()
    @State private var showingVideoCapture = false
    @State private var videoURL: URL?
    @State private var searchText = ""
    
    var body: some View {
        NavigationView { // NavigationView 시작
            VStack {
                HStack {
                    TextField(text: $searchText) {
                        Text(
                            "음악을 검색해주세요."
                        ).foregroundStyle(.gray)
                    }
                        .padding(20)
                        .padding(.leading, 20)
                        .background(Color("HHTertiary"))
                        .cornerRadius(10)
                        .padding(.horizontal) // 화면 좌우 패딩
                        .foregroundColor(.accent)
                        .overlay(
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .font(.title3)
                                    .foregroundColor(Color("HHGray"))
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 25)
                                Spacer()

                                if !searchText.isEmpty {
                                    Button(action: {
                                        self.searchText = ""
                                    }) {
                                        Image(systemName: "multiply.circle")
                                            .font(.title3)
                                            .foregroundColor(Color("HHGray"))
                                            .padding(.trailing, 25)
                                    }
                                }
                            }
                        )
                        .onChange(of: searchText) { newValue in
                            musicViewModel.searchText = newValue
                            musicViewModel.searchMusic(searchText: searchText)
                        }
                } // HStack TextField요소
                Spacer().frame(maxWidth: .infinity, maxHeight: .infinity).overlay {
                    if musicViewModel.isLoading {
                        // ProgressView()
                    } else {
                        musicList
                    }
                }
            }
            .navigationTitle("우선, 다른 사람들과 공유할 음악을 찾아 볼까요?")
            .sheet(isPresented: $showingVideoCapture) {
                CustomCameraView(isPresented: $showingVideoCapture, videoURL: $videoURL)
            }
            .onTapGesture {
                self.hideKeyboard()
            }
        } // NavigationView 종료
    } // body 종료
    
    @ViewBuilder
    private var musicList: some View {
        List(musicViewModel.songs) { song in
            musicRow(for: song)
        }
    }
    
    @ViewBuilder
    private func musicRow(for song: MusicModel) -> some View {
        Button(action: {
            // 노래 선택 시 카메라 인터페이스 표시
            showingVideoCapture = true
        }) {
            VStack {
                HStack { // HStack 시작
                    AsyncImage(url: song.artwork) { phase in // AsyncImage 시작
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 70, height: 70)
                        case .success(let image):
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
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
                            Image(systemName: musicViewModel.currentlyPlayingURL == previewUrl && musicViewModel.isPlaying ? "pause.circle" : "play.circle")
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
            }
            .animation(.easeInOut(duration: 0.8), value: musicViewModel.isPlaying)
        }
    } // AddMusicToHear View 종료
}
#Preview {
    AddMusicToHear()
}
