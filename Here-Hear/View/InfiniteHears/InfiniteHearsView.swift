//
//  InfiniteHearsView.swift
//  Here-Hear
//
//  Created by Martin on 4/17/24.
//

import SwiftUI

struct InfiniteHearsView: View {
    @State private var offset: CGFloat = 0
    
    private var colors: [Color] = [
        .red, .blue, .green, .pink, .purple, .orange
    ]
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ForEach(0..<colors.count, id: \.self) { index in
                        colors[index]
                            .frame(height: UIScreen.main.bounds.height)
                            .ignoresSafeArea(.all)
                            .id(index)
                            .gesture(
                                DragGesture(
                                    minimumDistance: 0,
                                    coordinateSpace: .local
                                ).onEnded { value in
                                    switch value.translation.height {
                                    case ...(-80):
                                        guard index < colors.count - 1 else { return }
                                        withAnimation(.easeInOut) {
                                            proxy.scrollTo(index + 1, anchor: .top)
                                        }
                                    case -80..<0:
                                            offset = -80
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                offset = .zero
                                            }
                                    case 0..<80:
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
                        
                    }
                }
                .animation(.spring, value: offset)
                .offset(y:offset)
                
            }
            .ignoresSafeArea(.all)
        }
    }
}

#Preview {
    InfiniteHearsView()
}
