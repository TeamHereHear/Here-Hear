//
//  UserEntity.swift
//  Here-Hear
//
//  Created by 이원형 on 2/20/24.
//

import Foundation

struct UserEntity: Codable {
    var id: String
    var nickname: String
    var createdAt: Date
}

extension UserEntity {
    func toModel() -> UserModel {
        .init(
            id: id,
            nickname: nickname,
            createdAt: createdAt
        )
    }
    func toDictionary() -> [String: Any] {
        let dateFomatter = DateFormatter()
        dateFomatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let createdAtString = dateFomatter.string(from: createdAt)
        
        return [
            "id": id,
            "nickname": nickname,
            "createdAt": createdAtString
        ]
    }
}
