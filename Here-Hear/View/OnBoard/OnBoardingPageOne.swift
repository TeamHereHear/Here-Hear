//
//  OnBoardingPageOne.swift
//  Here-Hear
//
//  Created by Martin on 3/13/24.
//

import SwiftUI
import MapKit

struct OnBoardingPageOne: View {
    @Binding private var tabSelection: Int
    @State private var region: MKCoordinateRegion = .init(
        center: .init(latitude: 37.773619, longitude: -122.418793),
        span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    init(_ tabSelection: Binding<Int>) {
        self._tabSelection = tabSelection
    }
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 85)
            Map(coordinateRegion: $region, interactionModes: [])
            .frame(width: 352, height: 352)
            .clipShape(.rect(cornerRadius: 30, style: .continuous))
            .overlay {
                HearBalloon(
                    viewModel: .init(
                        hear: HearModel.onBoardingPageOneStub,
                        container: .init(services: StubServices())
                    )
                )
                .scaleEffect(CGSize(width: 1.2, height: 1.2))
            }
            
            Spacer()
                .frame(height: 37)
            
//            Text("주변에서\n무슨 음악을 듣는지\n찾아보세요")
            Text("onBoardingPageOne.title")
                .onBoadingTitleStyle()
                
            Spacer()
            
            HStack {
                Spacer()
                Button {
                    withAnimation(.linear) {
                        tabSelection += 1
                    }
                } label: {
                    Text("onBoadingPageOne.Next")
                        .font(.system(size: 19, weight: .semibold))
                }
            }
            .padding(.horizontal, 21)
            
        }
    }
}

#Preview {
    OnBoardingPageOne(.constant(0))
}
