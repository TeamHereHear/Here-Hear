import Foundation
import FirebaseStorage
import Combine
import Firebase
import AVKit

enum VideoServiceError: Error {
    case custom(String)
    case defaultError

    var localizedDescription: String {
        switch self {
        case .custom(let message):
            return message
        case .defaultError:
            return "예상 못한 에러 발생"
        }
    }
}

protocol VideoServiceProtocol {
    func uploadVideoAndThumbnail(url: URL, hearId: String) -> AnyPublisher<(videoURL: URL?, thumbnailURL: URL?), VideoServiceError>
}

class VideoService: VideoServiceProtocol {
    private let storageReference = Storage.storage().reference()

    func uploadVideoAndThumbnail(url: URL, hearId: String) -> AnyPublisher<(videoURL: URL?, thumbnailURL: URL?), VideoServiceError> {
        Future<(videoURL: URL?, thumbnailURL: URL?), VideoServiceError> { promise in
            self.createThumbnail(for: url) { thumbnail in
                let videoRef = self.storageReference.child("Video/\(hearId).mov")
                let thumbnailRef = self.storageReference.child("Thumbnail/\(hearId).jpg")

                self.uploadVideo(url: url, to: videoRef) { result in
                    switch result {
                    case .success(let videoURL):
                        if let thumbnail = thumbnail {
                            self.uploadImage(thumbnail, to: thumbnailRef) { result in
                                switch result {
                                case .success(let thumbnailURL):
                                    promise(.success((videoURL: videoURL, thumbnailURL: thumbnailURL)))
                                case .failure(let error):
                                    promise(.failure(error))
                                }
                            }
                        } else {
                            promise(.failure(.custom("Thumbnail creation failed")))
                        }
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    private func uploadVideo(url: URL, to reference: StorageReference, completion: @escaping (Result<URL?, VideoServiceError>) -> Void) {
        reference.putFile(from: url, metadata: nil) { _, error in
            if let error = error {
                completion(.failure(.custom(error.localizedDescription)))
                return
            }
            reference.downloadURL { url, error in
                if let url = url {
                    completion(.success(url))
                } else if let error = error {
                    completion(.failure(.custom(error.localizedDescription)))
                }
            }
        }
    }

    private func uploadImage(_ image: UIImage, to reference: StorageReference, completion: @escaping (Result<URL?, VideoServiceError>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            completion(.failure(.custom("이미지 JPEG변환 실패")))
            return
        }
        reference.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(.custom(error.localizedDescription)))
                return
            }
            reference.downloadURL { url, error in
                if let url = url {
                    completion(.success(url))
                } else if let error = error {
                    completion(.failure(.custom(error.localizedDescription)))
                }
            }
        }
    }

    private func createThumbnail(for url: URL, completion: @escaping (UIImage?) -> Void) {
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
                    completion(thumbnail)
                }
            } catch {
                print("thumbnail 생성 실패: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
}

class StubVideoService: VideoServiceProtocol {
    func uploadVideoAndThumbnail(url: URL, hearId: String) -> AnyPublisher<(videoURL: URL?, thumbnailURL: URL?), VideoServiceError> {
        Just((videoURL: nil, thumbnailURL: nil))
            .setFailureType(to: VideoServiceError.self)
            .eraseToAnyPublisher()
    }
}
