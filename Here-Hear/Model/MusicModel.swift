//
//  MusicModel.swift
//  Here-Hear
//
//  Created by 이원형 on 2/20/24.
//

import Foundation

struct MusicModel: Codable, Hashable, Identifiable {
    var id: String
    var album: String?
    var title: String
    var artist: String
    var artwork: URL?
    var previewURL: URL?
}

extension MusicModel {
    func toEntity() -> MusicEntity {
        .init(
            id: id,
            album: album,
            title: title,
            artist: artist,
            artwork: artwork?.absoluteString,
            previewURL: previewURL?.absoluteString
        )
    }
}

// MARK: OnBoardingPage Stub
extension MusicModel {
    static let onBoardingPageStubOne: MusicModel = .init(
        id: "1611813405",
        album: "G - Stream 2 - Turn It Up - Single",
        title: "G - Wiggle",
        artist: "Gerald Albright",
        artwork: URL(
            string: "https://is1-ssl.mzstatic.com/image/thumb/Music126/v4/cb/e9/b4/cbe9b458-37aa-cb48-3d18-d8d44f31c798/658580401993.png/200x200bb.jpg"
        ),
        previewURL: URL(
            string: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview116/v4/00/4d/2c/004d2c57-941e-3563-22c0-6a1c87bb3f70/mzaf_4218236895290456377.plus.aac.p.m4a"
        )
    )
    
    static let onBoardingPageStubTwo: MusicModel = .init(
        id: "1623193283",
        album: "Twelve Carat Toothache",
        title: "I Like You (A Happier Song) [feat. Doja Cat]",
        artist: "Post Malone",
        artwork: URL(
            string: "https://is1-ssl.mzstatic.com/image/thumb/Music122/v4/0d/e8/8b/0de88b7c-bed9-be30-24e2-82d796e7bcf3/22UMGIM49145.rgb.jpg/200x200bb.jpg"
        ),
        previewURL: URL(
            string: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview112/v4/b3/2f/2a/b32f2a15-147f-d324-03d7-0a82a50f9267/mzaf_9573346997701482725.plus.aac.p.m4a"
        )
    )
    
    static let onBoardingPageStubThree: MusicModel = .init(
        id: "1656358106",
        album: "Look at Me !!!",
        title: "I adore you (feat. Crush)",
        artist: "Chan",
        artwork: URL(
            string:"https://is1-ssl.mzstatic.com/image/thumb/Music122/v4/f4/74/42/f47442fb-277a-72a0-1cb3-c54ce47949fb/Chan.jpg/200x200bb.jpg"
        ),
        previewURL: URL(
            string:"https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview122/v4/8f/fd/eb/8ffdeb60-8c36-0545-b714-15423922b2da/mzaf_12882138071536436042.plus.aac.p.m4a"
        )
    )
}
