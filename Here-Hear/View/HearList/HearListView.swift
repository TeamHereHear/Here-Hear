//
//  HearListView.swift
//  Here-Hear
//
//  Created by Martin on 3/25/24.
//

import SwiftUI

struct HearListView: View {
    @Binding private var shouldPresentHearList: Bool
    
    init(present shouldPresentHearList: Binding<Bool>) {
        self._shouldPresentHearList = shouldPresentHearList
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .trailing) {
                Menu {
                    
                } label: {
                    Label{
                        Text("거리순")
                    } icon: {
                        Image(systemName: "arrow.up.arrow.down.circle.fill")
                    }
                }
                .padding(.horizontal)
                
                List {
                    HearListCell(
                        hear: .mocks.first ?? .init(
                            id: "1",
                            userId: "1",
                            location: .init(latitude: 33, longitude: 120, geohashExact: "ggggg"),
                            musicIds: [],
                            feeling: .init(),
                            like: 100,
                            createdAt: .now
                        ),
                        userNickname: "Seokjun",
                        music: .onBoardingPageMockOne
                    )
                    .listRowSeparator(.visible)
                }
                .listStyle(.plain)
            }
            .navigationTitle(String(localized: "hearListView_title", defaultValue: "Hear List"))
            .toolbar {
                Button {
                    shouldPresentHearList = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 20))
                }
            }
        }
        
    }
}

#Preview {
    HearListView(present: .constant(true))
        .environmentObject(
            DIContainer(
                services: StubServices(),
                managers: StubManagers()
            )
        )
}
