//
//  UserModel.swift
//  Here-Hear
//
//  Created by 이원형 on 2/20/24.
//

import Foundation

struct UserModel {
    var id: String
    var nickname: String
    var createdAt: Date
}

extension UserModel {
    func toEntity() -> UserEntity {
        .init(
            id: id,
            nickname: nickname,
            createdAt: createdAt
        )
    }
}
