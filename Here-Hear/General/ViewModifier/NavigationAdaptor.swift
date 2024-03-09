//
//  NavigationAdaptor.swift
//  Here-Hear
//
//  Created by Martin on 3/6/24.
//

import SwiftUI

struct NavigationAdaptor<Destination: View>: ViewModifier {
    @Binding private var isPresented: Bool
    private var destination: () -> Destination
    
    init(
        isPresented: Binding<Bool>,
        @ViewBuilder destination: @escaping () -> Destination
    ) {
        self._isPresented = isPresented
        self.destination = destination
    }
    
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .navigationDestination(isPresented: $isPresented, destination: destination)
        } else {
            content
                .overlay {
                    NavigationLink(
                        destination: destination(),
                        isActive: $isPresented,
                        label: {
                            EmptyView()
                        })
                }
        }
    }
}

extension View {
    func navigationAdaptor<Destination: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder destination: @escaping () -> Destination
    ) -> some View {
       modifier(NavigationAdaptor(isPresented: isPresented, destination: destination))
    }
}
