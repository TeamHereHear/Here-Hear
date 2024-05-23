//
//  InfiniteHearsView.swift
//  Here-Hear
//
//  Created by Martin on 4/17/24.
//

import SwiftUI

struct InfiniteHearsView: View {
    @StateObject private var viewModel: InfiniteHearsViewModel
    
    init(viewModel: InfiniteHearsViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    @State private var offset: CGFloat = 0
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ForEach(0..<viewModel.hears.count, id: \.self) { index in
                        HearPlayView(hear: viewModel.hears[index])
                            .frame(height: UIScreen.main.bounds.height)
                            .ignoresSafeArea(.all)
                            .id(index)
                            .gesture(
                                DragGesture(
                                    minimumDistance: 0,
                                    coordinateSpace: .local
                                )
                                .onEnded { swipeTo($0, currentIndex: index, scrollProxy: proxy) }
                            )
                            .task {
                                await fetchMoreHears(whenIndexIs: index, outOfTotalCount: viewModel.hears.count)
                            }
                    }
                }
                .animation(.spring, value: offset)
                .offset(y: offset)
            }
            .ignoresSafeArea(.all)
        }
        .task {
            await viewModel.fetchHears()
        }
    }
    
    private func fetchMoreHears(
        whenIndexIs index: Int,
        outOfTotalCount count: Int
    ) async {
        guard index == Int(Double(count) * 0.8) else { return }
        
        await viewModel.fetchHears()
    }
    
    private let swipeThreshold: CGFloat = 80
    private func swipeTo(
        _ value: DragGesture.Value,
        currentIndex index: Int,
        scrollProxy proxy: ScrollViewProxy
    ) {
        let hearsCount = viewModel.hears.count
        
        switch value.translation.height {
        case ...(-swipeThreshold):
            guard index < hearsCount - 1 else { return }
            withAnimation(.easeInOut) {
                proxy.scrollTo(index + 1, anchor: .top)
            }
        case -swipeThreshold..<0:
            guard index < hearsCount - 1 else { return }
            offset = -swipeThreshold
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                offset = .zero
            }
        case 0..<swipeThreshold:
            guard index > 0 else { return }
            offset = swipeThreshold
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                offset = .zero
            }
        case swipeThreshold...:
            guard index > 0 else { return }
            withAnimation(.easeInOut) {
                proxy.scrollTo(index - 1, anchor: .top)
            }
        default:
            return
        }
    }
}

#Preview {
    InfiniteHearsView(viewModel: .init(container: .stub))
}
