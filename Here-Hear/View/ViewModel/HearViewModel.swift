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
        isLoading = true
        let hearId = UUID().uuidString

        if let videoURL = videoURL {
            // 비디오 URL이 존재하는 경우, 비디오와 썸네일 업로드 진행
            videoService.uploadVideoAndThumbnail(url: videoURL, hearId: hearId)
                .sink(receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .failure(let error):
                        print("비디오 및 썸네일 업로드 실패: \(error.localizedDescription)")
                        self?.isLoading = false
                    case .finished:
                        print("비디오 및 썸네일 업로드 성공")
                    }
                }, receiveValue: { [weak self] (videoURL, thumbnailURL) in
                    self?.processUploadedContent(videoURL: videoURL, thumbnailURL: thumbnailURL, hearId: hearId)
                })
                .store(in: &cancellables)
        } else {
            // 비디오 URL이 없는 경우, 직접 엔티티 저장으로 넘어감
            processUploadedContent(videoURL: nil, thumbnailURL: nil, hearId: hearId)
        }
    }

    private func processUploadedContent(videoURL: URL?, thumbnailURL: URL?, hearId: String) {
        guard let selectedSong = selectedSong,
              let selectedWeather = selectedWeather,
              let userId = Auth.auth().currentUser?.uid,
              let location = locationManager.currentLocation else {
            isLoading = false
            return
        }

        let geohashExact = GeohashService().geohashExact(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        guard let locationEntity = LocationEntity(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, geohashExact: geohashExact) else { return }

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

        // Store music entity
        let musicEntity = selectedSong.toEntity()
        musicRepository.addMusic(musicEntity).sink(receiveCompletion: handleCompletion, receiveValue: { _ in }).store(in: &cancellables)

        // Store hear entity
        hearRepository.add(hearEntity).sink(receiveCompletion: handleCompletion, receiveValue: { _ in }).store(in: &cancellables)
    }

    private func handleCompletion<T>(_ completion: Subscribers.Completion<T>) {
        DispatchQueue.main.async {
            self.isLoading = false
            switch completion {
            case .finished:
                self.isSaveCompleted = true
                print("Hear 업로드 성공")
            case .failure(let error):
                print("업로드 실패: \(error.localizedDescription)")
            }
        }
    }
}
