import SwiftUI
import AVKit

struct WeatherOption {
    let title: String
    let systemImage: String
    let color: Color
    let weatherType: Weather
    
}

struct WeatherChoiceView: View {
    @State private var selectedWeather: WeatherOption?
    @State private var navigateToSummary = false
    @Binding var videoURL: URL?
    @Binding var selectedSong: MusicModel?
    @EnvironmentObject var cameraViewModel: CameraViewModel

    private let weatherOptions = [
        WeatherOption(title: "맑아요", systemImage: "sun.max.fill", color: .yellow, weatherType: .sunny),
        WeatherOption(title: "흐려요", systemImage: "cloud", color: .gray, weatherType: .cloudy),
        WeatherOption(title: "비 내려요", systemImage: "cloud.rain", color: .blue, weatherType: .rainy),
        WeatherOption(title: "눈 내려요", systemImage: "snowflake", color: .white, weatherType: .snowy),
        WeatherOption(title: "바람 불어요", systemImage: "wind", color: .white, weatherType: .windy),
        WeatherOption(title: "안개가 많아요", systemImage: "cloud.fog", color: .gray, weatherType: .foggy),
        WeatherOption(title: "미세먼지 많아요", systemImage: "sun.dust", color: .orange, weatherType: .dusty)
    ]
    
    var body: some View {
        ZStack {
            if let videoURL = videoURL {
                VideoPlayer(player: AVPlayer(url: videoURL))
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
                    ForEach(weatherOptions, id: \.weatherType) { option in
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
