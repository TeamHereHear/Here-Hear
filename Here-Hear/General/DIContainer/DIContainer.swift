//
//  DIContainer.swift
//  Here-Hear
//
//  Created by Martin on 2/20/24.
//

import Foundation

class DIContainer: ObservableObject {
    var services: ServicesInterface
    
    init(services: ServicesInterface) {
        self.services = services
    }
}
