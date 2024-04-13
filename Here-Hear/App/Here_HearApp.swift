//
//  Here_HearApp.swift
//  Here-Hear
//
//  Created by 이원형 on 2/20/24.
//

import SwiftUI

@main
struct Here_HearApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var container: DIContainer = DIContainer(services: Services(), managers: Managers())

    var body: some Scene {
        WindowGroup {
            AuthenticatedView(authViewModel: .init(container: container))
                .environmentObject(container)
                .onAppear {
                    container.managers.musicManager.setupMusic()
                    container.managers.audioSessionManager.configureAudioSession()
                }
        }
        
    }
}
