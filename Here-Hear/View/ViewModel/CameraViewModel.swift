//
//  CameraViewModel.swift
//  ReelsCamera
//
//  Created by 이원형 on 3/7/24.
//

import SwiftUI
import AVFoundation

// MARK: Camera ViewModel
class CameraViewModel: NSObject, ObservableObject, AVCaptureFileOutputRecordingDelegate {
    @Published var session = AVCaptureSession()
    @Published var output = AVCaptureMovieFileOutput()
    @Published var preview: AVCaptureVideoPreviewLayer!
    @Published var alert = false
    // MARK: Video Recorder Properties
    @Published var isRecording: Bool = false
    @Published var recoredURLs: [URL] = []
    @Published var previewURL: URL?
    @Published var showPreview: Bool = false
    
    // MARK: Top Progress Bar
    @Published var recordedDuration: CGFloat = 0
    @Published var maxDuration: CGFloat = 20 // 최대 20초간 동영상 가능하게 하기!
    
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            
        case .authorized:
            // 백그라운드 스레드에서 setUp 호출
            DispatchQueue.global(qos: .userInitiated).async {
                self.setUp()
            }
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { (status) in
                if status {
                    // 백그라운드 스레드에서 setUp 호출
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.setUp()
                    }
                }
            }
            
        case .denied:
            self.alert.toggle()
            
        default:
            break
        }
    }

    func setUp() {
        self.session.beginConfiguration()
        
        if let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
            let audioDevice = AVCaptureDevice.default(for: .audio),
            let audioInput = try? AVCaptureDeviceInput(device: audioDevice) {
               
            // MARK: Audio Input
            if self.session.canAddInput(videoInput) && self.session.canAddInput(audioInput) {
                self.session.addInput(videoInput)
                self.session.addInput(audioInput)
            }
            
            // Same for Output
            if self.session.canAddOutput(self.output) {
                self.session.addOutput(self.output)
            }
        }
        
        self.session.commitConfiguration()
    }

    func startRecording() {
        // MARK: Temporary URL for recoring Video
        
        let tempURL = NSTemporaryDirectory() + "\(Date()).mov"
        if URL(string: tempURL) != nil {
            output.startRecording(to: URL(fileURLWithPath: tempURL), recordingDelegate: self)
            DispatchQueue.main.async {
                self.isRecording = true
            }
        }
    }
    
    func stopRecording() {
        output.stopRecording()
        DispatchQueue.main.async {
            self.isRecording = false
        }
    }

    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        // CREATED SUCCESSFULLY
        print(outputFileURL)
        // self.previewURL = outputFileURL
        self.recoredURLs.append(outputFileURL)
        if self.recoredURLs.count == 1 {
            self.previewURL = outputFileURL
            return
        }
        
        // CONVERTING URLs to ASSETS
        let assets = recoredURLs.compactMap { url -> AVURLAsset in
            return AVURLAsset(url: url)
        }
        self.previewURL = nil
        
        // MERGING VIDEOS
        mergeVideos(assets: assets) { exporter in
            exporter.exportAsynchronously {
                if exporter.status == .failed {
                    // HANDLE ERROR
                    print(exporter.error as Any)
                } else {
                    if let finalURL = exporter.outputURL {
                        print(finalURL)
                        DispatchQueue.main.async {
                            self.previewURL = finalURL
                        }
                    }
                }
                    
            }
                
        }
    }
    
    func mergeVideos(assets: [AVURLAsset], completion: @escaping (_ exporter: AVAssetExportSession) -> ()) {
        
        let composition = AVMutableComposition()
        var lastTime: CMTime = .zero
        
        guard let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        else {return}
        guard let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        else {return}
        
        for asset in assets {
            // Linking Audio and Video
            do {
                try videoTrack.insertTimeRange(CMTimeRange(start: .zero, duration: asset.duration), of: asset.tracks(withMediaType: .video)[0], at: lastTime)
                // Safe Check if Video has audio
                if !asset.tracks(withMediaType: .audio).isEmpty {
                    try audioTrack.insertTimeRange(CMTimeRange(start: .zero, duration: asset.duration), of: asset.tracks(withMediaType: .audio)[0], at: lastTime)
                }
            } catch {
                // HANDLE Error
                print(error.localizedDescription)
            }
            
            // Updatin Last time
            lastTime = CMTimeAdd(lastTime, asset.duration)
        }
        
        // MARK: Temp Output URL
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory() + "Reel-\(Date()).mp4")
        
        let layerInstructions = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        
        // MARK: Transform
        var transform = CGAffineTransform.identity
        transform = transform.rotated(by: 90 * (.pi / 180))
        transform = transform.translatedBy(x: 0, y: -videoTrack.naturalSize.height)
        layerInstructions.setTransform(transform, at: .zero)
        
        let instructions = AVMutableVideoCompositionInstruction()
        
        instructions.timeRange = CMTimeRange(start: .zero, duration: lastTime)
        instructions.layerInstructions = [layerInstructions]
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = CGSize(width: videoTrack.naturalSize.height, height: videoTrack.naturalSize.width)
        videoComposition.instructions = [instructions]
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        
        guard let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {return}
        exporter.outputFileType = .mp4
        exporter.outputURL = tempURL
        exporter.videoComposition = videoComposition
        completion(exporter)
    }
}
