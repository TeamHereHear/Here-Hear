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
    private var musicRepository: MusicRepositoryInterface
    private var videoService: VideoServiceProtocol
    
    private var cancellables = Set<AnyCancellable>()
    private let locationManager = LocationManager()
    @Published var selectedSong: MusicModel?
    @Published var selectedWeather: WeatherOption?
    @Published var videoURL: URL?
    @Published var isSaveCompleted = false
    @Published var isLoading = false
    @Published var feelingText: String = ""
    
    init(
        hearRepository: HearRepositoryInterface = HearRepository(),
        musicRepository: MusicRepositoryInterface = MusicRepository(),
        videoService: VideoServiceProtocol = VideoService()
    ) {
        self.hearRepository = hearRepository
        self.musicRepository = musicRepository
        self.videoService = videoService
    }
    
    func saveHearToFirebase() {
        
        guard let videoURL = videoURL else {
            print("비디오 데이터 없음")
            return
        }
        
        isLoading = true  // 로딩 시작
        let hearId = UUID().uuidString
        
        videoService.uploadVideo(url: videoURL, hearId: hearId)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case . failure(let error):
                    print("비디오 업로드 실패: \(error.localizedDescription)")
                    self?.isLoading = false
                case .finished:
                    print("비디오 업로드 성공")
                }
            }, receiveValue: { [weak self] downloadURL in
                self?.processUploadedVideo(url: downloadURL)
            })
            .store(in: &cancellables)
        
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
        
        // Entity 설정
        let feeling = FeelingEntity(expressionText: feelingText, colorHexString: "#FFFFFF", textLocation: [0.0, 0.0])
        
        let hearEntity = HearEntity(
            id: hearId,
            userId: userId,
            location: locationEntity,
            musicIds: [selectedSong.id],
            feeling: feeling,
            like: 0,
            createdAt: Date(),
            weather: selectedWeather.weatherType.rawValue
        )
        
        // 음악 엔티티 저장
        let musicEntity = selectedSong.toEntity()
        musicRepository.addMusic(musicEntity).sink(receiveCompletion: handleCompletion, receiveValue: { _ in }).store(in: &cancellables)
        
        // Hear 엔티티 저장
        hearRepository.add(hearEntity).sink(receiveCompletion: handleCompletion, receiveValue: { _ in }).store(in: &cancellables)
    }
    
    private func processUploadedVideo(url: URL?) {
        guard let url = url, let selectedSong = selectedSong, let selectedWeather = selectedWeather else {
            isLoading = false
            return
        }
    }
    private func handleCompletion<T>(_ completion: Subscribers.Completion<T>) {
        DispatchQueue.main.async {
            self.isLoading = false
            switch completion {
            case .finished:
                self.isSaveCompleted = true
                print("Hear 업로드 성공")
            case .failure(let error):
                if let musicError = error as? MusicRepositoryError {
                    print("Music Repository 에러: \(musicError)")
                } else if let hearError = error as? HearRepositoryError {
                    print("Hear Repository 에러: \(hearError)")
                } else {
                    print("에러: \(error.localizedDescription)")
                }
            }
        }
    }
}
