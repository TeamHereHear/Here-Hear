import SwiftUI
import AVKit

struct AddMusicToHear: View {
    @StateObject private var musicViewModel = MusicViewModel()
    @EnvironmentObject private var container: DIContainer
    @State private var videoURL: URL?
    @State private var selectedSong: MusicModel?
    @FocusState private var isInputActive: Bool

    var body: some View {
        NavigationView {
            VStack {
                Text("우선, 다른 사람들과 공유할\n음악을 찾아볼까요?")
                    .padding()
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                searchField
                
                Spacer().frame(maxWidth: .infinity).overlay {
                    if musicViewModel.isLoading {
                        ProgressView()
                    } else {
                        musicList
                    }
                }
            }
            .fullScreenCover(item: $selectedSong) {_ in 
                CameraHomeView(selectedSong: $selectedSong)
                    .onAppear {
                        musicViewModel.pauseMusicIfNeeded()
                        container.managers.audioSessionManager.deactivateAudioSession()
                    }
            }
            .onTapGesture {
                isInputActive = false
            }
            .onAppear {
                container.managers.audioSessionManager.activateAudioSession()
            }
        }
    }

    private var searchField: some View {
        HStack {
            TextField("공유하고 싶은 음악을 검색해주세요 :)", text: $musicViewModel.searchText)
                .focused($isInputActive)
                .textFieldStyle(PlainTextFieldStyle())
                .padding()
                .padding(.leading, 25)
                .background(Color("HHTertiary"))
                .cornerRadius(10)
                .foregroundColor(.black)
                .padding(.horizontal)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundColor(Color("HHGray"))
                        Spacer()
                        if !musicViewModel.searchText.isEmpty {
                            Button(action: {
                                musicViewModel.searchText = ""
                                isInputActive = false
                            }) {
                                Image(systemName: "multiply.circle.fill").foregroundColor(Color("HHGray"))
                            }
                        }
                    }
                    .padding(.horizontal, 25)
                )
        }
    }
    
    @ViewBuilder
    private var musicList: some View {
        List(musicViewModel.songs) { song in
            Button(action: {
                self.selectedSong = song
                isInputActive = false
            }) {
                HStack {
                    AsyncImage(url: song.artwork) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image.resizable()
                        case .failure:
                            Image(systemName: "photo.on.rectangle.angled")
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(width: 70, height: 70)
                    .cornerRadius(10)
                    
                    VStack(alignment: .leading) {
                        Text(song.title).lineLimit(1)
                        Text(song.artist).font(.footnote).foregroundColor(.gray)
                    }
                    Spacer()
                }
            }
        }
    }
}
