//
//  Home.swift
//  ReelsCamera
//
//  Created by 이원형 on 3/6/24.
//

import SwiftUI
import AVKit
import PhotosUI

struct CameraHomeView: View {
    @StateObject var cameraViewModel = CameraViewModel()
    
    @State private var inputText: String = ""
    @State private var showWeatherChoice1: Bool = false
    @State private var showWeatherChoice2: Bool = false

    @Binding var selectedSong: MusicModel?
    @State private var optionalVideoURL: URL? // 건너뛰기 nil값
    @EnvironmentObject private var container: DIContainer

    //앨범 이미지 보여주는 변수들
    //@State private var isImagePickerPresented = false
    //@State private var latestImage: UIImage?
    // @State private var selectedImage: UIImage?
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                
                CameraView()
                    .environmentObject(cameraViewModel)
                    .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
                
                ZStack {
                    Button(action: {
                        if cameraViewModel.isRecording {
                            cameraViewModel.stopRecording()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.showWeatherChoice1 = true
                            }
                        } else {
                            cameraViewModel.startRecording()
                        }
                    }) { // 버튼 content
                        ZStack {
                            Circle()
                                .fill(cameraViewModel.isRecording ? Color.red : Color.white)
                                .frame(width: 70, height: 70)
                        }
                    }
                    .padding(6)
                    .background {
                        Circle()
                            .fill(cameraViewModel.isRecording ? Color.red : Color("HHSecondary"))
                    }
                    
