//
//  OnBoardingView.swift
//  Here-Hear
//
//  Created by Martin on 3/2/24.
//

import SwiftUI

struct OnBoardingView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var tabSelection: Int = 0
    
    private let tabCount: Int = 3
    private var progress: CGFloat {
        CGFloat(tabSelection + 1) / CGFloat(tabCount)
    }
    
    var body: some View {
        VStack {
            HHProgressBar(value: progress)
            
            TabView(selection: $tabSelection) {
                Text("Tab Content 0")
                    .tag(0)
                Text("Tab Content 1")
                    .tag(1)
                Text("Tab Content 2")
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        
    }
}

#Preview {
    OnBoardingView()
}
