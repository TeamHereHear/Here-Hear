//
//  MainView.swift
//  Here-Hear
//
//  Created by 이원형 on 2/20/24.
//

import SwiftUI
import AuthenticationServices
import MapKit

struct MainView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject private var container: DIContainer
    @StateObject private var viewModel: MainViewModel

    @State private var hears: [HearModel] = HearModel.mocks
    @State private var userTrackingMode: MapUserTrackingMode = .none
    
    init(viewModel: MainViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        Map(
            coordinateRegion: $viewModel.region,
            interactionModes: [.pan, .zoom],
            showsUserLocation: true,
            userTrackingMode: $userTrackingMode,
            annotationItems: hears
        ) { hear in
            MapAnnotation(coordinate: .init(geohash: hear.location.geohashExact)) {
                HearBalloon(viewModel: .init(hear: hear, container: container))
            }
        }
        .overlay(alignment: .topTrailing) {
            Button {
                userTrackingMode = .follow
            } label: {
                Image(systemName:"location.fill")
                    .font(.system(size: 25))
                    .foregroundStyle(userTrackingMode == .none ? .white : .hhAccent)
            }
            .frame(width: 40, height: 40)
            .background(
                userTrackingMode == .none ? .hhAccent : .white,
                in: .rect(cornerRadius: 10, style: .circular)
            )
            .overlay {
                if userTrackingMode != .none {
                    RoundedRectangle(cornerRadius: 10, style: .circular)
                        .stroke(.hhAccent, lineWidth: 0.5)
                }
            }
            .padding(.trailing, 10)
            .padding(.top, 100)
            
        }
        .onChange(of: viewModel.region.span.longitudeDelta, perform: { delta in
            print(delta)
        })
        .ignoresSafeArea()
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
