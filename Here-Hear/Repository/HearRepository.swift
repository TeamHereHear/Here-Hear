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
    
}

protocol HearRepositoryInterface {
    func fetchAroundHears() -> AnyPublisher<[HearEntity], HearRepositoryError>
    func add(_ hear: HearEntity) -> AnyPublisher<HearEntity, HearRepositoryError>
    func update(_ hear: HearEntity) -> AnyPublisher<HearEntity, HearRepositoryError>
    func deleteHear(_ hear: HearEntity) -> AnyPublisher<Void, HearRepositoryError>
}

class HearRepository: HearRepositoryInterface {
    
    //TODO: 프로토콜을 생성하여 파이어배이스와의 느슨한 결합이 필요
    let collectionRef = Firestore.firestore().collection("Hear")

    func fetchAroundHears() -> AnyPublisher<[HearEntity], HearRepositoryError> {
        Empty().eraseToAnyPublisher()
    }
    
    func add(_ hear: HearEntity) -> AnyPublisher<HearEntity, HearRepositoryError> {
        Empty().eraseToAnyPublisher()
    }
    
    func update(_ hear: HearEntity) -> AnyPublisher<HearEntity, HearRepositoryError> {
        Empty().eraseToAnyPublisher()
    }
    
    func deleteHear(_ hear: HearEntity) -> AnyPublisher<Void, HearRepositoryError> {
        Empty().eraseToAnyPublisher()
    }
}

class StubHearRepository: HearRepositoryInterface {
    
    func fetchAroundHears() -> AnyPublisher<[HearEntity], HearRepositoryError> {
        Just([.mock])
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


//var id: String
//var userId: String
//var coordinate: CLLocationCoordinate2D
//var music: MusicEntity
//var feeling: FeelingEntity
//var like: Int
//var createdAt: Date
//var weather: String?
