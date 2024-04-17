//
//  Player.swift
//  Here-Hear
//
//  Created by 이원형 on 4/16/24.
//

import SwiftUI
import AVKit
import Foundation

struct Player: UIViewControllerRepresentable {
    
    var player: AVPlayer
    var loop: Bool
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let view = AVPlayerViewController()
        view.player = player
        view.showsPlaybackControls = false
        view.videoGravity = .resizeAspectFill
        player.play()
        
        if loop {
            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: player.currentItem,
                queue: .main) { _ in
                    self.player.seek(to: .zero)
                    self.player.play()
                }
        }
        return view
    }
    
    func updateUIViewController( _ uiViewController: AVPlayerViewController, context: Context) {
        
    }
    
    static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: ()) {
        // 필요한 경우 플레이어 정리 코드
        NotificationCenter.default.removeObserver(uiViewController,
                                                  name: .AVPlayerItemDidPlayToEndTime,
                                                  object: uiViewController.player?.currentItem)
        uiViewController.player?.pause()
        uiViewController.player = nil
    }
}
