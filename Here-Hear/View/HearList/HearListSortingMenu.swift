//
//  HearListSortingMenu.swift
//  Here-Hear
//
//  Created by Martin on 4/4/24.
//

import SwiftUI

struct HearListSortingMenu: View {
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
                    Text(sortingOrder.rawValue)
                }
            }
        } label: {
            Label {
                Text(viewModel.sortingOrder.localizedName)
            } icon: {
                Image(systemName: "arrow.up.arrow.down.circle.fill")
            }
        }
        .padding(.horizontal)
    }
}
