//
//  HearRepository.swift
//  Here-Hear
//
//  Created by Martin on 2/20/24.
//

import Foundation
import Combine

import FirebaseFirestore

enum HearRepositoryError: Error {
    case nilSelf
    case invalidEntity
    case custom(Error)
}

protocol HearRepositoryInterface {
    func fetchAroundHears() -> AnyPublisher<[HearEntity], HearRepositoryError>
    func add(_ hear: HearEntity) -> AnyPublisher<HearEntity, HearRepositoryError>
    func update(_ hear: HearEntity) -> AnyPublisher<HearEntity, HearRepositoryError>
    func deleteHear(_ hear: HearEntity) -> AnyPublisher<Void, HearRepositoryError>
}

class HearRepository: HearRepositoryInterface {
    
    let collectionRef = Firestore.firestore().collection("Hear")

    func fetchAroundHears() -> AnyPublisher<[HearEntity], HearRepositoryError> {
        Empty().eraseToAnyPublisher()
        
    }
    
    // MARK: - 새로운 HearEntity 추가
    
    /// 데이터베이스에 HearEntity를 추가하는 메서드
    /// - Parameter hear: 추가할 HearEntity
    /// - Returns: 추가한 HearEntity와 HearRepositoryError를 각각 Output, Error값으로 갖는 AnyPublisher
    func add(_ hear: HearEntity) -> AnyPublisher<HearEntity, HearRepositoryError> {
        Future { [weak self] promise in
            guard let self else {
                promise(.failure(.nilSelf))
                return
            }
            
            do {
                try self.collectionRef
                    .addDocument(from: hear)
                promise(.success(hear))
            } catch {
                promise(.failure(.custom(error)))
            }
            
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - HearEntity 업데이트
    
    /// 데이터베이스에 저장되어있는 Entity를 업데이트 하는 메서드
    /// - Parameter hear: 수정사항이 반영된 HearEntity
    /// - Returns: 수정한 HearEntity와 HearRepositoryError를 각각 Output, Error값으로 갖는 AnyPublisher
    func update(_ hear: HearEntity) -> AnyPublisher<HearEntity, HearRepositoryError> {
        Future { [weak self] promise in
            guard let self else {
                promise(.failure(.nilSelf))
                return
            }
            
            do {
                try self.collectionRef
                    .document(hear.id)
                    .setData(from: hear, merge: true)
                promise(.success(hear))
            } catch {
                promise(.failure(.custom(error)))
            }
        }
        .eraseToAnyPublisher()
    }
    
    /// 데이터베이스에 저장된 HearEntity를 삭제하는 메서드
    /// - Parameter hear: 삭제할 HearEntity
    /// - Returns: AnyPublisher<Void, HearRepositoryError>
    func deleteHear(_ hear: HearEntity) -> AnyPublisher<Void, HearRepositoryError> {
        Future { [weak self] promise in
            guard let self else {
                promise(.failure(.nilSelf))
                return
            }
            
            collectionRef
                .document(hear.id)
                .delete { error in
                    if let error {
                        promise(.failure(HearRepositoryError.custom(error)))
                    }
                }
            
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }
    
}

class StubHearRepository: HearRepositoryInterface {
    
    func fetchAroundHears() -> AnyPublisher<[HearEntity], HearRepositoryError> {
        guard let mock = HearEntity.mock else {
            return Fail<[HearEntity], HearRepositoryError>(error: .invalidEntity).eraseToAnyPublisher()
        }
        
        return Just([mock])
            .setFailureType(to: HearRepositoryError.self)
            .eraseToAnyPublisher()
    }
    
    func add(_ hear: HearEntity) -> AnyPublisher<HearEntity, HearRepositoryError> {
        Just(hear)
            .setFailureType(to: HearRepositoryError.self)
            .eraseToAnyPublisher()
    }
    
    func update(_ hear: HearEntity) -> AnyPublisher<HearEntity, HearRepositoryError> {
        Just(hear)
            .setFailureType(to: HearRepositoryError.self)
            .eraseToAnyPublisher()
    }
    
    func deleteHear(_ hear: HearEntity) -> AnyPublisher<Void, HearRepositoryError> {
        Just(())
            .setFailureType(to: HearRepositoryError.self)
            .eraseToAnyPublisher()
    }
}
