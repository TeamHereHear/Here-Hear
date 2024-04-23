import SwiftUI
import AVKit

struct CameraHomeView: View {
    @StateObject var cameraViewModel = CameraViewModel()
    @State private var showAddFeelingTextView1: Bool = false
    @State private var showAddFeelingTextView2: Bool = false
    @Binding var selectedSong: MusicModel?
    @State private var optionalVideoURL: URL?

    @EnvironmentObject private var container: DIContainer

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                CameraView()
                    .environmentObject(cameraViewModel)
                    .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))

                recordButton

                if !cameraViewModel.isRecording {
                    Button {
                        self.selectedSong = nil
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .padding(.top, 10)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }

                VStack {
                    Text("음악에 어울리는\n동영상을 촬영해 볼까요?")
                        .font(.title)
                        .foregroundColor(.white)
                        .opacity(cameraViewModel.isRecording ? 0 : 1)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding()
                .padding(.top, 50)

                skipButton
            }
            .preferredColorScheme(.dark)
        }
    }

    private var recordButton: some View {
        ZStack {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.25)) {
                    if cameraViewModel.isRecording {
                        cameraViewModel.stopRecording()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            self.showAddFeelingTextView1 = true
                        }
                    } else {
                        cameraViewModel.startRecording()
                    }
                }
            }) {
                ZStack {
                    Circle()
                        .fill(cameraViewModel.isRecording ? Color.red : Color.white)
                        .frame(width: 70, height: 70)
                }
            }
            .padding(6)
            .background(
                Circle()
                    .strokeBorder(Color.gray, lineWidth: 4)
                    .background(Circle().fill(Color("HHSecondary")))
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 100)
            
            NavigationLink(destination: AddFeelingText(
                 videoURL: $cameraViewModel.previewURL,
                 selectedSong: $selectedSong
             )
                 .environmentObject(cameraViewModel), isActive: $showAddFeelingTextView1) {
                     EmptyView()
                 }
        }
    }

    private var skipButton: some View {
        HStack {
            Spacer()
            Button(action: {
                showAddFeelingTextView2 = true
            }) {
                Text("건너뛰기")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .shadow(radius: 10)
            }
            .padding([.bottom, .trailing], 15)
            .padding(.bottom, 5)

            NavigationLink(
                destination: AddFeelingText(
                    videoURL: $optionalVideoURL,
                    selectedSong: $selectedSong
                ),
                isActive: $showAddFeelingTextView2
            ) {
                EmptyView()
            }
        }
    }
}
