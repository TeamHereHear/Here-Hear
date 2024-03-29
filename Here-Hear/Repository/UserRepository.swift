//
//  UserRepository.swift
//  Here-Hear
//
//  Created by Martin on 2/20/24.
//

import Foundation
import Combine
import FirebaseFirestore

enum UserRepositoryError: Error {
    case notFound
    case dataUnavailable
    case networkError
    case error(Error)
}

protocol UserRepositoryInterface {
    func fetchUser(ofId userId: String) -> AnyPublisher<UserEntity?, UserRepositoryError>
    func fetchUser(ofId userId: String) async throws -> UserEntity?
    func addUser(_ user: UserEntity) -> AnyPublisher<UserEntity, UserRepositoryError>
    func updateUser(_ user: UserEntity) -> AnyPublisher<UserEntity, UserRepositoryError>
    func deleteUser(_ user: UserEntity) -> AnyPublisher<UserEntity, UserRepositoryError>
}

#warning("TODO: Firestore Cache Setting")
class UserRepository: UserRepositoryInterface {
    private var database = Firestore.firestore()
    
    // MARK: 기존 유저 정보 FireStore에서 가져오기
    func fetchUser(ofId userId: String) -> AnyPublisher<UserEntity?, UserRepositoryError> {
        let subject = PassthroughSubject<UserEntity?, UserRepositoryError>()
        
        database.collection("User").document(userId).getDocument { document, error  in
            if let error {
                subject.send(completion: .failure(.error(error)))
                return
            }
            
            if let document = document, document.exists {
                do {
                    let user = try document.data(as: UserEntity?.self)
                    subject.send(user)
                    subject.send(completion: .finished)
                } catch {
                    subject.send(completion: .failure(.dataUnavailable))
                }
            } else {
                subject.send(nil)
                subject.send(completion: .finished)
            }
        }
        
        return subject.eraseToAnyPublisher()
    }
    
    func fetchUser(ofId userId: String) async throws -> UserEntity? {
        return try await database.collection("User").document(userId).getDocument(as: UserEntity?.self)
    }
    
    // MARK: 새로운 유저 추가하기
    func addUser(_ user: UserEntity) -> AnyPublisher<UserEntity, UserRepositoryError> {
        let subject = PassthroughSubject<UserEntity, UserRepositoryError>()
        
        database.collection("User").document(user.id).setData(user.toDictionary()) { error in
            if error != nil {
                subject.send(completion: .failure(.dataUnavailable))
                return
            }
            
            subject.send(user)
            subject.send(completion: .finished)
        }

        return subject.eraseToAnyPublisher()
    }
    // MARK: 기존 유저 정보 변경하기
    func updateUser(_ user: UserEntity) -> AnyPublisher<UserEntity, UserRepositoryError> {
        let subject = PassthroughSubject<UserEntity, UserRepositoryError>()
        
        database.collection("User").document(user.id).updateData(user.toDictionary()) { error in
            if error != nil {
                subject.send(completion: .failure(.dataUnavailable))
            } else {
                subject.send(user)
                subject.send(completion: .finished)
            }
        }
        
        return subject.eraseToAnyPublisher()
    }
    
    // MARK: 유저 정보 삭제하기
    func deleteUser(_ user: UserEntity) -> AnyPublisher<UserEntity, UserRepositoryError> {
        let subject = PassthroughSubject<UserEntity, UserRepositoryError>()
        
        database.collection("User").document(user.id).delete { _ in
            subject.send(user)
            subject.send(completion: .finished)
        }
        
        return subject.eraseToAnyPublisher()
    }
    
}

class StubUserRepository: UserRepositoryInterface {
    // 예제 데이터
    private var userArr: [String: UserEntity] = [:]
    
    init() {
        let testUser = UserEntity(
            id: "1",
            nickname: "ThisIsWonhyeong",
            createdAt: Date()
        )
        userArr[testUser.id] = testUser
    }
    
    func fetchUser(ofId userId: String) -> AnyPublisher<UserEntity?, UserRepositoryError> {
        if let user = userArr[userId] {
            return Just(user).setFailureType(to: UserRepositoryError.self).eraseToAnyPublisher()
        } else {
            // 사용자 정보 존재하지 않을 경우, .notFound 에러 반환
            return Fail(error: UserRepositoryError.notFound).eraseToAnyPublisher()
        }
    }
    func fetchUser(ofId userId: String) async throws -> UserEntity? {
        nil
    }
    
    func addUser(_ user: UserEntity) -> AnyPublisher<UserEntity, UserRepositoryError> {
        userArr[user.id] = user
        return Just(user).setFailureType(to: UserRepositoryError.self).eraseToAnyPublisher()
    }
    
    func updateUser(_ user: UserEntity) -> AnyPublisher<UserEntity, UserRepositoryError> {
        if userArr[user.id] != nil {
            userArr[user.id] = user
            return Just(user).setFailureType(to: UserRepositoryError.self).eraseToAnyPublisher()
        } else {
            return Fail(error: UserRepositoryError.notFound).eraseToAnyPublisher()
        }
    }
    
    func deleteUser(_ user: UserEntity) -> AnyPublisher<UserEntity, UserRepositoryError> {
        if userArr.removeValue(forKey: user.id) != nil {
            return Just(user).setFailureType(to: UserRepositoryError.self).eraseToAnyPublisher()
        } else {
            return Fail(error: UserRepositoryError.notFound).eraseToAnyPublisher()
        }
    }
 }
