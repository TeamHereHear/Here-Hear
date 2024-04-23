import SwiftUI
import AVKit

struct WeatherChoiceView: View {
    @State private var selectedWeather: Weather?
    @State private var navigateToSummary = false
    @Binding var videoURL: URL?
    @Binding var selectedSong: MusicModel?
    @Binding var feelingText: String
    @EnvironmentObject var cameraViewModel: CameraViewModel

    var body: some View {
        ZStack {
            
            if let videoURL = videoURL {
                Player(player: AVPlayer(url: videoURL), loop: true)
                    .ignoresSafeArea(.all)
            } else {
                Color("HHTertiary")
                    .edgesIgnoringSafeArea(.all)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("지금 여기\n날씨는 어떤가요?")
                    .padding()
                    .font(.title)
                    .foregroundColor(videoURL != nil ? .white : .black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 15) {
                    ForEach(Weather.allCases, id: \.self) { weather in
                        Button {
                            self.selectedWeather = weather
                            DispatchQueue.main.async {
                                self.navigateToSummary = true
                            }
                            print("\(weather.optionTitle) 선택됨")
                        } label: {
                            HStack {
                                Image(systemName: weather.imageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 30)
                                    .foregroundColor(weather.color)
                                Text(weather.optionTitle)
                                    .font(.headline)
                            }
                        }
                        .weatherChoiceButtonStyle()
                    }
                        NavigationLink(destination: FinalSummaryHearView(
                            videoURL: $videoURL,
                            selectedSong: $selectedSong,
                            selectedWeather: $selectedWeather,
                            feelingText: $feelingText
                        ), isActive: $navigateToSummary) {
                            EmptyView()
                        }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.clear)
            }
        }
    }
}
