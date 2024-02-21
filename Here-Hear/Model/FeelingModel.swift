//
//  FeelingModel.swift
//  Here-Hear
//
//  Created by 이원형 on 2/20/24.
//

import Foundation
import SwiftUI

struct FeelingModel {
    var expressionText: String?
    var color: Color?
    var textLocation: CGPoint?
}

extension FeelingModel {
    func toEntity() -> FeelingEntity {
        .init(
            expressionText: expressionText,
            colorHexString: color?.toHex(),
            textLocation: textLocation?.toDoubleArray()
        )
    }
}
