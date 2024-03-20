//
//  HearListCell.swift
//  Here-Hear
//
//  Created by Martin on 3/14/24.
//

import SwiftUI

struct HearListCell: View {
    private let hear: HearModel
    private let userNickname: String
    private let music: MusicModel
    
    init(
        hear: HearModel,
        userNickname: String,
        music: MusicModel
    ) {
        self.hear = hear
        self.userNickname = userNickname
        self.music = music
    }
    
    var body: some View {
        HStack {
           informations
            buttons
        }
        .frame(height: 109)
    }
    
    @ViewBuilder
    private var informations: some View {
        HStack(alignment: .bottom) {
            albumArt
            
            VStack(alignment: .leading, spacing: 0) {
                songInfo
                publishInfo
            }
        }
        
        Spacer()
    }
    
    private var albumArt: some View {
        RemoteImage(
            path: music.artwork?.absoluteString,
            isStorageImage: false,
            transitionDuration: 0.5
        ) {
            Rectangle()
                .foregroundStyle(.hhGray)
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(width: 88, height: 88)
        .background(.hhGray)
        .clipShape(.rect(cornerRadius: 11, style: .continuous))
    }
    
    @ViewBuilder
    private var songInfo: some View {
        Text(music.title)
            .font(.system(size: 15, weight: .semibold))
        Text(music.artist)
            .font(.system(size: 12))
            .foregroundStyle(.secondary)
        Text(music.album ?? "")
            .font(.system(size: 12))
            .foregroundStyle(.secondary)
            .padding(.bottom, 15)
    }
    
    private var hearDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "YY.MM.dd"
        return formatter
    }
    private var publishInfo: some View {
        HStack(spacing: 5) {
            #warning("TODO: Storage 이미지 경로 Constant로 구성")
            RemoteImage(
                path: "UserInfo/\(hear.userId)/profile.jpg",
                isStorageImage: true,
                transitionDuration: 0.5
            ) {
                Circle()
                    .foregroundStyle(.hhGray)
            }
            .frame(width: 16, height: 16)
            .background(.hhGray)
            .clipShape(.circle)
            
            Group {
                Text(userNickname)
                Text(
                    Measurement(value: 5, unit: UnitLength.meters),
                    format: .measurement(width: .abbreviated)
                )
                .foregroundStyle(.secondary)
                Text(hear.createdAt, formatter: hearDateFormatter)
                    .foregroundStyle(.secondary)
            }
            .font(.system(size: 10))
        }
    }
    
    private var buttons: some View {
        HStack {
            Button {
                
            } label: {
                Image(systemName: "heart.fill")
                    .font(.system(size: 20))
                    .padding(.vertical, 12)
                    .overlay(alignment: .bottom) {
                        Text(hear.like, format: .number)
                            .font(.system(size: 10))
                            .foregroundStyle(Color(.label))
                    }
            }
            
            Button {
                
            } label: {
                Image(systemName: "music.note")
                    .font(.system(size: 20))
                    .foregroundStyle(.hhSecondary)
            }
            
            //TODO: 동영상 프리뷰를 어떻게 나타낼 것인가?
            Button {
                
            } label: {
                RoundedRectangle(cornerRadius: 11, style: .circular)
                    .frame(width: 56, height: 88)
                    .overlay {
                        Image(systemName: "play.fill")
                            .foregroundStyle(.white)
                    }
            }
        }
    }
}

#Preview {
    HearListCell(
        hear: .onBoardingPageOneStub,
        userNickname: "Wonhyeong",
        music: MusicEntity.mock.toModel()
    )
    .environmentObject(
        DIContainer(
            services: StubServices(),
            managers: StubManagers()
        )
    )
    .padding(.horizontal, 9)
}
