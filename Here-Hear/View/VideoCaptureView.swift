import SwiftUI
import AVFoundation
import UIKit

// MARK: - Custom Camera Interface
struct CustomCameraView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var videoURL: URL?
    
    func makeUIViewController(context: Context) -> UIViewController {
        let cameraViewController = CustomCameraViewController()
        cameraViewController.delegate = context.coordinator
        return cameraViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, CustomCameraViewControllerDelegate {
        var parent: CustomCameraView
        
        init(_ parent: CustomCameraView) {
            self.parent = parent
        }
        
        func didCaptureVideo(_ url: URL) {
            parent.videoURL = url
            parent.isPresented = false
        }
        
        func didCancelCapture() {
            parent.isPresented = false
        }
    }
}

// MARK: - Custom Camera View Controller
class CustomCameraViewController: UIViewController {
    var captureSession = AVCaptureSession()
    var videoOutput = AVCaptureMovieFileOutput()
    var previewLayer: AVCaptureVideoPreviewLayer?
    weak var delegate: CustomCameraViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
    }
    
    func setupCaptureSession() {
        captureSession.beginConfiguration()
        
        // Setup video input
        if let videoDevice = AVCaptureDevice.default(for: .video),
           let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
           captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        
        // Setup video output
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        captureSession.commitConfiguration()

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
            
            DispatchQueue.main.async { [weak self] in
                self?.setupPreviewLayer()
            }
        }
    }
    func setupPreviewLayer() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = view.layer.bounds
        if let previewLayer = previewLayer {
            view.layer.addSublayer(previewLayer)
        }
    }
    
    // MARK: - Actions
    func startRecording() {
        let outputPath = NSTemporaryDirectory() + "output.mov"
        let outputFileURL = URL(fileURLWithPath: outputPath)
        videoOutput.startRecording(to: outputFileURL, recordingDelegate: self)
    }
    
    func stopRecording() {
        if videoOutput.isRecording {
            videoOutput.stopRecording()
        }
    }
    
}

extension CustomCameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Video recording error: \(error.localizedDescription)")
        } else {
            delegate?.didCaptureVideo(outputFileURL)
        }
    }
}

protocol CustomCameraViewControllerDelegate: AnyObject {
    func didCaptureVideo(_ url: URL)
    func didCancelCapture()
}
