//
//  MusicRepository.swift
//  Here-Hear
//
//  Created by Martin on 2/20/24.
//

import Foundation
import Combine

import FirebaseFirestore

enum MusicRepositoryError: Error {
    case nilSelf
    case emptyData
    case custom(Error)
}

protocol MusicRepositoryInterface {
    func addMusic(_ music: MusicEntity) -> AnyPublisher<MusicEntity, MusicRepositoryError>
    func fetchMusic(ofIds ids: [String]) -> AnyPublisher<[MusicEntity], MusicRepositoryError>
    func deleteMusic(ofId id: String) -> AnyPublisher<Void, MusicRepositoryError>
}

class MusicRepository: MusicRepositoryInterface {
    private let collectionRef = Firestore.firestore().collection("Music")
    
    // MARK: - 새로운 MusicEntity 추가
    
    /// MusicEntity를 데이터베이스에 추가하는 메서드
    /// - Parameter music: MusicEntity
    /// - Returns: 추가한 MusicEntity와 MusicRepositoryError를 각각 Output과 Error로 가지는 AnyPublisher
    func addMusic(_ music: MusicEntity) -> AnyPublisher<MusicEntity, MusicRepositoryError> {
        Future { [weak self] promise in
            guard let self else {
                promise(.failure(MusicRepositoryError.nilSelf))
                return
            }
            
            do {
                try self.collectionRef
                    .document(music.id)
                    .setData(from: music)
                promise(.success(music))
            } catch {
                promise(.failure(MusicRepositoryError.custom(error)))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - MusicEntity 가져오기
    
    /// 주어진 MusicEntity의 id배열로 해당하는 MusicEntity를 데이터베이스에서 가져오는 메서드
    /// - Parameter ids: MusicEntity id 배열
    /// - Returns: 가져온 MusicEntity배열과 MusicRepositoryError를 각각 Output과 Error로 가지는 AnyPublisher
    func fetchMusic(ofIds ids: [String]) -> AnyPublisher<[MusicEntity], MusicRepositoryError> {
        Future { [weak self] promise in
            guard let self else {
                promise(.failure(MusicRepositoryError.nilSelf))
                return
            }
                     
            self.collectionRef
                .whereField("id", in: ids)
                .getDocuments { snapshot, error in
                    if let error {
                        promise(.failure(MusicRepositoryError.custom(error)))
                        return
                    }
                    
                    guard let snapshot else {
                        promise(.failure(MusicRepositoryError.emptyData))
                        return
                    }
                    
                    let entities: [MusicEntity] = snapshot.documents.compactMap {
                        try? $0.data(as: MusicEntity.self)
                    }
                    
                    promise(.success(entities))
                }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - MusicEntity 삭제
    
    /// 데이터베이스에서 id에 해당하는 MusicEntity를 삭제하는 메서드
    /// - Parameter id: 삭제할 MusicEntity의 id
    /// - Returns: AnyPublisher<Void, MusicRepositoryError>
    func deleteMusic(ofId id: String) -> AnyPublisher<Void, MusicRepositoryError> {
        Future { [weak self] promise in
            guard let self else {
                promise(.failure(MusicRepositoryError.nilSelf))
                return
            }
            
            self.collectionRef
                .document(id)
                .delete { error in
                    if let error {
                        promise(.failure(MusicRepositoryError.custom(error)))
                        return
                    }
                    
                    promise(.success(()))
                }
            
        }
        .eraseToAnyPublisher()
    }
}
