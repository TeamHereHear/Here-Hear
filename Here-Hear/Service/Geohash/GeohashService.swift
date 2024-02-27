//
//  GeohashService.swift
//  Here-Hear
//
//  Created by Martin on 2/26/24.
//

import Foundation
import Geohash

protocol GeohashServiceInterface {
    func geohashExact(latitude: Double, longitude: Double) -> String
    func overlappingGeohash(latitude: Double, longitude: Double, precision: Int) -> [String]
    
}

class GeohashService: GeohashServiceInterface {
    /// 기준점의 정확한 Geohash(12글자 길이)
    /// - Parameters:
    ///   - latitude: 기준점의 위도
    ///   - longitude: 기준점의 경도
    /// - Returns: 12글자 길이의 Geohash
    func geohashExact(latitude: Double, longitude: Double) -> String {
        Geohash.encode(latitude: latitude, longitude: longitude, length: 12)
    }
    
    /// 기준점 반경에 걸쳐있는 Geohash를 구하는 메서드
    /// - Parameters:
    ///   - latitude: 기준점의 위도
    ///   - longitude: 기준점의 경도
    ///   - precision: Geohash 정확도(길이)
    /// - Returns: 기준점 반경에 걸쳐있는 Geohash
    func overlappingGeohash(latitude: Double, longitude: Double, precision: Int) -> [String] {
        let geohash = Geohash.encode(latitude: latitude, longitude: longitude, length: precision)
        let neighbors = Geohash.neighbors(geohash: geohash)
        
        let neighborsParents: [String] = neighbors.map { String($0.dropLast()) }
        
        return Array(Set(neighborsParents))
    }
}

class StubGeohashService: GeohashServiceInterface {
    func geohashExact(latitude: Double, longitude: Double) -> String {
        // 37.566406, 126.977822
        "wydm9qy2jtws"
    }
    func overlappingGeohash(latitude: Double, longitude: Double, precision: Int) -> [String] {
        []
    }
}
