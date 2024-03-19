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

// MARK: OnBoardingPage Mock
extension MusicModel {
    
    static let onBoardingPageMockOne: MusicModel = .init(
        id: "10",
        album: "Windy Day",
        title: "Windy Day",
        artist: "Oh my girl",
        artwork: nil,
        previewURL: nil
    )
    
    static let onBoardingPageMockTwo: MusicModel = .init(
        id: "11",
        album: "",
        title: "",
        artist: "",
        artwork: nil,
        previewURL: nil
    )
    
    static let onBoardingPageMockThree: MusicModel = .init(
        id: "12",
        album: "",
        title: "",
        artist: "",
        artwork: nil,
        previewURL: nil
    )
}
