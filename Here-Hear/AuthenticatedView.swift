//
//  ContentView.swift
//  Here-Hear
//
//  Created by 이원형 on 2/20/24.
//

import SwiftUI

struct AuthenticatedView: View {
    @StateObject var authViewModel: AuthViewModel

    var body: some View {
        VStack {
            switch authViewModel.authState {
                
            case .unauthenticated:
                LoginView()
            case .authenticated:
                MainView()
            }
        }.onAppear {
            authViewModel.send(action: .checkAuthenticationState)
            
        }.environmentObject(authViewModel)
    }
}

struct AuthenticatedView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticatedView(authViewModel: .init(container: .init(services: StubServices())))
    }
}
