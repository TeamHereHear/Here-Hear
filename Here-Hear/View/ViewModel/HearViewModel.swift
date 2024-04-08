    //
    //  HearViewModel.swift
    //  Here-Hear
    //
    //  Created by 이원형 on 3/30/24.
    //

    import Foundation
    import Combine
    import Firebase

    class HearViewModel: ObservableObject {
        private var hearRepository: HearRepositoryInterface
        private var cancellables = Set<AnyCancellable>()
        private let locationManager = LocationManager()

        @Published var selectedSong: MusicModel?
        @Published var selectedWeather: WeatherOption?
        @Published var videoURL: URL?
        @Published var isSaveCompleted = false

        init(hearRepository: HearRepositoryInterface = HearRepository()) {
            self.hearRepository = hearRepository
        }

        func saveHearToFirebase() {
            guard let selectedSong = selectedSong,
                  let selectedWeather = selectedWeather,
                  let userId = Auth.auth().currentUser?.uid else {
                print("데이터가 없음")
                return
            }
            
            guard let location = locationManager.currentLocation else {
                print("위치 정보를 가져올 수 없습니다.")
                return
            }
            
            let geohashExact = GeohashService().geohashExact(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            
            guard let locationEntity = LocationEntity(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, geohashExact: geohashExact) else {
                print("LocationEntity 초기화 실패!")
                return
            }

            let feeling = FeelingEntity(expressionText: "기분 좋음", colorHexString: "#FFFFFF", textLocation: [0.0, 0.0])

            let hearEntity = HearEntity(
                id: UUID().uuidString,
                userId: userId,
                location: locationEntity,
                musicIds: [selectedSong.id],
                feeling: feeling,
                like: 0,
                createdAt: Date(),
                weather: selectedWeather.title
            )
            
            hearRepository.add(hearEntity)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        print("Error saving hear: \(error)")
                    case .finished:
                        print("Hear saved successfully")
                        DispatchQueue.main.async {
                            self.isSaveCompleted = true
                        }
                    }
                }, receiveValue: { _ in
                })
                .store(in: &cancellables)
        }
    }
