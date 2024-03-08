//
//  RegisterProfileImageView.swift
//  Here-Hear
//
//  Created by Martin on 3/2/24.
//

import SwiftUI

struct RegisterProfileImageView: View {
    @StateObject private var viewModel: RegisterProfileImageViewModel
    
    init(viewModel: RegisterProfileImageViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        content
            .navigationAdaptor(isPresented: $viewModel.didComplete) {
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
                    Button {
                        viewModel.send(.skip)
                    } label: {
                        Text("건너뛰기")
                    }

                    Spacer()
                
                    Button {
                        viewModel.send(.upload)
                    } label: {
                        Text("저장")
                    }
                
                }
            }
        }
    }
    
    private var profileImagePickerButton: some View {
        Button {
            DispatchQueue.main.async {
                viewModel.send(.showImagePicker)
            }
        } label: {
            Circle()
                .foregroundStyle(.hhGray)
                .overlay {
                    if let profileImage = viewModel.image {
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
        .sheet(isPresented: $viewModel.showProfileImagePicker) {
            ProfileImagePicker(image: $viewModel.image)
        }
    }
}
