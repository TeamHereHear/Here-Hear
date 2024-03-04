//
//  RegisterNicknameView.swift
//  Here-Hear
//
//  Created by Martin on 3/2/24.
//

import SwiftUI
import Combine

struct RegisterNicknameView: View {
    @StateObject private var viewModel: RegisterNicknameViewModel
    @FocusState private var isFocused: Bool
    
    init(viewModel: RegisterNicknameViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                content
                    .navigationDestination(isPresented: $viewModel.didSetNickname) {
                        RegisterProfileImageView()
                    }
            }
        } else {
            NavigationView {
                content
                    .overlay {
                        NavigationLink(
                            destination: RegisterProfileImageView(),
                            isActive: $viewModel.didSetNickname,
                            label: {
                                EmptyView()
                            })
                    }
            }
        }
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 18) {
            HHProgressBar(value: 0.5)
                .padding(.horizontal, -5)
            Text("닉네임을 만들어주세요 :)")
                .font(.largeTitle)
                .fontWeight(.heavy)
            
            Spacer()

            NicknameTextField(
                nickname: $viewModel.nickname,
                isValid: $viewModel.isValidNickname
            )
            .focused($isFocused)
           
            Spacer()
        }
        .padding(.horizontal, 17)
        .onAppear {
            isFocused = true
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Spacer()
                
                    Button {
                        viewModel.registerNickname()
                    } label: {
                        Text("저장")
                    }
                    .disabled(!viewModel.isValidNickname)
                }
            }
        }
        
    }
}

#Preview {
    RegisterNicknameView(
        viewModel: .init(
            container: .init(
                services: StubServices()
            )
        )
    )
}
