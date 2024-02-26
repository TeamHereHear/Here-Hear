//
//  LoginView.swift
//  Here-Hear
//
//  Created by 이원형 on 2/23/24.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    var body: some View {
        VStack {
            Spacer()
            
            Image("Here,HearAppIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 300, height: 300)
                .cornerRadius(50)
            Group {
                Text("여기서는 무슨 노래 듣지?")
                    .font(.headline)
                    .fontWeight(.regular)
                    .foregroundColor(.gray)
                
                Text("음악으로 기억되는 공간")
                    .font(.headline)
                    .fontWeight(.regular)
                    .foregroundColor(.gray)
                                
                Text("Here, Hear")
                    .font(.largeTitle)
                    .foregroundColor(Color("HHAccent"))
                
            }
            Button {
                authViewModel.send(action: .anonymousLogin)
            } label: {
                Text("로그인 없이 바로 실행하기")
            }.buttonStyle(LoginButtonStyle(textColor: .black, borderColor: Color("HHTertiary"), backgroundColor: Color("HHTertiary")))
            Spacer()
            
            Button {
                authViewModel.send(action: .googleLogin)
            } label: {
                Text("Google로 로그인")
            }.buttonStyle(LoginButtonStyle(textColor: .black, borderColor: Color("HHTertiary"), backgroundColor: Color("HHTertiary")))

            SignInWithAppleButton { request in
                authViewModel.send(action: .appleLogin(request))
            } onCompletion: { result in
                authViewModel.send(action: .appleLoginCompletion(result))
            }.frame(height: 45)
                .padding(.horizontal, 40)

            Spacer()
            
            HStack(spacing: 20) {
                Button(action: {
                    // TODO: 개인정보 처리방침 페이지 연결
                }) {
                    Text("개인정보 처리방침")
                        .font(.caption2)
                        .foregroundColor(.black)
                }
                Button(action: {
                    // TODO: 위치정보 이용약관 페이지 연결
                }) {
                    Text("위치정보 이용약관")
                        .font(.caption2)
                        .foregroundColor(.black)
                }
                Button(action: {
                    // TODO: 서비스 이용약관 페이지 연결
                }) {
                    Text("서비스 이용약관")
                        .font(.caption2)
                        .foregroundColor(.black)
                }
            }
        }.overlay {
            if authViewModel.isLoading {
                ProgressView()
            }
        }
    }
}

#Preview {
    LoginView()
}
