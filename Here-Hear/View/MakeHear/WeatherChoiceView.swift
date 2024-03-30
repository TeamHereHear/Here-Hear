import SwiftUI
import AVKit

struct WeatherOption {
    let title: String
    let systemImage: String
    let color: Color
}

struct WeatherChoiceView: View {
    @State private var selectedWeather: WeatherOption?
    @State private var navigateToSummary = false
    @Binding var videoURL: URL?
    @Binding var selectedSong: MusicModel?
    @EnvironmentObject var cameraViewModel: CameraViewModel

    private let weatherOptions = [
        WeatherOption(title: "맑아요", systemImage: "sun.max.fill", color: .yellow),
        WeatherOption(title: "흐려요", systemImage: "cloud", color: .gray),
        WeatherOption(title: "비 내려요", systemImage: "cloud.rain", color: .blue),
        WeatherOption(title: "눈 내려요", systemImage: "snowflake", color: .white),
        WeatherOption(title: "바람 불어요", systemImage: "wind", color: .white),
        WeatherOption(title: "안개가 많아요", systemImage: "cloud.fog", color: .gray),
        WeatherOption(title: "미세먼지 많아요", systemImage: "sun.dust", color: .orange)
    ]
    
    var body: some View {
        ZStack {
            
            if let videoURL = videoURL {
                VideoPlayer(player: AVPlayer(url: videoURL))
                    .edgesIgnoringSafeArea(.all)
            } else {
                Color("HHTertiary")
                    .edgesIgnoringSafeArea(.all)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("지금 여기\n날씨는 어떤가요?")
                    .padding()
                    .font(.title)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 15) {
                    ForEach(weatherOptions, id: \.title) { option in
                        Button(action: {
                            self.selectedWeather = option
                            DispatchQueue.main.async {
                                self.navigateToSummary = true
                            }
                            print("\(option.title) 선택됨")
                        }) {
                            HStack {
                                Image(systemName: option.systemImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 30)
                                    .foregroundColor(option.color)
                                Text(option.title)
                                    .font(.headline)
                            }
                        }
                        .weatherChoiceButtonStyle()
                    }
                        NavigationLink(destination: FinalSummaryHearView(
                            videoURL: $videoURL,
                            selectedSong: $selectedSong,
                            selectedWeather: $selectedWeather
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
