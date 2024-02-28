//
//  HearService.swift
//  Here-Hear
//
//  Created by Martin on 2/20/24.
//

import Foundation
import Combine

protocol HearServiceInterface {
    func fetchAroundHears(
        latitude: Double,
        longitude: Double,
        radiusInMeter radius: Double,
        searchingIn geohashArray: [String]
    ) -> AnyPublisher<[HearModel], ServiceError>
    func addHear(_ hear: HearModel) -> AnyPublisher<HearModel, ServiceError>
    func updateHear(_ hear: HearModel) -> AnyPublisher<HearModel, ServiceError>
    func deleteHear(_ hear: HearModel) -> AnyPublisher<Void, ServiceError>
}

class HearService: HearServiceInterface {
    private let repository: HearRepositoryInterface

    init(repository: HearRepositoryInterface) {
        self.repository = repository
    }
    
    func fetchAroundHears(
        latitude: Double,
        longitude: Double,
        radiusInMeter radius: Double,
        searchingIn geohashArray: [String]
    ) -> AnyPublisher<[HearModel], ServiceError> {
        repository.fetchAroundHears(
            latitude: latitude,
            longitude: longitude,
            radiusInMeter: radius,
            searchingIn: geohashArray
        )
        .map { $0.map { $0.toModel() } }
        .mapError { ServiceError.error($0)}
        .eraseToAnyPublisher()
    }
    
    func addHear(_ hear: HearModel) -> AnyPublisher<HearModel, ServiceError> {
        guard let entity = hear.toEntity() else {
            return Fail(error: ServiceError.error(HearRepositoryError.invalidEntity))
                .eraseToAnyPublisher()
        }
        return repository.add(entity)
            .map { $0.toModel() }
            .mapError { ServiceError.error($0) }
            .eraseToAnyPublisher()
    }
    
    func updateHear(_ hear: HearModel) -> AnyPublisher<HearModel, ServiceError> {
        guard let entity = hear.toEntity() else {
            return Fail(error: ServiceError.error(HearRepositoryError.invalidEntity))
                .eraseToAnyPublisher()
        }
        return repository.update(entity)
            .map { $0.toModel() }
            .mapError { ServiceError.error($0) }
            .eraseToAnyPublisher()
    }
    
    func deleteHear(_ hear: HearModel) -> AnyPublisher<Void, ServiceError> {
        guard let entity = hear.toEntity() else {
            return Fail(error: ServiceError.error(HearRepositoryError.invalidEntity))
                .eraseToAnyPublisher()
        }
        return repository.deleteHear(entity)
            .mapError { ServiceError.error($0)}
            .eraseToAnyPublisher()
    }
}

class StubHearService: HearServiceInterface {
    func fetchAroundHears(
        latitude: Double,
        longitude: Double,
        radiusInMeter radius: Double,
        searchingIn geohashArray: [String]
    ) -> AnyPublisher<[HearModel], ServiceError> {
        Empty().eraseToAnyPublisher()
    }
    
    func addHear(_ hear: HearModel) -> AnyPublisher<HearModel, ServiceError> {
        Just(hear).setFailureType(to: ServiceError.self).eraseToAnyPublisher()
    }
    
    func updateHear(_ hear: HearModel) -> AnyPublisher<HearModel, ServiceError> {
        Just(hear).setFailureType(to: ServiceError.self).eraseToAnyPublisher()
    }
    
    func deleteHear(_ hear: HearModel) -> AnyPublisher<Void, ServiceError> {
        Just(()).setFailureType(to: ServiceError.self).eraseToAnyPublisher()
    }
    
}
