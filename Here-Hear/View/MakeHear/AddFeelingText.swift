import SwiftUI
import AVKit

struct AddFeelingText: View {
    @Binding var videoURL: URL?
    @Binding var selectedSong: MusicModel?
    @EnvironmentObject var cameraViewModel: CameraViewModel

    @State private var showWeatherChoiceView = false
    @FocusState private var isEditingText: Bool
    @State private var feelingText = ""

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                PlayerView(videoURL: videoURL, loop: true)
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    Spacer()
                        .frame(height: geometry.size.height * 0.2)

                    TextField("", text: $feelingText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                        .background(Capsule().fill(Color.clear))
                        .focused($isEditingText)
                        .overlay(
                            Group {
                                if feelingText.isEmpty && !isEditingText {
                                    Text("지금 떠오르는 생각을 적어볼까요?")
                                        .font(.title)
                                        .foregroundColor(videoURL != nil ? .white : .black)
                                        .multilineTextAlignment(.center)
                                        .onTapGesture {
                                            isEditingText = true
                                        }
                                }
                            }
                        )
                        .onSubmit {
                            confirmInput()
                        }
                        .submitLabel(.done)

                    Spacer()
                }

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        actionButton
                            .padding(20)
                    }
                }

                NavigationLink(
                    destination: WeatherChoiceView(videoURL: $videoURL, selectedSong: $selectedSong, feelingText: $feelingText),
                    isActive: $showWeatherChoiceView
                ) {
                    EmptyView()
                }
            }
            .animation(.easeInOut(duration: 0.5), value: isEditingText)
        }
    }

    private var actionButton: some View {
        Button(feelingText.isEmpty ? "건너뛰기" : "확인") {
            if feelingText.isEmpty {
                showWeatherChoiceView = true
            } else {
                confirmInput()
            }
        }
        .font(.headline)
        .foregroundColor(.white)
        .shadow(radius: 10)
    }

    private func confirmInput() {
        isEditingText = false
        if !feelingText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            showWeatherChoiceView = true
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
