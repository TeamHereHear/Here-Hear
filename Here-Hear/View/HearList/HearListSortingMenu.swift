//
//  HearListSortingMenu.swift
//  Here-Hear
//
//  Created by Martin on 4/4/24.
//

import SwiftUI

struct HearListSortingMenu: View {
    @Environment(\.colorScheme) var scheme
    @ObservedObject private var viewModel: HearListViewModel
    
    init(viewModel: HearListViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        Menu {
            ForEach(HearListViewModel.SortingOrder.allCases, id: \.hashValue) { sortingOrder in
                Button {
                    viewModel.sortingOrder = sortingOrder
                } label: {
                    Text(sortingOrder.localizedName)
                }
            }
        } label: {
            Label {
                Text(viewModel.sortingOrder.localizedName)
                    .font(.system(size: 14))
                    .foregroundStyle(scheme == .light ? .black : .white)
            } icon: {
                Image(systemName: "arrow.up.arrow.down.circle.fill")
            }
        }
        .padding(.horizontal)
    }
}
