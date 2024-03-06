//
//  RegisterProfileImageView.swift
//  Here-Hear
//
//  Created by Martin on 3/2/24.
//

import SwiftUI

struct RegisterProfileImageView: View {
    @State private var showProfileImagePicker: Bool = false
    @State private var profileImage: UIImage?
    @State private var didSetProfile: Bool = false
    
    var body: some View {
        content
            .navigationAdaptor(isPresented: $didSetProfile) {
                OnBoardingView()
            }
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 18) {
            HHProgressBar(value: 1)
                .padding(.horizontal, -5)
            Text("프로필 사진을 저장해 주세요.")
                .font(.title)
                .fontWeight(.heavy)
            Spacer()
            profileImagePickerButton
                .padding(.horizontal, -17)
            Spacer()
        }
        .padding(.horizontal, 17)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    NavigationLink {
                        
                    } label: {
                        Text("건너뛰기")
                    }

                    Spacer()
                
                    Button {
                        
                    } label: {
                        Text("저장")
                    }
                
                }
            }
        }
    }
    
    private var profileImagePickerButton: some View {
        Button {
            showProfileImagePicker = true
        } label: {
            Circle()
                .foregroundStyle(.hhGray)
                .overlay {
                    if let profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .scaledToFill()
                            .clipShape(.circle)
                            .padding(8)
                           
                    } else {
                        Image(systemName: "hare")
                            .font(.largeTitle)
                            .foregroundStyle(.hhAccent2)
                            .padding(8)
                    }
                }
                .padding(41)
        }
        .sheet(isPresented: $showProfileImagePicker) {
            ProfileImagePicker(image: $profileImage)
        }
    }
}

#Preview {
    NavigationView {
        RegisterProfileImageView()
    }
        
}