                    NavigationLink(destination: WeatherChoiceView(
                        videoURL: $cameraViewModel.previewURL,
                        selectedSong: $selectedSong
                    )
                        .environmentObject(cameraViewModel), isActive: $showWeatherChoice1) {
                            EmptyView()
                        }
                    // 프리뷰 버튼
                    //                Button {
                    //                    // cameraModel.showPreview.toggle()
                    //                    if cameraViewModel.previewURL != nil {
                    //                        cameraViewModel.showPreview.toggle()
                    //                    }
                    //                } label: {
                    //                    Group {
                    //                        if cameraViewModel.previewURL == nil && !cameraViewModel.recoredURLs.isEmpty {
                    //                            // Merging Videos
                    //                            ProgressView()
                    //                                .tint(.blue)
                    //                        } else {
                    //                            Label {
                    //                                Image(systemName: "chevron.right")
                    //                                    .font(.callout)
                    //                            } icon: {
                    //                                Text("Preview")
                    //                            }
                    //                            .foregroundColor(.black)
                    //
                    //                        }
                    //                    }
                    //                } // label
                    //                .padding(.horizontal, 20)
                    //                .padding(.vertical, 8)
                    //                .background {
                    //                    Capsule()
                    //                        .fill(.white)
                    //                }
                    //                .frame(maxWidth: .infinity, alignment: .trailing)
                    //                .padding(.trailing)
                    //                .opacity((cameraViewModel.previewURL == nil && cameraViewModel.recoredURLs.isEmpty) || cameraViewModel.isRecording ? 0 : 1)
                }
                .animation(.easeInOut(duration: 2.0), value: showWeatherChoice1)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, 100)// 촬영버튼 패딩
                
                // 동영상 촬영본 모두 삭제하기
                //            if cameraViewModel.previewURL != nil && !cameraViewModel.isRecording {
                //                Button {
                //                    cameraViewModel.recordedDuration = 0
                //                    cameraViewModel.previewURL = nil
                //                    cameraViewModel.recoredURLs.removeAll()
                //
                //                } label: {
                //                    // Image(systemName: "xmark")
                //                    Text("다시 찍기")
                //                        .font(.title2)
                //                        .foregroundColor(.white)
                //                        .padding()
                //                        .padding(.top, 10)
                //                }
                //                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                //            }
                
                if !cameraViewModel.isRecording {
                    Button {
                        // 'selectedSong'을 'nil'로 설정하여 fullscreenCover를 닫습니다.
                        self.selectedSong = nil
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .padding(.top, 10)
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading) // 버튼을 오른쪽 상단에 위치시킵니다.
                }
                
                VStack {
                    Text("음악에 어울리는\n동영상을 촬영해 볼까요?")
                        .font(.title)
                        .foregroundColor(.black)
                        .opacity(cameraViewModel.isRecording ? 0 : 1)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding()
                .padding(.top, 50)
                
                //                if !cameraViewModel.isRecording {
                //                    HStack {
                //                        Button(action: {
                //                            isImagePickerPresented = true
                //                        }) {
                //
                //                            ZStack {
                //                                if selectedVideoURL == nil && selectedImage == nil {
                //                                    if let latestImage = latestImage {
                //                                        Image(uiImage: latestImage)
                //                                            .resizable()
                //                                            .frame(width: 35, height: 35)
                //                                            .cornerRadius(10)
                //                                    } else {
                //                                        // 최근 이미지가 없는 경우 기본 텍스트나 이미지 사용
                //                                        Text("앨범에서 사진, 동영상 선택")
                //                                            .foregroundColor(.white)
                //                                            .padding()
                //                                            .background(Color.blue)
                //                                            .clipShape(Capsule())
                //                                    }
                //                                } else {
                //                                    // 선택된 비디오나 이미지 표시
                //                                    if let selectedVideoURL = selectedVideoURL {
                //                                        VideoPlayer(player: AVPlayer(url: selectedVideoURL))
                //                                            .frame(width: 35, height: 35)
                //                                            .cornerRadius(10)
                //                                    } else if let selectedImage = selectedImage {
                //                                        Image(uiImage: selectedImage)
                //                                            .resizable()
                //                                            .frame(width: 35, height: 35)
                //                                            .cornerRadius(10)
                //                                    }
                //                                }
                //                            }// ZStack
                //                            .frame(width: 35, height: 35)
                //                            .cornerRadius(10)
                //                            .overlay(
                //                                RoundedRectangle(cornerRadius: 10)
                //                                    .stroke(Color.white, lineWidth: 2)
                //                                )
                //                    }
                //                        .padding([.bottom, .leading], 15)
                //                        Spacer()
                //
                //                    }// HStack
                //
                //                }
                
                // 건너뛰기
                if !cameraViewModel.isRecording {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            showWeatherChoice2 = true
                            print("건너뛰기 눌림")
                        }) {
                            Text("건너뛰기")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .shadow(radius: 10)
                            
                            NavigationLink(destination: WeatherChoiceView(
                                videoURL: $optionalVideoURL,
                                selectedSong: $selectedSong
                            ), isActive: $showWeatherChoice2) {
                                EmptyView()
                            }
                        }
                        .padding([.bottom, .trailing], 15)
                        .padding(.bottom, 5)
                    }
                }
                
            } // ZStack
            //            .onAppear {
            //                fetchLatestImage()
            //            }
            //            .sheet(isPresented: $isImagePickerPresented) {
            //                ImagePicker(selectedVideoURL: $selectedVideoURL, selectedImage: $selectedImage)
            //            }
            
            //            .overlay(content: {
            //                if let url = cameraViewModel.previewURL, cameraViewModel.showPreview {
            //                    CameraPreviewView(url: url, showPreview: $cameraViewModel.showPreview)
            //                        .environmentObject(cameraViewModel)
            //                        .transition(.opacity)
            //                        .animation(.easeInOut(duration: 5.0), value: cameraViewModel.showPreview)
            //                }
            //            })
            .preferredColorScheme(.dark)
        }
        
    }
    
    // 앨범에서 제일 최근 이미지 불러와서 대표 이미지로 만들기
    //    func fetchLatestImage() {
    //        let fetchOptions = PHFetchOptions()
    //        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
    //        fetchOptions.fetchLimit = 1
    //        let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
    //
    //        if let lastAsset = fetchResult.firstObject {
    //            let manager = PHImageManager.default()
    //            let options = PHImageRequestOptions()
    //            options.version = .current
    //            options.isSynchronous = true
    //            manager.requestImage(for: lastAsset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: options) { image, _ in
    //                self.latestImage = image
    //            }
    //        }
    //
    //    }
    //
    //    struct ImagePicker: UIViewControllerRepresentable {
    //        @Environment(\.presentationMode) var presentationMode
    //        @Binding var selectedVideoURL: URL?
    //        @Binding var selectedImage: UIImage?
    //
    //        func makeUIViewController(context: Context) -> UIImagePickerController {
    //            let picker = UIImagePickerController()
    //            picker.delegate = context.coordinator
    //            picker.sourceType = .photoLibrary
    //            picker.mediaTypes = ["public.movie", "public.image"] // 비디오 선택을 위해 mediaTypes 설정
    //            return picker
    //        }
    //
    //        func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    //
    //        func makeCoordinator() -> Coordinator {
    //            Coordinator(self)
    //        }
    //
    //        class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //            var parent: ImagePicker
    //
    //            init(_ parent: ImagePicker) {
    //                self.parent = parent
    //            }
    //
    //            func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
    //                if let videoURL = info[.mediaURL] as? URL {
    //                    parent.selectedVideoURL = videoURL
    //                } else if let image = info[.originalImage] as? UIImage {
    //                    parent.selectedImage = image
    //                }
    //                parent.presentationMode.wrappedValue.dismiss()
    //            }
    //
    //            func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    //                parent.presentationMode.wrappedValue.dismiss()
    //            }
    //        }
    //    }
    //
    
}
