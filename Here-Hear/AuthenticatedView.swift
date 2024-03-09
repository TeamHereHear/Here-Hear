//
//  ContentView.swift
//  Here-Hear
//
//  Created by 이원형 on 2/20/24.
//

import SwiftUI

struct AuthenticatedView: View {
    @EnvironmentObject private var container: DIContainer
    @StateObject var authViewModel: AuthViewModel

    var body: some View {
        VStack {
            switch authViewModel.authState {
            case .unauthenticated:
                LoginView()
            case .authenticated:
                OnBoardRouterView(viewModel: .init(container: container))
            }
        }.onAppear {
            authViewModel.send(action: .checkAuthenticationState)
            
        }.environmentObject(authViewModel)
    }
}

#Preview {
    let container: DIContainer = .init(services: StubServices())
    return AuthenticatedView(authViewModel: .init(container: container))
        .environmentObject(container)
}
