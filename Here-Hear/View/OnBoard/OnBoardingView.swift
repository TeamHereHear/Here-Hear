//
//  OnBoardingView.swift
//  Here-Hear
//
//  Created by Martin on 3/2/24.
//

import SwiftUI

struct OnBoardingView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var didCompleteOnboard: Bool = false
    
    var body: some View {
        Button {
            authViewModel.send(action: .logout)
        } label: {
            Text("logout")
        }
        .navigationAdaptor(isPresented: $didCompleteOnboard) {
            MainView()
        }
        .navigationBarBackButtonHidden()
        
    }
}

#Preview {
    OnBoardingView()
}
