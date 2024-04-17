import SwiftUI
import AVKit

struct AddFeelingText: View {
    @Binding var videoURL: URL?
    @Binding var selectedSong: MusicModel?
    @EnvironmentObject var cameraViewModel: CameraViewModel

    @State private var showWeatherChoiceView = false
    @State private var isEditingText = false
    @State private var inputText = ""
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background player or color
                PlayerView(videoURL: videoURL, loop: true)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                        .frame(height: geometry.size.height * 0.1)
                    
                    if isEditingText {
                        TextField("지금 떠오르는 생각을 적어볼까요?", text: $inputText, onCommit: {
                            isEditingText = false
                        })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .transition(.opacity)
                        .animation(.easeInOut)
                    } else {
                        Text("지금 떠오르는\n생각을 적어볼까요?")
                            .font(.title)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .onTapGesture {
                                isEditingText = true
                            }
                    }
                    
                    Spacer()
                }
                // Skip Button at bottom-right
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button("건너뛰기") {
                            showWeatherChoiceView = true
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .shadow(radius: 10)
                        .padding(20)  // Padding from right and bottom edges
                    }
                }
                
                // Navigation Link hidden
                NavigationLink(destination: WeatherChoiceView(videoURL: $videoURL, selectedSong: $selectedSong), isActive: $showWeatherChoiceView) {
                    EmptyView()
                }
            }
        }
    }
}

struct PlayerView: View {
    var videoURL: URL?
    var loop: Bool
    
    var body: some View {
        if let videoURL = videoURL {
            Player(player: AVPlayer(url: videoURL), loop: loop)
        } else {
            Color("HHTertiary")
        }
    }
}
