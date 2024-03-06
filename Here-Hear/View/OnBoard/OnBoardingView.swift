//
//  OnBoardingView.swift
//  Here-Hear
//
//  Created by Martin on 3/2/24.
//

import SwiftUI

struct OnBoardingView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    
    var body: some View {
        Button {
            authViewModel.send(action: .logout)
        } label: {
            Text("logout")
        }
        
    }
}

#Preview {
    OnBoardingView()
}
