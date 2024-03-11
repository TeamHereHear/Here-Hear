//
//  RemoteImage.swift
//  Here-Hear
//
//  Created by Martin on 3/11/24.
//

import SwiftUI

struct RemoteImage<Placeholder: View>: View {
    @EnvironmentObject private var container: DIContainer
    
    private let path: String?
    private let isStorageImage: Bool
    private let transitionDuration: TimeInterval
    private let placeholder: () -> Placeholder
    
    init(
        path: String?,
        isStorageImage: Bool,
        transitionDuration: TimeInterval,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.path = path
        self.isStorageImage = isStorageImage
        self.transitionDuration = transitionDuration
        self.placeholder = placeholder
    }
    
    var body: some View {
        if let path {
            RemoteImageInnerView(
                viewModel: .init(
                    container: container,
                    path: path,
                    isStorageImage: isStorageImage
                ),
                placeholder: placeholder
            )
            .id(path)
        } else {
            placeholder()
        }
    }
}

private struct RemoteImageInnerView<Placeholder: View>: View {
    @StateObject private var viewModel: RemoteImageViewModel
    
    private let placeholder: () -> Placeholder
    private let transitionDuration: TimeInterval
    
    init(
        viewModel: RemoteImageViewModel,
        transitionDuration: TimeInterval = 1.0,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.transitionDuration = transitionDuration
        self.placeholder = placeholder
    }
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
            } else {
                placeholder()
            }
        }
        .transition(.opacity)
        .animation(
            .easeIn(duration: transitionDuration),
            value: viewModel.image
        )
        .task {
            guard viewModel.imageLoadingState == .none else {
                return
            }
            
            if viewModel.isStorageImage {
                await viewModel.fetchFromStoragePath()
            } else {
                await viewModel.fetch()
            }
        }
    }
}
