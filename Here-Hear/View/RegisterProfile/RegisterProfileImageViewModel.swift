//
//  RegisterProfileImageViewModel.swift
//  Here-Hear
//
//  Created by Martin on 3/5/24.
//

import SwiftUI

final class RegisterProfileImageViewModel: ObservableObject {
    @Published var showProfileImagePicker: Bool = false
    @Published var image: UIImage?
    @Published var didSetProfile: Bool = false
    
    func upload() {
        
    }
}
