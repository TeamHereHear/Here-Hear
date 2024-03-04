//
//  MusicEntity.swift
//  Here-Hear
//
//  Created by 이원형 on 2/20/24.
//

import Foundation

struct MusicEntity: Codable, Hashable, Identifiable {
    var id: String
    var album: String?
    var title: String
    var artist: String
    var artwork: String?
    var previewURL: String?

}

extension MusicEntity {
    func toModel() -> MusicModel {
        .init(
            id: id,
            album: album,
            title: title,
            artist: artist,
            artwork: URL(string: artwork ?? ""),
            previewURL: URL(string: previewURL ?? "")
        )
    }
}
