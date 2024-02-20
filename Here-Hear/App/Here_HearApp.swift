//
//  Here_HearApp.swift
//  Here-Hear
//
//  Created by 이원형 on 2/20/24.
//

import SwiftUI

@main
struct Here_HearApp: App {
    @StateObject private var container: DIContainer = DIContainer(services: Services())
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(container)
        }
    }
}
