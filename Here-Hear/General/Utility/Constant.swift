//
//  Constant.swift
//  Here-Hear
//
//  Created by Martin on 4/8/24.
//

import Foundation



enum Constant {}

typealias UserDefaultsKey = Constant.UserDefaultsKey
typealias StoragePath = Constant.StoragePath

extension Constant {
    struct UserDefaultsKey {
        static let OnBoarding: String = "onBoarding"
    }
    
    struct StoragePath {
        static let UserInfo: String = "UserInfo"
    }
}
