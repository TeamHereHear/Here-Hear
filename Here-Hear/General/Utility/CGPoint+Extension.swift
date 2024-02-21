//
//  CGPoint+extension.swift
//  Here-Hear
//
//  Created by 이원형 on 2/21/24.
//

import Foundation

extension CGPoint {
    init?(doubleArray: [Double]) {
        guard doubleArray.count == 2 else {return nil}
        
        self.init(x: doubleArray[0], y: doubleArray[1])
    }
}

extension CGPoint {
    func toDoubleArray() -> [Double] {
        [Double(self.x), Double(self.y)]
    }
}
