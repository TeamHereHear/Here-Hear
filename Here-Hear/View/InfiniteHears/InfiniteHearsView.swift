//
//  InfiniteHearsView.swift
//  Here-Hear
//
//  Created by Martin on 4/17/24.
//

import SwiftUI

struct InfiniteHearsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: InfiniteHearsViewModel
    @EnvironmentObject private var container: DIContainer
    
    @State private var offset: CGFloat = 0
    @State private var currentWeather: Weather?
    @State private var currentIndex: Int = 0
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ForEach(0..<viewModel.hears.count, id: \.self) { index in
                        HearPlayView(
                            viewModel: .init(
                                container: container,
                                hear: viewModel.hears[index]
                            ),
                            currentIndex: $currentIndex,
                            index: index
                        )
                        .frame(width: UIScreen.current?.bounds.width)
                        .frame(height: UIScreen.current?.bounds.height)
                        .id(index)
                        .gesture(
                            DragGesture(
                                minimumDistance: 0,
                                coordinateSpace: .local
                            )
                            .onEnded { swipeTo($0, currentIndex: index, scrollProxy: proxy) }
                        )
                        .onAppear {
                            print("hearplayview of index \(index) is appeared")
                        }
                        .task {
                            currentWeather = viewModel.hears[index].weather
                        }
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
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 25))
                            .foregroundStyle(.white)
                    }
                    if let weather = currentWeather {
                        Image(systemName: weather.imageName)
                            .foregroundStyle(weather.color)
                            .font(.system(size: 35))
                    }
                }
            }
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
    
    @MainActor
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
            self.currentIndex = index + 1
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
            self.currentIndex = index - 1
        default:
            return
        }
    }
}

#Preview {
    InfiniteHearsView(
        viewModel: .init(
            container: .stub,
            location: .init(
                latitude: 10,
                longitude: 10,
                geohashExact: "aaaaaaµ"
            )
        )
    )
}
