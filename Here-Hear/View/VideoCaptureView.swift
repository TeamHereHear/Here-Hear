import SwiftUI
import AVFoundation

// 커스텀 카메라 뷰를 구현하는 SwiftUI View
struct CustomCameraView: View {
    @Binding var isPresented: Bool
    @Binding var videoURL: URL?

    var body: some View {
        CustomCameraViewControllerRepresentable(isPresented: $isPresented, videoURL: $videoURL)
    }
}

// UIViewControllerRepresentable 프로토콜을 구현하여 UIKit 뷰 컨트롤러를 SwiftUI에서 사용 가능하게 함
struct CustomCameraViewControllerRepresentable: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var videoURL: URL?

    func makeUIViewController(context: Context) -> UIViewController {
        let cameraViewController = CustomCameraViewController()
        cameraViewController.delegate = context.coordinator
        return cameraViewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // Coordinator 클래스를 사용하여 UIKit과 SwiftUI 사이의 상호 작용을 관리
    class Coordinator: NSObject, CustomCameraViewControllerDelegate {
        var parent: CustomCameraViewControllerRepresentable

        init(_ parent: CustomCameraViewControllerRepresentable) {
            self.parent = parent
        }

        // 비디오 캡처가 완료되었을 때 호출될 메소드
        func videoCaptured(url: URL) {
            parent.videoURL = url
            parent.isPresented = false
        }
    }
}

// 실제 카메라 기능을 담당할 UIViewController 서브클래스
class CustomCameraViewController: UIViewController {
    var captureSession: AVCaptureSession?
    var videoOutput: AVCaptureMovieFileOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var delegate: CustomCameraViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
        setupUI()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }
    func setupUI() {
        let captureButton = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        captureButton.backgroundColor = UIColor(Color("HHAccent2"))
        captureButton.layer.cornerRadius = 35
        captureButton.center = CGPoint(x: view.bounds.midX, y: view.bounds.height - 100)
        captureButton.addTarget(self, action: #selector(captureButtonPressed), for: .touchUpInside)
        view.addSubview(captureButton)
        
        // 기타 UI요소 추가...
    }
    
    @objc func captureButtonPressed() {
        if videoOutput?.isRecording == true {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    func setupCaptureSession() {
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else { return }

        captureSession.beginConfiguration()

        // 비디오 입력 설정
        guard let videoDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
              captureSession.canAddInput(videoInput) else {
            print("비디오 입력을 추가할 수 없습니다.")
            return
        }
        captureSession.addInput(videoInput)

        // 비디오 출력 설정
        videoOutput = AVCaptureMovieFileOutput()
        guard let videoOutput = videoOutput, captureSession.canAddOutput(videoOutput) else {
            print("비디오 출력을 추가할 수 없습니다.")
            return
        }
        captureSession.addOutput(videoOutput)

        // 프리뷰 레이어 설정
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.frame = view.bounds
        previewLayer?.videoGravity = .resizeAspectFill
        if let previewLayer = previewLayer {
            view.layer.addSublayer(previewLayer)
        }

        captureSession.commitConfiguration()
        captureSession.startRunning()
    }

    // 비디오 캡처 시작
    func startRecording() {
        guard let videoOutput = videoOutput else { return }

        let outputPath = NSTemporaryDirectory() + "tempMovie.mov"
        let outputFileURL = URL(fileURLWithPath: outputPath)
        videoOutput.startRecording(to: outputFileURL, recordingDelegate: self)
    }

    // 비디오 캡처 중지
    func stopRecording() {
        videoOutput?.stopRecording()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.stopRunning()
            
            // 필요한 경우 UI 업데이트를 메인 스레드에서 호출
            DispatchQueue.main.async {
                // 캡쳐 완료 후 UI 업데이트
            }
        }
    }
}

// AVCaptureFileOutputRecordingDelegate 프로토콜 채택
extension CustomCameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("비디오 캡처 에러: \(error.localizedDescription)")
            return
        }
        
        // 비디오 캡처 완료 처리
        delegate?.videoCaptured(url: outputFileURL)
    }
}

// 비디오 캡처 완료 시 호출될 델리게이트 프로토콜
protocol CustomCameraViewControllerDelegate {
    func videoCaptured(url: URL)
}
