//
//  UserEntity.swift
//  Here-Hear
//
//  Created by 이원형 on 2/20/24.
//

import Foundation

struct UserEntity {
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
}
