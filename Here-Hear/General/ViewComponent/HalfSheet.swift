//
//  HalfSheet.swift
//  Here-Hear
//
//  Created by Martin on 4/14/24.
//

import SwiftUI

struct HalfSheet<Content>: UIViewControllerRepresentable where Content : View {
    private let content: Content
    
    @inlinable init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    func makeUIViewController(context: Context) -> HalfSheetController<Content> {
        return HalfSheetController(rootView: content)
    }
    
    func updateUIViewController(_ uiViewController: HalfSheetController<Content>, context: Context) {
        
    }
    
    class HalfSheetController<InnerContent>: UIHostingController<InnerContent> where InnerContent: View {
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            if let presentation = sheetPresentationController {
                presentation.detents = [.medium()]
                presentation.prefersGrabberVisible = true
            }
        }
    }
}


