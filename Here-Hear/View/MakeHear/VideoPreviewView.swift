import SwiftUI
import AVKit

struct VideoPreviewView: View {
    var url: URL
    @EnvironmentObject var cameraViewModel: CameraViewModel
    @Binding var showPreview: Bool
    
    private var player: AVPlayer {
        let player = AVPlayer(url: url)
        player.actionAtItemEnd = .none
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
            player.seek(to: .zero)
            player.play()
        }
        return player
    }
    
    var body: some View {
        VideoPlayer(player: player)
            .onAppear {
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
                        .foregroundColor(.white)
                        .padding()
                        .padding(.top, 30)
                }
            }
    }
}
