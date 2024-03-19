//
//  OnBoardingPageThree.swift
//  Here-Hear
//
//  Created by Martin on 3/14/24.
//

import SwiftUI

struct OnBoardingPageThree: View {
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 85)
            Spacer()
                .frame(height: 37)
            Text("onBoardingPageThree.title")
                .onBoadingTitleStyle()
            
            Spacer()
            
            HStack {
                Spacer()
                Button {
                    
                } label: {
                    Text("onBoadingPageOne.Next")
                        .font(.system(size: 19, weight: .semibold))
                }
            }
            .padding(.horizontal, 21)
        }
    }
}

#Preview {
    OnBoardingPageThree()
}
