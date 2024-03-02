//
//  OnBoardRouterView.swift
//  Here-Hear
//
//  Created by Martin on 3/2/24.
//

import SwiftUI

struct OnBoardRouterView: View {
    @State private var onBoardRoute: OnBoardRoute = .existingUser
    
    enum OnBoardRoute: Int, Hashable {
        case existingUser = 1
        case signnedInNewUser
        case anonymousNewUser
    }
    
    var body: some View {
        NavigationView {
            switch onBoardRoute {
            case .existingUser:
                Text("Main")
            case .signnedInNewUser:
                Text("Signned")
            case .anonymousNewUser:
                Text("Anonymous")
            }
        }
    }
}

#Preview {
    OnBoardRouterView()
}
