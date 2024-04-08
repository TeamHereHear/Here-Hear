//
//  OnBoardingView.swift
//  Here-Hear
//
//  Created by Martin on 3/2/24.
//

import SwiftUI

struct OnBoardingView: View {
    @State private var tabSelection: Int = 0
    @State private var isMainViewPresented: Bool = false
    @EnvironmentObject private var container: DIContainer
    private let tabCount: Int = 3
    private var progress: CGFloat {
        CGFloat(tabSelection + 1) / CGFloat(tabCount)
    }
    
    var body: some View {
        VStack {
            HHProgressBar(value: progress)
                .padding(.horizontal, 12)
            
            TabView(selection: $tabSelection) {
                OnBoardingPageOne($tabSelection)
                    .tag(0)
                OnBoardingPageTwo($tabSelection)
                    .tag(1)
                OnBoardingPageThree($isMainViewPresented)
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .navigationAdaptor(isPresented: $isMainViewPresented) {
                MainView(viewModel: .init(container: container))
            }
        }
        
    }
}

#Preview {
    OnBoardingView()
        .environmentObject(
            DIContainer(
                services: StubServices(),
                managers: StubManagers()
            )
        )
}
