//
//  RegisterProfileView.swift
//  Here-Hear
//
//  Created by Martin on 3/2/24.
//

import SwiftUI

struct RegisterProfileView: View {
    @State private var stage: Int = 0
    
    var body: some View {
        TabView(selection: $stage) {
            Button{
                stage = 1
            } label: {
                Text("Next")
            }
            .tag(0)
                
            Text("Tab Content 2").tag(1)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))

    }
}

#Preview {
    RegisterProfileView()
}
