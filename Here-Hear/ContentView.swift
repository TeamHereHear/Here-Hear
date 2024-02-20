//
//  ContentView.swift
//  Here-Hear
//
//  Created by 이원형 on 2/20/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var container: DIContainer
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .environmentObject(DIContainer(services: StubServices()))
}
