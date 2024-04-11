//
//  MusicManger.swift
//  Here-Hear
//
//  Created by 이원형 on 3/2/24.
//

import Foundation
import Combine
import MusicKit

protocol MusicManagerProtocol {
    func fetchMusic(with term: String) -> AnyPublisher<[MusicModel], Error>
    func setupMusic()
}

class MusicManager: MusicManagerProtocol {
    
    init() {}
    
    func setupMusic() { // 앱 시작되자마자 MusicKit 검증해서 버벅임 없애기! 다른 방법있으면 교체 가능!
        Task {
            checkMusicAuthorizationStatus()
            await performInitialMusicSearchIfNeeded()
        }
    }
    // Apple Music 권한 상태를 확인하고, 필요한 경우 권한을 요청
    private func checkMusicAuthorizationStatus() {
        Task {
            let status = await MusicAuthorization.request()
            switch status {
            case .authorized:
                print("MusicAuthorization: Authorized")
                // 권한이 승인된 경우 초기 음악 검색을 수행
                await performInitialMusicSearchIfNeeded()

            case .denied, .restricted:
                print("MusicAuthorization: Denied or Restricted")
                // 권한이 거부되거나 제한된 경우

            case .notDetermined:
                print("MusicAuthorization: Not Determined")
                // 권한 요청을 아직 수행하지 않은 경우

            @unknown default:
                print("MusicAuthorization: Unknown")
            }
        }
    }

    // 필요한 경우 초기 음악 검색을 수행하는 함수: 검증 할때 버벅이기때문에 앱 시작시 강제 검색해서 버벅임을 풂
    private func performInitialMusicSearchIfNeeded() async {
        do {
            var searchRequest = MusicCatalogSearchRequest(term: "Apple", types: [Song.self])
            searchRequest.limit = 1

            let response = try await searchRequest.response()

            print("Initial music search performed with \(response.songs.count) results.")
        } catch {
            print("Error performing initial music search: \(error.localizedDescription)")
        }
    }

    func fetchMusic(with term: String) -> AnyPublisher<[MusicModel], Error> {
        Future<[MusicModel], Error> { promise in
            Task {
                
                let status = await MusicAuthorization.request()
                switch status {
                case .authorized:
                    do {
                        
                        var request = MusicCatalogSearchRequest(
                            term: term,
                            types: [Song.self]
                        )
                        request.limit = 15
                        
                        let response = try await request.response()

                        let models = response.songs.compactMap { song in
//                            if let artworkURL = song.artwork?.url(width: 200, height: 200) {
//                                print("\(artworkURL)")
//                            }
                                // return
                            return MusicModel(
                                id: song.id.rawValue,
                                albumId: song.albums?.first?.id.rawValue,
                                album: song.albumTitle,
                                title: song.title,
                                artist: song.artistName,
                                artwork: song.artwork?.url(width: 200, height: 200),
                                previewURL: song.previewAssets?.first?.url
                            )
                        }
                        promise(.success(models))
                    } catch {
                        promise(.failure(error))
                    }
                default:
                    promise(.failure(ManagerError.unauthorized))
                }
            }
        }
        .eraseToAnyPublisher()

    }

}

final class StubMusicManager: MusicManagerProtocol {
    func setupMusic() {
    }
    
    func fetchMusic(with term: String) -> AnyPublisher<[MusicModel], any Error> {
        Empty().eraseToAnyPublisher()
    }
}
