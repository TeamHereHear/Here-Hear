//
//  FeelingEntity.swift
//  Here-Hear
//
//  Created by 이원형 on 2/20/24.
//

import Foundation

struct FeelingEntity {
    var expressionText: String?
    var colorHexString: String?
    var textLocation: [Double]?
}

extension FeelingEntity {
    func toModel() -> FeelingModel {
        .init(
            expressionText: expressionText,
            color: .init(hexString: colorHexString ?? "FFFFFF"),
            textLocation: .init(doubleArray: textLocation ?? [])
        )
    }
}
