//
//  HearListView.swift
//  Here-Hear
//
//  Created by Martin on 3/25/24.
//

import SwiftUI

struct HearListView: View {
    @StateObject private var viewModel: HearListViewModel
    @Binding private var shouldPresentHearList: Bool
    
    init(
        viewModel: HearListViewModel,
        present shouldPresentHearList: Binding<Bool>
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._shouldPresentHearList = shouldPresentHearList
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .trailing) {
               HearListSortingMenu(viewModel: viewModel)
                
                List {
                    
                    ForEach(viewModel.sortedHears, id: \.id) { hearListCell($0) }
                    progressView
                }
                .listStyle(.plain)
            }
            .navigationTitle(String(localized: "hearListView.title", defaultValue: "Hear List"))
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
    
    private func hearListCell(_ hear: HearModel) -> some View {
        HearListCell(
            hear: hear,
            distanceInMeter: viewModel.distanceOfHear(hear),
            userNickname: viewModel.userNicknames[hear.id],
            musics: viewModel.musicOfHear[hear.id]
        )
        .listRowInsets(
            .init(
                top: 0,
                leading: 21,
                bottom: 0,
                trailing: 7
            )
        )
        .listRowSeparator(.visible)
    }
    
    @MainActor
    @ViewBuilder
    private var progressView: some View {
        if viewModel.loadingState == .none {
            ProgressView()
                .id(UUID())
                .frame(maxWidth: .infinity)
                .task {
                    await viewModel.fetchHears()
                }
                .listRowSeparator(.hidden)
        }
    }
}

#Preview {
    let container = DIContainer(
        services: StubServices(),
        managers: StubManagers()
    )
    
    return HearListView(
        viewModel: .init(
            container: container,
            location: .seoulCityHall
        ),
        present: .constant(true)
    )
    .environmentObject(
        container
    )
}
