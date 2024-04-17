//
//  OpenInOtherMusicServiceView.swift
//  Here-Hear
//
//  Created by martin on 4/11/24.
//

import SwiftUI

struct OpenInOtherMusicServiceView: View {
    @Environment(\.locale) var locale: Locale
    private let music: MusicModel
    private var countryCode: String? {
        locale.identifier.split(separator: "_").last?.lowercased()
    }
    
    init(music: MusicModel) {
        self.music = music
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                RemoteImage(
                    path: music.artwork?.absoluteString,
                    isStorageImage: false,
                    transitionDuration: 0.5
                ) {
                    Rectangle()
                        .foregroundStyle(.hhGray)
                }
                .aspectRatio(1, contentMode: .fit)
                .frame(width: 64, height: 64)
                .background(.hhGray)
                .clipShape(.rect(cornerRadius: 11, style: .continuous))
                VStack(alignment: .leading) {
                    Text(music.title)
                        .font(.system(size: 15, weight: .semibold))
                    Text(music.artist)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(
                Material.ultraThin,
                in: .rect(cornerRadius: 10, style: .continuous)
            )
            
            Text("이 음악 다른 앱에서 듣기")
                .font(.headline)
            
            ScrollView(.horizontal) {
                HStack {
                    openInAppleMusicButton
                    openInSpotifyButton
                    openInYTMusicButton
                }
                .padding(4)
            }
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
        .background(.hhSecondary)
        .background(ignoresSafeAreaEdges: .all)
    }
    
    @MainActor
    @ViewBuilder
    private var openInAppleMusicButton: some View {
        if let countryCode,
           let appleMusicIconImage = UIImage(named: "AppleMusicIcon"),
           let appleMusicDeeplinkUrl = music.appleMusicDeeplinkURL(ofCountryCode: countryCode) {
            Button {
                Task {
                    await UIApplication.shared.open(appleMusicDeeplinkUrl)
                }
            } label: {
                VStack {
                    Image(uiImage: appleMusicIconImage)
                        .otherMusicServiceIconModifier(
                            canOpenURL(appleMusicDeeplinkUrl)
                        )
                    Text("Apple Music")
                        .font(.caption)
                        .foregroundStyle(.black)
                        .opacity(canOpenURL(appleMusicDeeplinkUrl) ? 1.0 : 0.4)
                }
            }
            .disabled(!canOpenURL(appleMusicDeeplinkUrl))
        }
    }
    
    @MainActor
    @ViewBuilder
    private var openInSpotifyButton: some View {
        if let spotifyDeeplinkUrl = music.spotifyDeeplinkURL() {
            Button {
                Task {
                    await UIApplication.shared.open(spotifyDeeplinkUrl)
                }
            } label: {
                VStack {
                    Image("SpotifyIcon")
                        .otherMusicServiceIconModifier(
                            canOpenURL(spotifyDeeplinkUrl)
                        )
                    Text("Spotify")
                        .font(.caption)
                        .foregroundStyle(.black)
                        .opacity(canOpenURL(spotifyDeeplinkUrl) ? 1.0 : 0.4)
                }
            }
            .disabled(!canOpenURL(spotifyDeeplinkUrl))
        }
    }
    
    @MainActor
    @ViewBuilder
    private var openInYTMusicButton: some View {
        if let youtubeMusicDeeplinkURL = music.youtubeMusicDeeplinkURL() {
            Button {
                Task {
                    await UIApplication.shared.open(youtubeMusicDeeplinkURL)
                }
            } label: {
                VStack {
                    Image("YoutubeMusicIcon")
                        .otherMusicServiceIconModifier(
                            canOpenURL(youtubeMusicDeeplinkURL)
                        )
                    Text("Youtube Music")
                        .font(.caption)
                        .foregroundStyle(.black)
                        .opacity(canOpenURL(youtubeMusicDeeplinkURL) ? 1.0 : 0.5)
                }
            }
            .disabled(!canOpenURL(youtubeMusicDeeplinkURL))
        }
    }
    
    private func canOpenURL(_ url: URL) -> Bool {
        UIApplication.shared.canOpenURL(url)
    }
}

extension Image {
    func otherMusicServiceIconModifier(_ canOpen: Bool = true) -> some View {
        self
            .resizable()
            .aspectRatio(1, contentMode: .fit)
            .frame(width: 45)
            .frame(width: 75, height: 75)
            .background {
                Circle()
                    .foregroundStyle(.white)
                    .overlay {
                        Circle()
                            .stroke(lineWidth: 3)
                            .foregroundStyle(canOpen ? .hhAccent : .hhGray)
                    }
            }
            
    }
}

#Preview {
    Text("")
        .sheet(isPresented: .constant(true)) {
            HalfSheet {
                OpenInOtherMusicServiceView(music: .onBoardingPageStubOne)
                    .environmentObject(
                        DIContainer(
                            services: StubServices(),
                            managers: StubManagers()
                        )
                    )
            }.ignoresSafeArea()
        }
}
