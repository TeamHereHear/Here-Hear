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
//    init() {
//        let appearance = UINavigationBarAppearance()
//        appearance.backgroundColor = UIColor.systemPink // 네비게이션 바의 배경색 설정
//        appearance.titleTextAttributes = [.foregroundColor: UIColor.white] // 네비게이션 바 타이틀 색상 설정
//        
//        // UINavigationBar의 모든 인스턴스에 대한 기본 외관 설정
//        UINavigationBar.appearance().standardAppearance = appearance
//        UINavigationBar.appearance().scrollEdgeAppearance = appearance
//    }

    var body: some Scene {
        WindowGroup {
            AuthenticatedView(authViewModel: .init(container: container))
                .environmentObject(container)
           
        }
    }
}
