import Foundation
import FirebaseStorage
import Combine
import Firebase

enum VideoServiceError: Error {
    case custom(String)
    case defaultError

    var localizedDescription: String {
        switch self {
        case .custom(let message):
            return message
        case .defaultError:
            return "An unexpected error occurred"
        }
    }
}

protocol VideoServiceProtocol {
    func uploadVideo(url: URL, hearId: String) -> AnyPublisher<URL?, ServiceError>
}

class VideoService: VideoServiceProtocol {
    private let storageReference = Storage.storage().reference()

    func uploadVideo(url: URL, hearId: String) -> AnyPublisher<URL?, ServiceError> {
        
        let userId = Auth.auth().currentUser?.uid
        
        let videoRef = storageReference.child("Video/\(userId ?? "")/\(hearId).mov")

        return Future<URL?, VideoServiceError> { promise in
            videoRef.putFile(from: url, metadata: nil) { _, error in
                if let error = error {
                    promise(.failure(VideoServiceError.custom(error.localizedDescription)))
                    return
                }

                videoRef.downloadURL { url, error in
                    if let url = url {
                        promise(.success(url))
                    } else if let error = error {
                        promise(.failure(VideoServiceError.custom(error.localizedDescription)))
                    }
                }
            }
        }
        .mapError { ServiceError.error($0) }
        .eraseToAnyPublisher()
    }
}

class StubVideoService: VideoServiceProtocol {
    func uploadVideo(url: URL, hearId: String) -> AnyPublisher<URL?, ServiceError> {
        Empty().eraseToAnyPublisher()
    }
}
