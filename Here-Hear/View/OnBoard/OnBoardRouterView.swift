//
//  OnBoardRouterView.swift
//  Here-Hear
//
//  Created by Martin on 3/2/24.
//

import SwiftUI

struct OnBoardRouterView: View {
    @StateObject private var viewModel: OnBoardRouterViewModel
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var container: DIContainer
    
    @AppStorage(UserDefaultsKey.OnBoarding) var didAnonymousUserHasOnboarded: Bool = false

    init(viewModel: OnBoardRouterViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            switch viewModel.onBoardRoute {
            case .none:
                ProgressView()
            case .existingUser:
                /// 이미 등록되어 있다면
                MainView(viewModel: .init(container: container))
            case .newUser:
                /// 등록되어 있는 UserModel 이 없다면
                RegisterNicknameView(viewModel: .init(container: container))
            case .anonymousUser:
                /// 익명사용자라면
                if didAnonymousUserHasOnboarded {
                    MainView(viewModel: .init(container: container))
                } else {
                    anonymousUserDestination
                }
            case .failed:
                /// 실패했다면
                ProgressView()
                    .onAppear {
                        authViewModel.send(action: .logout)
                    }
            }
        }
        .onAppear {
            viewModel.setOnBoardRoute()
        }
    }
    
    @ViewBuilder
    var anonymousUserDestination: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                OnBoardingView()
            }
        } else {
            NavigationView {
                OnBoardingView()
            }
        }
    }
}
