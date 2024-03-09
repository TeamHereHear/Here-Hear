//
//  MainView.swift
//  Here-Hear
//
//  Created by 이원형 on 2/20/24.
//

import SwiftUI
import AuthenticationServices

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
            
            if authViewModel.isAnonymousUser {
                Button(action: {
                    authViewModel.send(action: .linkGoogleLogin)
                }, label: {
                    Text("구글 계정으로 로그인")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color("HHTertiary"))
                        .cornerRadius(50)
                })
                
                SignInWithAppleButton { request in
                    authViewModel.send(action: .appleLogin(request))
                } onCompletion: { result in
                    authViewModel.send(action: .linkAppleLoginCompletion(result))
                }
                .frame(height: 45)
                .padding(.horizontal, 40)
            }
        }
        .onAppear {
            authViewModel.send(action: .checkAnonymousUser)
        }   
    }
}

#Preview {
    MainView()
}
