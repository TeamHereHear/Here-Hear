//
//  DIContainer.swift
//  Here-Hear
//
//  Created by Martin on 2/20/24.
//

import Foundation

class DIContainer: ObservableObject {
    var services: ServicesInterface
    var managers: ManagersProtocol
    
    init(
        services: ServicesInterface,
        managers: ManagersProtocol
    ) {
        self.services = services
        self.managers = managers
    }
}
