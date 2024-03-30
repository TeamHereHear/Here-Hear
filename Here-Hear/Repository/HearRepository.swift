//
//  HearRepository.swift
//  Here-Hear
//
//  Created by Martin on 2/20/24.
//

import Foundation
import Combine
import CoreLocation

import FirebaseFirestore

enum HearRepositoryError: Error {
    case nilSelf
    case emptySearchingGeohash
    case invalidEntity
    case custom(Error)
}

protocol HearRepositoryInterface {
    func fetchAroundHears(
        from center: CLLocation,
        radiusInMeter radius: Double,
        inGeohashes geohashArray: [String]
    ) -> AnyPublisher<[HearEntity], HearRepositoryError>
    
    func fetchAroundHears(
        from center: CLLocation,
        radiusInMeter radius: Double,
        inGeohashes geohashArray: [String],
        startAt previousLastDocumentId: String?,
        limit: Int
    ) async throws -> (documents: [HearEntity], lastDocumentId: String?)
    
    func add(_ hear: HearEntity) -> AnyPublisher<HearEntity, HearRepositoryError>
    func update(_ hear: HearEntity) -> AnyPublisher<HearEntity, HearRepositoryError>
    func deleteHear(_ hear: HearEntity) -> AnyPublisher<Void, HearRepositoryError>
}

#warning("TODO: Firestore Cache Setting")
class HearRepository: HearRepositoryInterface {
    
    let collectionRef = Firestore.firestore().collection("Hear")

    func fetchAroundHears(
        from center: CLLocation,
        radiusInMeter radius: Double,
        inGeohashes geohashArray: [String]
    ) -> AnyPublisher<[HearEntity], HearRepositoryError> {
        Future { [weak self] promise in
            guard let self else {
                promise(.failure(.nilSelf))
                return
            }
            
            guard let precision = geohashArray.first?.count else {
                promise(.failure(.emptySearchingGeohash))
                return
            }
            
            self.completeFetchingAroundHears(
                locationOfCenter: center,
                radiusInMeter: radius,
                precision: precision,
                searchingIn: geohashArray,
                promise
            )
        }
        .eraseToAnyPublisher()
    }
    
    private func completeFetchingAroundHears(
        locationOfCenter: CLLocation,
        radiusInMeter radius: Double,
        precision: Int,
        searchingIn geohashArray: [String],
        _ promise: @escaping((Result<[HearEntity], HearRepositoryError>) -> Void)
    ) {
        self.collectionRef
            .whereField(.init(["location", "geohash\(precision)"]), in: geohashArray)
            .getDocuments { [weak self] snapshot, error in
                guard let self else {
                    promise(.failure(.nilSelf))
                    return
                }
                guard let snapshot else {
                    promise(.success([HearEntity]()))
                    return
                }
                
                if let error {
                    promise(.failure(HearRepositoryError.custom(error)))
                }
                
                let entities = snapshot.documents
                    .compactMap { try? $0.data(as: HearEntity.self) }
                    .filter {
                        self.isHearEntityInRadius(radiusInMeter: radius, from: locationOfCenter, $0)
                    }
                
                promise(.success(entities))
            }
    }
    
    func fetchAroundHears(
        from center: CLLocation,
        radiusInMeter radius: Double,
        inGeohashes geohashArray: [String],
        startAt previousLastDocumentId: String?,
        limit: Int
    ) async throws -> (documents: [HearEntity], lastDocumentId: String?) {
        guard let precision = geohashArray.first?.count else {
            throw HearRepositoryError.emptySearchingGeohash
        }
        var startDocument: DocumentSnapshot?
        
        if let previousLastDocumentId {
            startDocument = try? await self.collectionRef
                .document(previousLastDocumentId)
                .getDocument()
        }
        
        let query = self.collectionRef
            .whereField(.init(["location", "geohash\(precision)"]), in: geohashArray)
            .order(by: "createdAt", descending: true)
            .limit(to: limit)
        
        var result: ([HearEntity], String?)
        
        if let startDocument {
            result = try await query
                .start(afterDocument: startDocument)
                .getDocumentsWithSnapshot(as: HearEntity.self)
        } else {
            result = try await query.getDocumentsWithSnapshot(as: HearEntity.self)
        }
        
        result.0 = result.0.filter { isHearEntityInRadius(radiusInMeter: radius, from: center, $0) }
        
        return result
    }
    
    private func isHearEntityInRadius(
        radiusInMeter radius: Double,
        from center: CLLocation,
        _ entity: HearEntity
    ) -> Bool {
        let locationOfEntity = CLLocation(
            latitude: entity.location.latitude,
            longitude: entity.location.longitude
        )
        
        let distance: Double = locationOfEntity.distance(from: center)
        
        return distance <= radius
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
    func fetchAroundHears(
        from center: CLLocation,
        radiusInMeter radius: Double,
        inGeohashes geohashArray: [String],
        startAt previousLastDocumentId: String?,
        limit: Int
    ) async throws -> (documents: [HearEntity], lastDocumentId: String?) {
        ([],nil)
    }
    
    func fetchAroundHears(
        from center: CLLocation,
        radiusInMeter radius: Double,
        inGeohashes geohashArray: [String]
    ) -> AnyPublisher<[HearEntity], HearRepositoryError> {
        Empty().eraseToAnyPublisher()
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

extension Query {
    func getDocumentsWithSnapshot<T>(
        as: T.Type
    ) async throws -> (documents: [T], lastDocumentId: String?) where T: Decodable {
        let snapshot = try await self.getDocuments()
        
        return (snapshot.documents.compactMap { try? $0.data(as: T.self) }, snapshot.documents.last?.documentID)
    }
}
