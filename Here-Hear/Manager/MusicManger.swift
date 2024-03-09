//
//  MusicManger.swift
//  Here-Hear
//
//  Created by 이원형 on 3/2/24.
//

import Foundation
import Combine
import AVKit
import MusicKit

protocol MusicMangerProtocol {
    func fetchMusic(with term: String) -> AnyPublisher<[MusicModel], Error>
}

class MusicManger: MusicMangerProtocol {
    
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
                        request.limit = 10
                        
                        let response = try await request.response()
                        let models = response.songs.compactMap { song in
                            MusicModel(
                                id: song.id.rawValue,
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
