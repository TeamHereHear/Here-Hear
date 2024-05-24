//
//  HearPlayViewModel.swift
//  Here-Hear
//
//  Created by Tyrell_07 on 4/22/24.
//

import Foundation
import Combine
import AVKit

class HearPlayViewModel: ObservableObject {
    let hear: HearModel
    var thumbnailPath: String {
        "\(StoragePath.Thumbnail)/\(hear.id).jpg"
    }
    private let container: DIContainer
    @Published var viewData: ViewData = .init()
    
    struct ViewData {
        var videoURL: URL?
        var music: MusicModel?
        var userNickname: String?
    }
    
    @Published var videoPlayer: AVPlayer?
    @Published var videoProgress: CGFloat?
    

    @Published var error: HearPlayError?
    enum HearPlayError: LocalizedError {
        case failedToFetchVideoURL
        case failedToFetchMusic
        case failedToFetchUserInfo
    }
    
    init(
        container: DIContainer,
        hear: HearModel
    ) {
        self.container = container
        self.hear = hear
    }
    
    @MainActor
    func fetchAllData() async {
        async let videoURL = fetchVideoURL()
        async let music = fetchMusic()
        async let nickname = fetchHearUser()
        do {
            try await self.viewData = .init(
                videoURL: videoURL,
                music: music,
                userNickname: nickname
            )
        } catch {
            self.error = error as? HearPlayError
        }
    }
    
    @MainActor
    private func fetchVideoURL() async throws -> URL {
        do {
            return try await container.services.videoService.hearVideoUrl(ofId: hear.id)
        } catch {
            throw HearPlayError.failedToFetchVideoURL
        }
    }

    
    @MainActor
    private func fetchMusic() async throws -> MusicModel? {
        guard let musicId = hear.musicIds.first else { return nil }
        do {
            let musics = try await container.services.musicService.fetchMusic(ofIds: [musicId])
            if musics.isEmpty { return nil }
            return musics.first
        
        } catch {
            throw HearPlayError.failedToFetchMusic
        }
        
    }
    
    @MainActor
    private func fetchHearUser() async throws -> String? {
        do {
            return try await container.services.userService.fetchUser(ofId: hear.userId)?.nickname
        } catch {
            throw HearPlayError.failedToFetchUserInfo
        }
        
    }
    
    
    func setPlayer(withVideoUrl videoUrl: URL?) async {
        guard let videoUrl else { return }
        videoPlayer = AVPlayer(url: videoUrl)
       
        videoPlayer?.isMuted = true
        
        await videoPlayer?.play()
        
        let interval = CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let totalTime = try? await videoPlayer?.currentItem?.asset.load(.duration)
        videoPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { time in
            let currentTimeSeconds = CMTimeGetSeconds(time)
            if let totalTime {
                let totalTimeSeconds = CMTimeGetSeconds(totalTime)
                self.videoProgress = CGFloat(currentTimeSeconds) / CGFloat(totalTimeSeconds)
            }
        }
    }
    
    func cleanPlayer() {
        videoPlayer?.pause()
        videoPlayer = nil
    }
}
