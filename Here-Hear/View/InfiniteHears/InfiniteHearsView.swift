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
    
    @State private var colors: [Color] = [
        .red, .blue, .green, .pink, .purple, .orange
    ]
    @State private var didAdd: Bool = false
    private let extraColors: [Color] = [
        .hhGray, .hhAccent, .hhAccent2, .hhTertiary, .hhSecondary
    ]
    
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
                                .onEnded { value in
                                    switch value.translation.height {
                                    case ...(-80):
                                        guard index < colors.count - 1 else { return }
                                        withAnimation(.easeInOut) {
                                            proxy.scrollTo(index + 1, anchor: .top)
                                        }
                                    case -80..<0:
                                        guard index < colors.count - 1 else { return }
                                        offset = -80
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            offset = .zero
                                        }
                                    case 0..<80:
                                        guard index > 0 else { return }
                                        offset = 80
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            offset = .zero
                                        }
                                    case 80...:
                                        guard index > 0 else { return }
                                        withAnimation(.easeInOut) {
                                            proxy.scrollTo(index - 1, anchor: .top)
                                        }
                                    default:
                                        return
                                    }
                                    
                                }
                            )
                            .onAppear {
                                fetchMoreHears(whenIndexIs: index, outOfTotalCount: viewModel.hears.count)
                            }
                    }
                }
                .animation(.spring, value: offset)
                .offset(y: offset)
            }
            .ignoresSafeArea(.all)
        }
    }
    
    private func fetchMoreHears(
        whenIndexIs index: Int,
        outOfTotalCount count: Int
    ) {
        guard index == Int(Double(count) * 0.8) else { return }
        guard !didAdd else { return }
        // TODO: viewModel 에서 추가로 hear를 불러오는 로직
        colors.append(contentsOf: extraColors)
        self.didAdd = true
        
    }
}

#Preview {
    InfiniteHearsView(viewModel: .init(container: .stub))
}
