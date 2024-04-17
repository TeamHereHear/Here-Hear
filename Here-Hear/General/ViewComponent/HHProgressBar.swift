//
//  HHProgressBar.swift
//  Here-Hear
//
//  Created by Martin on 3/4/24.
//

import SwiftUI

struct HHProgressBar: View {
    private let value: CGFloat
    
    init(value: CGFloat) {
        self.value = value
    }
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width * value
            Capsule(style: .continuous)
                .foregroundStyle(.black)
            Capsule(style: .continuous)
                .frame(width: width)
                .foregroundStyle(.hhSecondary)
        }
        .frame(height: 5)
    }
}

#Preview {
    VStack {
        HHProgressBar(value: 0.3)
        Spacer()
    }
    .padding()
}
