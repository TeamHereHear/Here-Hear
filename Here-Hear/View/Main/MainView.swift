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
    @AppStorage(UserDefaultsKey.OnBoarding) var didAnonymousUserHasOnboarded: Bool = false

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
        .onAppear { didAnonymousUserHasOnboarded = true }
        .navigationBarBackButtonHidden()
        .overlay(alignment: .topTrailing) { UserTrackingButton($userTrackingMode) }
        .overlay(alignment: .bottom) { fetchAroundButton }
        .overlay(alignment: .bottomLeading) { presentHearListButton }
        .ignoresSafeArea()
        .tint(.hhSecondary)
    }
    
    private var fetchAroundButton: some View {
        let buttonHeight: CGFloat = 36
        let shadowRadius: CGFloat = 10
        let bottomPadding: CGFloat = 100
        
        return Button {
            viewModel.fetchAroundHears()
        } label: {
            Text("mainView.fetchAround.button.title")
                .font(.caption.bold())
                .foregroundStyle(.white)
        }
        .frame(maxHeight: buttonHeight)
        .padding(.horizontal)
        .background(.black, in: .capsule)
        .shadow(color: .hhSecondary, radius: shadowRadius)
        .padding(.bottom, bottomPadding)
        .opacity(viewModel.showFetchAroundHearButton ? 1 : 0)
        .animation(.easeInOut, value: viewModel.showFetchAroundHearButton)
    }
    
    @MainActor
    private var presentHearListButton: some View {
        let buttonSize: CGFloat = 45
        let leadingPadding: CGFloat = 16
        let bottomPadding: CGFloat = 30
        
        return Button {
            shouldPresentHearList = true
        } label: {
            Image(systemName: "music.note.list")
                .font(.system(size: buttonSize))
        }
        .padding(.leading, leadingPadding)
        .padding(.bottom, bottomPadding)
        .tint(.hhAccent2)
        .fullScreenCover(isPresented: $shouldPresentHearList) {
            HearListView(
                viewModel: .init(container: container, location: viewModel.mapRect.origin.coordinate),
                present: $shouldPresentHearList
            )
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
