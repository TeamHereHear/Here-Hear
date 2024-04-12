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
    func fetchMusic(ofIds ids: [String]) async throws -> [MusicEntity]
    func deleteMusic(ofId id: String) -> AnyPublisher<Void, MusicRepositoryError>
}

#warning("TODO: Firestore Cache Setting")
class MusicRepository: MusicRepositoryInterface {
    private let collectionRef = Firestore.firestore().collection("Music")
    
    // MARK: - 새로운 MusicEntity 추가
    
    /// MusicEntity를 데이터베이스에 추가하는 메서드
    /// - Parameter music: MusicEntity
    /// - Returns: 추가한 MusicEntity와 MusicRepositoryError를 각각 Output과 Error로 가지는 AnyPublisher
    func addMusic(_ music: MusicEntity) -> AnyPublisher<MusicEntity, MusicRepositoryError> {
        Future { [weak self] promise in
            guard let self else {
                promise(.failure(.nilSelf))
                return
            }
            
            do {
                // Firestore에 MusicEntity 추가
                let documentReference = self.collectionRef.document(music.id) // 문서 ID를 명시적으로 지정
                try documentReference.setData(from: music)
                promise(.success(music))
            } catch {
                promise(.failure(.custom(error)))
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
                promise(.failure(.nilSelf))
                return
            }
            
            self.collectionRef
                .whereField(FieldPath.documentID(), in: ids)
                .getDocuments { snapshot, error in
                    if let error {
                        promise(.failure(.custom(error)))
                        return
                    }
                    
                    if let result = snapshot?.documents.compactMap({ try? $0.data(as: MusicEntity.self)}) {
                        promise(.success(result))
                        return
                    }
                    
                    promise(.failure(.emptyData))
                    return
                }
             
            /*
            // 결과를 담을 배열 초기화
            var results: [MusicEntity] = []
            
            // 각 ID에 대해 문서를 조회하는 작업 그룹 생성
            let group = DispatchGroup()
            
            for id in ids {
                group.enter()
                self.collectionRef.document(id).getDocument { (document, error) in
                    defer { group.leave() }
                    
                    if let document = document, document.exists, let entity = try? document.data(as: MusicEntity.self) {
                        
                        results.append(entity)
//                        print("Repo에서 fetchMusic 한거임 \(results)")
                    } else if let error = error {
                        print("Error fetching document: \(error)")
                    }
                }
            }
            
            // 모든 작업이 완료될 때까지 대기
            group.notify(queue: .main) {
                promise(.success(results))
            }
             */
             
        }
        .eraseToAnyPublisher()
    }
    
    func fetchMusic(ofIds ids: [String]) async throws -> [MusicEntity] {
        let snapshot = try await self.collectionRef
            .whereField(FieldPath.documentID(), in: ids)
            .getDocuments()
        
        return snapshot.documents.compactMap { try? $0.data(as: MusicEntity.self) }
    }
    

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
