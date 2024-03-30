//
//  UserTrackingButton.swift
//  Here-Hear
//
//  Created by Martin on 3/21/24.
//

import SwiftUI
import MapKit

struct UserTrackingButton: View {
    @Binding var userTrackingMode: MapUserTrackingMode
    
    init(_ userTrackingMode: Binding<MapUserTrackingMode>) {
        self._userTrackingMode = userTrackingMode
    }
    var body: some View {
        Button {
            withAnimation(.easeIn) {
                userTrackingMode = .follow                
            }
        } label: {
            Image(systemName: "location.fill")
                .font(.system(size: 25))
                .foregroundStyle(userTrackingMode == .none ? .white : .hhAccent)
        }
        .frame(width: 40, height: 40)
        .background(
            userTrackingMode == .none ? .hhAccent : .white,
            in: .rect(cornerRadius: 10, style: .circular)
        )
        .overlay {
            if userTrackingMode != .none {
                RoundedRectangle(cornerRadius: 10, style: .circular)
                    .stroke(.hhAccent, lineWidth: 0.5)
            }
        }
        .padding(.trailing, 10)
        .padding(.top, 100)
    }
}

#Preview {
    UserTrackingButton(.constant(.none))
}
