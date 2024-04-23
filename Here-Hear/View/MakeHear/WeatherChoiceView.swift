import SwiftUI
import AVKit

struct WeatherOption {
    let title: String
    let systemImage: String
    let color: Color
    let weatherType: Weather
    
}

extension Color {
    static let sunnyColor = Color(red: 1, green: 0.8, blue: 0)
    static let cloudyColor = Color(red: 0.6, green: 0.6, blue: 0.65)
    static let rainyColor = Color(red: 0, green: 0.5, blue: 1)
    static let snowyColor = Color(red: 0.95, green: 0.95, blue: 0.95)
    static let windyColor = Color(red: 0.7, green: 0.7, blue: 0.7)
    static let foggyColor = Color(red: 0.65, green: 0.65, blue: 0.7)
    static let dustyColor = Color(red: 0.9, green: 0.55, blue: 0.25)
}

struct WeatherChoiceView: View {
    @State private var selectedWeather: WeatherOption?
    @State private var navigateToSummary = false
    @Binding var videoURL: URL?
    @Binding var selectedSong: MusicModel?
    @Binding var feelingText: String
    @EnvironmentObject var cameraViewModel: CameraViewModel

    private let weatherOptions = [
        WeatherOption(title: "맑아요", systemImage: "sun.max.fill", color: .sunnyColor, weatherType: .sunny),
        WeatherOption(title: "흐려요", systemImage: "cloud", color: .cloudyColor, weatherType: .cloudy),
        WeatherOption(title: "비 내려요", systemImage: "cloud.rain", color: .rainyColor, weatherType: .rainy),
        WeatherOption(title: "눈 내려요", systemImage: "snowflake", color: .snowyColor, weatherType: .snowy),
        WeatherOption(title: "바람 불어요", systemImage: "wind", color: .windyColor, weatherType: .windy),
        WeatherOption(title: "안개가 많아요", systemImage: "cloud.fog", color: .foggyColor, weatherType: .foggy),
        WeatherOption(title: "미세먼지 많아요", systemImage: "sun.dust", color: .dustyColor, weatherType: .dusty)
    ]
    
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
