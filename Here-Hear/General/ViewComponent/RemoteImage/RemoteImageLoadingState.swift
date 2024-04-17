//
//  RemoteImageLoadingState.swift
//  Here-Hear
//
//  Created by Martin on 3/11/24.
//

import Foundation

enum RemoteImageLoadingState: Hashable {
    case none
    case loading
    case finished
    case failed
}
