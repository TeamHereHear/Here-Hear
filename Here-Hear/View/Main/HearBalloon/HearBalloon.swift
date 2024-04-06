//
//  HearBalloon.swift
//  Here-Hear
//
//  Created by Martin on 3/12/24.
//

import SwiftUI

struct HearBalloon: View {
    @StateObject private var viewModel: HearBalloonViewModel
    
    private let width: CGFloat = 185
    private let height: CGFloat = 63
    private let cornerRadius: CGFloat = 10
    private let tipHeight: CGFloat = 20
    
    private let albumArtWidth: CGFloat = 63
    
    init(viewModel: HearBalloonViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            albumArt
                .padding(.trailing, 5)
            
            informations
            
            Spacer()
        }
        .frame(width: width, height: height)
        .clipShape(.rect(cornerRadius: cornerRadius, style: .continuous))
        .padding(.bottom, tipHeight)
        .background {
            HearBalloonBackground(
                width: width,
                height: height,
                cornerRadius: cornerRadius,
                tipHeight: tipHeight
            )
        }
        .onAppear {
            viewModel.fetch()
        }
    }
    
    private var albumArt: some View {
        RemoteImage(
            path: viewModel.music?.previewURL?.absoluteString,
            isStorageImage: false,
            transitionDuration: 1) { ProgressView() }
            .frame(
                width: albumArtWidth,
                height: albumArtWidth
            )
            .background(.hhGray)
    }
    
    private var informations: some View {
        VStack(alignment: .leading, spacing: 0) {
            musicInfo
            
            hearInfo
        }
        .frame(width: 110)
    }
    
    @ViewBuilder
    private var musicInfo: some View {
        Group {
            Text(viewModel.music?.title ?? "Music Title")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.black)
            
            Text(viewModel.music?.artist ?? "Artist")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(.white)
        }
        .redacted(reason: viewModel.music == nil ? .placeholder : [])
        
    }
    
    private var hearInfo: some View {
        HStack(spacing: 0) {
            Text(viewModel.userNickname ?? "Nickname")
                .foregroundStyle(.white)
                .redacted(reason: viewModel.userNickname == nil ? .placeholder : [])
            
            Spacer()
            
            Image(systemName: "heart.fill")
                .foregroundStyle(.hhAccent2)
                .padding(.trailing, 3)
            
            Text(viewModel.like, format: .number)
                .foregroundStyle(.white)
        }
        .font(.system(size: 11, weight: .regular))
    }
}
