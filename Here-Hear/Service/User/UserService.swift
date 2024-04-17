//
//  UserService.swift
//  Here-Hear
//
//  Created by Martin on 2/20/24.
//

import Foundation
import Combine

protocol UserServiceInterface {
    func fetchUser(ofId userId: String) -> AnyPublisher<UserModel?, ServiceError>
    func fetchUser(ofId userId: String) async throws -> UserModel?
    func addUser(_ user: UserModel) -> AnyPublisher<UserModel, ServiceError>
    func updateUser(_ user: UserModel) -> AnyPublisher<UserModel, ServiceError>
    func deleteUser(_ user: UserModel) -> AnyPublisher<UserModel, ServiceError>
}

class UserService: UserServiceInterface {
    
    private let repository: UserRepositoryInterface
    
    init(repository: UserRepositoryInterface) {
        self.repository = repository
    }
    
    // MARK: - 유저정보 가져오기
    
    /// userId가 주어졌을 때 해당하는 UserModel을 가져오는 메서드
    /// - Parameter userId: 가져올 사용자의 Id
    /// - Returns: AnyPublisher<UserModel, ServiceError>
    func fetchUser(ofId userId: String) -> AnyPublisher<UserModel?, ServiceError> {
        repository.fetchUser(ofId: userId)
            .map { $0?.toModel() }
            .mapError { ServiceError.error($0) }
            .eraseToAnyPublisher()
    }
    
    func fetchUser(ofId userId: String) async throws -> UserModel? {
        return try await repository.fetchUser(ofId: userId)?.toModel()
    }
    
    // MARK: - 유저정보 추가하기
    
    /// 리포지토리의 메서드 중 사용자 정보를 데이터베이스에 추가하는 메서드를 호출하는 메서드
    /// - Parameter user: 추가할 사용자정보 UserModel
    /// - Returns: 추가한 사용자 정보 UserMoldel 과 ServiceError 를 각각 Output, Error로 갖는 AnyPublisher
    func addUser(_ user: UserModel) -> AnyPublisher<UserModel, ServiceError> {
        repository.addUser(user.toEntity())
            .map { $0.toModel() }
            .mapError { ServiceError.error($0) }
            .eraseToAnyPublisher()
    }
    
    // MARK: - 유저정보 업데이트
    
    /// 사용자정보를 업데이트 할 때 호출하는 메서드
    /// - Parameter user: 업데이트된 UserModel
    /// - Returns: 업데이트된 UserModel과 ServiceError를 각각 Output, Error로 갖는 AnyPublisher
    func updateUser(_ user: UserModel) -> AnyPublisher<UserModel, ServiceError> {
        repository.updateUser(user.toEntity())
            .map { $0.toModel() }
            .mapError { ServiceError.error($0) }
            .eraseToAnyPublisher()
    }
    
    // MARK: - 유저정보 삭제
    
    /// 사용자 정보를 삭제할 때 호출하는 메서드
    /// - Parameter user: 삭제할 사용자정보 UserModel
    /// - Returns: 삭제한 UserModel과 ServiceError를 각각 Output, Error로 갖는 AnyPublisher
    func deleteUser(_ user: UserModel) -> AnyPublisher<UserModel, ServiceError> {
        repository.deleteUser(user.toEntity())
            .map { $0.toModel() }
            .mapError { ServiceError.error($0) }
            .eraseToAnyPublisher()
    }
}

class StubUserService: UserServiceInterface {
    func fetchUser(ofId userId: String) -> AnyPublisher<UserModel?, ServiceError> {
        Empty().eraseToAnyPublisher()
    }
    
    func fetchUser(ofId userId: String) async throws -> UserModel? {
        nil
    }
    
    func addUser(_ user: UserModel) -> AnyPublisher<UserModel, ServiceError> {
        Empty().eraseToAnyPublisher()
    }
    
    func updateUser(_ user: UserModel) -> AnyPublisher<UserModel, ServiceError> {
        Empty().eraseToAnyPublisher()
    }
    
    func deleteUser(_ user: UserModel) -> AnyPublisher<UserModel, ServiceError> {
        Empty().eraseToAnyPublisher()
    }
}
