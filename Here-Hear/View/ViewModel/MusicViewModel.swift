//
//  MusicViewModel.swift
//  Here-Hear
//
//  Created by 이원형 on 3/2/24.
//

import Foundation
import Combine
import AVKit

class MusicViewModel: ObservableObject {
    @Published var songs: [MusicModel] = []
    @Published var searchText: String = ""
    @Published var playbackProgress: Float = 0.0
    @Published var isLoading = false // 음악 검색중인지 여부 나타내는 상태 변수임
    private var player: AVPlayer?
    var currentlyPlayingURL: URL?
    private var timeObserverToken: Any?
    private var musicManager: MusicMangerProtocol
    private var cancellables: Set<AnyCancellable> = []
    
    init(musicManager: MusicMangerProtocol = MusicManger()) {
        self.musicManager = musicManager
    }
    
    func searchMusic() {
        isLoading = true
        musicManager.fetchMusic(with: searchText)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    switch completion {
                    case .finished:
                        break
                    case .failure(let failure):
                        print(failure.localizedDescription)
                    }
                    
                },
                receiveValue: { [weak self] songs in
                    self?.songs = songs
                })
            .store(in: &cancellables)
    }
    
    // 미리듣기 재생 및 일시정지
    func pauseMusic(url: URL) {
        
        // 현재 재생 중인 곡이 바뀌면, 기존의 Time Observer를 제거
        if let timeObserverToken = timeObserverToken {
            player?.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
        
        // 현재 다른 곡이 재생중인지 확인하고, 그렇다면 정지
        if let currentlyPlayingURL = currentlyPlayingURL, currentlyPlayingURL != url {
            player?.pause()
            self.player?.seek(to: .zero)
            self.currentlyPlayingURL = nil
        }
        
        // 이전과 동일한 곡을 다시 재생하려는 경우
        if currentlyPlayingURL == url, player?.timeControlStatus == .playing {
            player?.pause()
            currentlyPlayingURL = nil
        } else if currentlyPlayingURL == url, player?.timeControlStatus != .playing {
            player?.play()
        } else {
            // 새로운 곡 재생하기
            player = AVPlayer(url: url)
            player?.play()
            currentlyPlayingURL = url
            setupEndPlaybackObserver()
        }
        // 새로운 곡을 재생할 때, Time Observer를 추가
        if player?.currentItem != nil {
            let interval = CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            let mainQueue = DispatchQueue.main
            timeObserverToken = player?.addPeriodicTimeObserver(
                forInterval: interval,
                queue: mainQueue
            ) { _ in
                guard let currentItem = self.player?.currentItem else { return }
                let duration = currentItem.duration.seconds
                let currentTime = currentItem.currentTime().seconds
                let progress = currentTime / duration
                self.playbackProgress = Float(progress)
            }
        }
    }
    
    // 미리듣기 끝나는 시점 감지하기
    func setupEndPlaybackObserver() {
        NotificationCenter.default.removeObserver(
            self,
            name: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem
        )
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) {  _ in
            self.player?.seek(to: .zero) // 재생 위치 시작으로 이동
            self.currentlyPlayingURL = nil // 현재 재생중인 URL 초기화하기
        }
    }
}
