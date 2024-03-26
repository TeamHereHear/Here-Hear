//
//  HearListViewModel.swift
//  Here-Hear
//
//  Created by Martin on 3/25/24.
//

import Foundation
import Combine

final class HearListViewModel: ObservableObject {
    @Published var hears: [HearModel] = []
    @Published var musicOfHear: [String : MusicModel] = [:]
    
    private let container: DIContainer
    private var cancellables = Set<AnyCancellable>()
    private var lastDocumentID: String?
    
    init(
        container: DIContainer,
        hears: [HearModel],
        musicOfHear: [String : MusicModel]
    ) {
        self.container = container
        self.hears = hears
        self.musicOfHear = musicOfHear
    }

}
