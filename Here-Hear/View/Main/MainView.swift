//
//  MainView.swift
//  Here-Hear
//
//  Created by 이원형 on 2/20/24.
//

import SwiftUI
import Combine
import AuthenticationServices
import MapKit

struct MainView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject private var container: DIContainer
    @StateObject private var viewModel: MainViewModel
    @State private var userTrackingMode: MapUserTrackingMode = .none
    @State private var shouldPresentHearList: Bool = false
    
    init(viewModel: MainViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        Map(
            mapRect: $viewModel.mapRect,
            interactionModes: [.pan, .zoom],
            showsUserLocation: true,
            userTrackingMode: $userTrackingMode,
            annotationItems: viewModel.hears
        ) { hear in
            MapAnnotation(coordinate: .init(geohash: hear.location.geohashExact)) {
                HearBalloon(viewModel: .init(hear: hear, container: container))
            }
        }
        .ignoresSafeArea()
        .tint(.hhSecondary)
        .overlay(alignment: .topTrailing) {
           UserTrackingButton($userTrackingMode)
        }
        .fullScreenCover(isPresented: $shouldPresentHearList) {
            HearListView(present: $shouldPresentHearList)
        }
        .overlay(alignment: .bottomLeading) {
            Button {
                shouldPresentHearList = true
            } label: {
                Image(systemName: "music.note.list")
                    .font(.system(size: 45))
            }
            .padding(.leading, 16)
            .padding(.bottom, 30)
            .tint(.hhAccent2)
        }
        .onAppear {
            authViewModel.send(action: .checkAnonymousUser)
        }   
    }
}

#Preview {
    let container = DIContainer(services: StubServices(), managers: StubManagers())
    return MainView(viewModel: .init(container: container))
        .environmentObject(
            AuthViewModel(container: container)
        )
        .environmentObject(container)
}
