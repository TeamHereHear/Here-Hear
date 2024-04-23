import SwiftUI
import AVKit

struct FinalSummaryHearView: View {
    @Binding var videoURL: URL?
    @Binding var selectedSong: MusicModel?
    @Binding var selectedWeather: Weather?
    @Binding var feelingText: String
    @EnvironmentObject var cameraViewModel: CameraViewModel
    @StateObject var hearViewModel = HearViewModel()
    @EnvironmentObject private var container: DIContainer

    var musicPlayer = AVPlayer()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let videoURL = videoURL {
                    Player(player: AVPlayer(url: videoURL), loop: true)
                        .ignoresSafeArea(.all)
                } else {
                    Color("HHTertiary")
                        .edgesIgnoringSafeArea(.all)
                }

                if hearViewModel.isLoading {
                    ProgressView()
                        .scaleEffect(2.0, anchor: .center)
                        .progressViewStyle(CircularProgressViewStyle(tint: Color("HHTertiary")))
                } else {
                    VStack {
                        Spacer()
                        
                        Text(feelingText)
                            .font(.title)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        detailsView
                        Spacer()
                        actionButton
                    }
                }
            }
        }
        .onAppear {
            if let previewURL = selectedSong?.previewURL {
                musicPlayer.replaceCurrentItem(with: AVPlayerItem(url: previewURL))
                musicPlayer.play()
            }
        }
        .onDisappear {
            musicPlayer.pause()
        }
    }
    
    private var actionButton: some View {
        HStack {
            Spacer()
            Button(action: saveHear) {
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
    
    private func saveHear() {
        hearViewModel.selectedSong = selectedSong
        hearViewModel.selectedWeather = selectedWeather
        hearViewModel.videoURL = videoURL
        hearViewModel.feelingText = feelingText
        
        hearViewModel.saveHearToFirebase()
    }

    private var detailsView: some View {
        VStack(spacing: 16) {
            // 아트워크 이미지
            if let artworkURL = selectedSong?.artwork {
                AsyncImage(url: artworkURL) { image in
                    image.resizable()
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
                .foregroundColor(.white)
                .shadow(radius: 10)
            
            // 아티스트 이름
            Text(selectedSong?.artist ?? "아티스트 정보 없음")
                .font(.headline)
                .foregroundColor(.white)
                .shadow(radius: 10)
            
            // 날씨 정보
            HStack {
                Image(systemName: selectedWeather?.imageName ?? "questionmark.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(selectedWeather?.color ?? .white)
                
                Text(selectedWeather?.optionTitle ?? "날씨 정보 없음")
                    .foregroundColor(.white)
                    .shadow(radius: 10)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.35))
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}
