//
//  CameraView.swift
//  ReelsCamera
//
//  Created by 이원형 on 3/6/24.
//

import SwiftUI
import AVFoundation

// Adding Camera And Microphone Permission

struct CameraView: View {
    @EnvironmentObject var cameraModel: CameraViewModel
    
    var body: some View {
        
        GeometryReader { proxy in
            let size = proxy.size
            
            CameraPreview(size: size)
                .environmentObject(cameraModel)
            
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(.black.opacity(0.25))
                
                Rectangle()
                    .fill(Color.pink)
                    .frame(width: size.width * (cameraModel.recordedDuration / cameraModel.maxDuration))
            }
            .frame(height: 10)
            .frame(maxHeight: .infinity, alignment: .top)
        }
            .onAppear(perform: cameraModel.checkPermission)
            .alert(isPresented: $cameraModel.alert) {
                Alert(title: Text("Please Enable cameraModel Access Or Microphone Acess !!!"))
            }
            .onReceive(Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()) { _ in
                if cameraModel.recordedDuration <= cameraModel.maxDuration && cameraModel.isRecording {
                    cameraModel.recordedDuration += 0.01
                }
                
                if cameraModel.recordedDuration >= cameraModel.maxDuration && cameraModel.isRecording {
                    // Stopping the Recording
                    cameraModel.stopRecording()
                    cameraModel.isRecording = false
                }
                    
            }
    }
}
// setting view for preview

struct CameraPreview: UIViewRepresentable {
    @EnvironmentObject var cameraModel: CameraViewModel
    var size: CGSize
    
    func makeUIView(context: Context) -> some UIView {
        
        let view = UIView()
        
        cameraModel.preview = AVCaptureVideoPreviewLayer(session: cameraModel.session)
        cameraModel.preview.frame.size = size
        
        cameraModel.preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(cameraModel.preview)
        
        // AVCaptureSession의 startRunning이 메인스레드에서 호출말고 UI응답성 유지하기 위해서 백그라운드 스레드에서 실행하기
        DispatchQueue.global(qos: .userInitiated).async {
           cameraModel.session.startRunning()
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
    
}
