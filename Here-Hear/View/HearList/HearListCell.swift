//
//  HearListCell.swift
//  Here-Hear
//
//  Created by Martin on 3/14/24.
//

import SwiftUI

struct HearListCell: View {
    private let hear: HearModel
    private let distanceInMeter: Double?
    private let userNickname: String?
    private let musics: [MusicModel]?
    
    @State private var openMusic: MusicModel?
    
    init(
        hear: HearModel,
        distanceInMeter: Double?,
        userNickname: String?,
        musics: [MusicModel]?
    ) {
        self.hear = hear
        self.distanceInMeter = distanceInMeter
        self.userNickname = userNickname
        self.musics = musics
    }
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            HStack {
                informations
                previewButton
            }
            HStack {
                Spacer()
                
            }
        }
        .frame(height: 130)
    }
    
    @ViewBuilder
    private var informations: some View {
        HStack(alignment: .bottom) {
            albumArt
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    songInformation
                        .redacted(reason: musics == nil ? .placeholder : [])
                    Spacer()
                    likeAndLinkButtons
                }
                detailedInformation
            }
        }
        
        Spacer()
    }
    
    private var albumArt: some View {
        RemoteImage(
            path: musics?.first?.artwork?.absoluteString,
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
    
    private var songInformation: some View {
        VStack(alignment: .leading) {
            Text(musics?.first?.title ?? "Music Title")
                .font(.system(size: 15, weight: .semibold))
            Text(musics?.first?.artist ?? "Music Artist")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
            Text(musics?.first?.album ?? "Music Album")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .padding(.bottom, 15)
        }
    }
    
    private var hearDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "YY.MM.dd"
        return formatter
    }
    private var detailedInformation: some View {
        HStack(spacing: 5) {
            RemoteImage(
                path: "\(StoragePath.UserInfo)/\(hear.userId)/profile.jpg",
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
                Text(userNickname ?? "userNickname")
                    .lineLimit(1)
                    .redacted(reason: userNickname == nil ? .placeholder : [])
                if let distanceInMeter {
                    Text(
                        Measurement(value: distanceInMeter, unit: UnitLength.meters),
                        format: .measurement(width: .abbreviated)
                    )
                    .foregroundStyle(.secondary)
                }
                Text(hear.createdAt, formatter: hearDateFormatter)
                    .foregroundStyle(.secondary)
            }
            .font(.system(size: 10))
        }
    }
    
    private var previewButton: some View {
        let buttonWidth: CGFloat = 56
        let buttonHeight: CGFloat = 88
        let cornerRadius: CGFloat = 11
        return Button {
            
        } label: {
            RoundedRectangle(cornerRadius: cornerRadius, style: .circular)
                .frame(width: buttonWidth, height: buttonHeight)
                .overlay {
                    Image(systemName: "play.fill")
                        .foregroundStyle(.white)
                }
        }
    }
    
    private var likeAndLinkButtons: some View {
        HStack(spacing: 16) {
            Button {
                if let music = musics?.first {
                    openMusic = music
                }
            } label: {
                Image(systemName: "music.note")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.hhSecondary)
            }
            .sheet(item: $openMusic) { music in
                OpenInAnotherMusicServiceView(music: music)
            }
            
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
        }
    }
    
}

#Preview {
    HearListCell(
        hear: HearModel.onBoardingPageOneStub,
        distanceInMeter: 1000000,
        userNickname: "Wonhyeong",
        musics: [MusicModel.onBoardingPageStubOne]
    )
    .environmentObject(
        DIContainer(
            services: StubServices(),
            managers: StubManagers()
        )
    )
    .padding(.horizontal, 9)
}
