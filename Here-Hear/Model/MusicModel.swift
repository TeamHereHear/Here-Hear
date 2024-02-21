//
//  MusicModel.swift
//  Here-Hear
//
//  Created by 이원형 on 2/20/24.
//

import Foundation

struct MusicModel {
    var id: String
    var album: String
    var title: String
    var artist: String
    var artwork: URL?
}

extension MusicModel {
    func toEntity() -> MusicEntity {
        .init(
            id: id,
            album: album,
            title: title,
            artist: artist,
            artwork: artwork?.absoluteString
        )
    }
}
