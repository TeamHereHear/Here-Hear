//
//  FeelingEntity+Mock.swift
//  Here-Hear
//
//  Created by Martin on 2/22/24.
//

import Foundation

extension FeelingEntity {
    static var mock: FeelingEntity {
        .init(
            expressionText: "오늘은 눈이 펑펑 내리네",
            colorHexString: "FFFFFF",
            textLocation: [100, 100]
        )
    }
}
