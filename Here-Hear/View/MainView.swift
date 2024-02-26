//
//  MainView.swift
//  Here-Hear
//
//  Created by 이원형 on 2/20/24.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack {
            Text("this is MainView")
                .padding()
            
            Button(action: {
                authViewModel.send(action: .logout)
            }, label: {
                Text("로그아웃")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color("HHTertiary"))
                    .cornerRadius(50)
            })
        }
    }
}

#Preview {
    MainView()
}
