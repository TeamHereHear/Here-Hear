//
//  MusicService.swift
//  Here-Hear
//
//  Created by Martin on 2/20/24.
//

import Foundation
import Combine

protocol MusicServiceInterface {
    func addMusic(_ music: MusicModel) -> AnyPublisher<MusicModel, ServiceError>
    func fetchMusic(ofIds ids: [String]) -> AnyPublisher<[MusicModel], ServiceError>
    func deleteMusic(ofId id: String) -> AnyPublisher<Void, ServiceError>
}

class MusicService: MusicServiceInterface {
    private let repository: MusicRepositoryInterface
    
    init(repository: MusicRepositoryInterface) {
        self.repository = repository
    }
    
    func addMusic(_ music: MusicModel) -> AnyPublisher<MusicModel, ServiceError> {
        let entity = music.toEntity()
        return repository.addMusic(entity)
            .map { $0.toModel() }
            .mapError { ServiceError.error( $0 ) }
            .eraseToAnyPublisher()
    }
    
    func fetchMusic(ofIds ids: [String]) -> AnyPublisher<[MusicModel], ServiceError> {
        return repository.fetchMusic(ofIds: ids)
            .map { $0.map { $0.toModel() } }
            .mapError { ServiceError.error( $0 ) }
            .eraseToAnyPublisher()
    }
    
    func deleteMusic(ofId id: String) -> AnyPublisher<Void, ServiceError> {
        return repository.deleteMusic(ofId: id)
            .mapError { ServiceError.error( $0 ) }
            .eraseToAnyPublisher()
    }
}

class StubMusicService: MusicServiceInterface {
    func addMusic(_ music: MusicModel) -> AnyPublisher<MusicModel, ServiceError> {
        Just(music)
            .setFailureType(to: ServiceError.self)
            .eraseToAnyPublisher()
    }
    
    func fetchMusic(ofIds ids: [String]) -> AnyPublisher<[MusicModel], ServiceError> {
        let testModel = ids.map {
            MusicModel(
                id: $0,
                album: "Album \($0)",
                title: "Title \($0)",
                artist: "Artist \($0)",
                artwork:
                    URL(
                        string:  "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/9a/49/b2/9a49b2d2-2501-2fc7-60eb-2b8ff34a1412/TAEYEON-DIGITAL20COVER.jpg/200x200bb.jpg"
                    )
                   
            )
        }
        return Just(testModel)
            .setFailureType(to: ServiceError.self)
            .eraseToAnyPublisher()
    }
    
    func deleteMusic(ofId id: String) -> AnyPublisher<Void, ServiceError> {
        Just(())
            .setFailureType(to: ServiceError.self)
            .eraseToAnyPublisher()
    }

}
