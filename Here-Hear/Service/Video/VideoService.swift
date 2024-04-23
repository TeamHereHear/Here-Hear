import Foundation
import FirebaseStorage
import Combine
import AVKit

enum VideoServiceError: Error {
    case custom(String)
    case defaultError

    var localizedDescription: String {
        switch self {
        case .custom(let message):
            return message
        case .defaultError:
            return "예상하지 못한 에러 발생"
        }
    }
}

protocol VideoServiceProtocol {
    func uploadVideoAndThumbnail(url: URL, hearId: String) -> AnyPublisher<(videoURL: URL?, thumbnailURL: URL?), VideoServiceError>
}

class VideoService: VideoServiceProtocol {
    private let storageReference = Storage.storage().reference()

    func uploadVideoAndThumbnail(url: URL, hearId: String) -> AnyPublisher<(videoURL: URL?, thumbnailURL: URL?), VideoServiceError> {
        let videoRef = storageReference.child("Video/\(hearId).mov")
        let thumbnailRef = storageReference.child("Thumbnail/\(hearId).jpg")
        
        return createThumbnail(for: url)
            .flatMap { thumbnail -> AnyPublisher<(videoURL: URL?, thumbnailURL: URL?), VideoServiceError> in
                let uploadVideo = self.uploadVideo(url: url, to: videoRef)
                let uploadThumbnail = thumbnail.map {
                    self.uploadImage($0, to: thumbnailRef)
                } ?? Fail(error: VideoServiceError.custom("썸네일 이미지 생성 실패")).eraseToAnyPublisher()
                
                return Publishers.Zip(uploadVideo, uploadThumbnail)
                    .map { (videoURL, thumbnailURL) in (videoURL, thumbnailURL) }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private func uploadVideo(url: URL, to reference: StorageReference) -> AnyPublisher<URL?, VideoServiceError> {
        Future<URL?, VideoServiceError> { promise in
            reference.putFile(from: url, metadata: nil) { _, error in
                if let error = error {
                    promise(.failure(.custom(error.localizedDescription)))
                    return
                }
                reference.downloadURL { url, error in
                    if let url = url {
                        promise(.success(url))
                    } else if let error = error {
                        promise(.failure(.custom(error.localizedDescription)))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    private func uploadImage(_ image: UIImage, to reference: StorageReference) -> AnyPublisher<URL?, VideoServiceError> {
        Future<URL?, VideoServiceError> { promise in
            guard let imageData = image.jpegData(compressionQuality: 0.5) else {
                promise(.failure(.custom("이미지 JPEG변환 실패")))
                return
            }
            reference.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    promise(.failure(.custom(error.localizedDescription)))
                    return
                }
                reference.downloadURL { url, error in
                    if let url = url {
                        promise(.success(url))
                    } else if let error = error {
                        promise(.failure(.custom(error.localizedDescription)))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    private func createThumbnail(for url: URL) -> AnyPublisher<UIImage?, VideoServiceError> {
        Future<UIImage?, VideoServiceError> { promise in
            DispatchQueue.global().async {
                let asset = AVAsset(url: url)
                let assetImgGenerate = AVAssetImageGenerator(asset: asset)
                assetImgGenerate.appliesPreferredTrackTransform = true
                assetImgGenerate.requestedTimeToleranceAfter = .zero
                assetImgGenerate.requestedTimeToleranceBefore = .zero

                let time = CMTimeMake(value: 1, timescale: 2)
                do {
                    let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
                    let thumbnail = UIImage(cgImage: img)
                    DispatchQueue.main.async {
                        promise(.success(thumbnail))
                    }
                } catch {
                    DispatchQueue.main.async {
                        promise(.failure(.custom("썸네일 생성 실패: \(error.localizedDescription)")))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}


class StubVideoService: VideoServiceProtocol {
    func uploadVideoAndThumbnail(url: URL, hearId: String) -> AnyPublisher<(videoURL: URL?, thumbnailURL: URL?), VideoServiceError> {
        Just((videoURL: nil, thumbnailURL: nil))
            .setFailureType(to: VideoServiceError.self)
            .eraseToAnyPublisher()
    }
}
