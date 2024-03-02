//
//  RegisterNicknameView.swift
//  Here-Hear
//
//  Created by Martin on 3/2/24.
//

import SwiftUI
import Combine

struct RegisterNicknameView: View {
    @State private var nickname: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("닉네임을 만들어주세요 :)")
                .font(.largeTitle)
                .fontWeight(.heavy)
            
            Spacer()
            
            NicknameTextField(nickname: $nickname)
                .focused($isFocused)
                .submitLabel(.continue)
                .onSubmit {
                    print("Submit")
                }
            Spacer()
        }
        .padding(.horizontal, 17)
        .onAppear {
            isFocused = true
        }
    }
}

#Preview { 
    RegisterNicknameView()
}
