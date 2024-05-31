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
    @Published var isPlaying = false
    private var player: AVPlayer?
    var currentlyPlayingURL: URL?
    private var timeObserverToken: Any?
    private var musicManager: MusicManagerProtocol
    private var cancellables: Set<AnyCancellable> = []
    
    init(musicManager: MusicManagerProtocol = MusicManager()) {
        self.musicManager = musicManager
        setupSearchTextPublisher()
    }
    
    func setupSearchTextPublisher() {
        $searchText
            .removeDuplicates()
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] searchText in
                self?.searchMusic(searchText: searchText)
            }
            .store(in: &cancellables)
    }
    
    func searchMusic(searchText: String) {
        guard !searchText.isEmpty else {
            self.songs = []
            return
        }
    
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            self.musicManager.fetchMusic(with: searchText)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { [weak self] completion in
                        self?.isLoading = false
                        if case .failure(let error) = completion {
                            print(error.localizedDescription)
                        }
                    },
                    receiveValue: { [weak self] songs in
                        self?.songs = songs
                   }
                )
                .store(in: &self.cancellables)
        }

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
            currentlyPlayingURL = url
            isPlaying = false // 재생 중이 아님

        } else if currentlyPlayingURL == url, player?.timeControlStatus != .playing {
            player?.play()
            isPlaying = true // 재생 중

        } else {
            // 새로운 곡 재생하기
            player = AVPlayer(url: url)
            player?.play()
            currentlyPlayingURL = url
            isPlaying = true // 재생 중
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
            self.isPlaying = false // 재생 중이 아님
        }
    }
}

extension MusicViewModel {
    func pauseMusicIfNeeded() {
        if isPlaying, let url = currentlyPlayingURL {
            pauseMusic(url: url)
        }
    }
}
