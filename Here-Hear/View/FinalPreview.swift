//
//  FinalPreview.swift
//  Here-Hear
//
//  Created by 이원형 on 3/20/24.
//

import SwiftUI
import AVKit

struct FinalPreview: View {
    let url: URL
    @EnvironmentObject var cameraViewModel: CameraViewModel
    @Binding var showPreview: Bool

    private var player: AVPlayer {
        let player = AVPlayer(url: url)
        player.actionAtItemEnd = .none
        return player
    }

    var body: some View {
        

                    player.play()
                    NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
                        player.seek(to: CMTime.zero)
                        player.play()
                    }
                .onDisappear {
                    player.pause()
                    NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
                }
                .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
                .padding(.bottom, 70)
                .overlay(alignment: .topLeading) {
                    Button {
                        cameraViewModel.deleteAllRecordings()
                        showPreview.toggle()
                    } label: {
                        Image(systemName: "xmark.circle")
                            .font(.title)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .padding(.top, 30)
                }
        
    }
}

