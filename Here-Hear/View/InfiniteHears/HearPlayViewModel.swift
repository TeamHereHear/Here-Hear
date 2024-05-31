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
    
    @Published var musicData: MusicData = .init()
    @Published var videoData: VideoData = .init()
    @Published var videoPlayer: AVPlayer?
    private var musicPlayer: AVPlayer?
    @Published var userNickname: String?
    
    struct MusicData {
        var music: MusicModel?
        var musicPlayBackProgress: CGFloat?
    }
    
    struct VideoData {
        var videoURL: URL?
        var hasVideo: Bool = true
        var videoProgress: CGFloat?
    }

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
        
        self.videoData = if let url = await videoURL {
            VideoData(videoURL: url, hasVideo: true)
        } else {
            VideoData(hasVideo: false)
        }
        
        self.userNickname = try? await nickname
        self.musicData.music = try? await music
        
        self.setPlayer(withVideoURL: self.videoData.videoURL)
        self.setMusicPlayer(withPreviewURL: self.musicData.music?.previewURL)
    }
    
    
    
    @MainActor
    private func fetchVideoURL() async -> URL? {        
        let url = try? await container.services.videoService.hearVideoUrl(ofId: hear.id)
        
        return url
    }

    @MainActor
    private func fetchMusic() async throws -> MusicModel? {
        guard let musicId = hear.musicIds.first else {
            return nil
        }
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
    
    private func setPlayer(withVideoURL videoURL: URL?) {
        guard let videoURL else {
            return
        }
        videoPlayer = AVPlayer(url: videoURL)
    }
    
    func playVideo() async {
        videoPlayer?.isMuted = true
        
        await videoPlayer?.play()
        
        let interval = CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let totalTime = try? await videoPlayer?.currentItem?.asset.load(.duration)
        videoPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { time in
            let currentTimeSeconds = CMTimeGetSeconds(time)
            if let totalTime {
                let totalTimeSeconds = CMTimeGetSeconds(totalTime)
                self.videoData.videoProgress = CGFloat(currentTimeSeconds) / CGFloat(totalTimeSeconds)
            }
        }
    }
    
    private func setMusicPlayer(withPreviewURL previewURL: URL?) {
        guard let previewURL else { return }
        musicPlayer = AVPlayer(url: previewURL)
    }
    
    func playMusic() async {
        await musicPlayer?.play()
        
        guard !self.videoData.hasVideo else { return }
        
        let interval = CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let totalTime = try? await musicPlayer?.currentItem?.asset.load(.duration)
        musicPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { time in
            let currentTimeSeconds = CMTimeGetSeconds(time)
            if let totalTime {
                let totalTimeSeconds = CMTimeGetSeconds(totalTime)
                self.musicData.musicPlayBackProgress = CGFloat(currentTimeSeconds) / CGFloat(totalTimeSeconds)
            }
        }
        setUpMusicPlayerEndObserver()
    }
    
    private func setUpMusicPlayerEndObserver() {
        NotificationCenter.default.removeObserver(
            self,
            name: .AVPlayerItemDidPlayToEndTime,
            object: musicPlayer?.currentItem
        )
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: musicPlayer?.currentItem,
            queue: .main
        ) {  _ in
            self.musicPlayer?.seek(to: .zero)
            self.musicPlayer?.play()
        }
    }
    
    func pausePlayer() {
        videoPlayer?.pause()
        videoPlayer?.seek(to: .zero)
        musicPlayer?.pause()
        musicPlayer?.seek(to: .zero)
    }
    
    func cleanPlayer() {
        videoPlayer?.pause()
        musicPlayer?.pause()
        NotificationCenter.default.removeObserver(
            self,
            name: .AVPlayerItemDidPlayToEndTime,
            object: musicPlayer?.currentItem
        )
        musicPlayer = nil
        videoPlayer = nil
    }
}
