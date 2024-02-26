//
//  AuthService.swift
//  Here-Hear
//
//  Created by Martin on 2/20/24.
//

import Foundation
import Combine
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices

enum AuthServiceError: Error {
    case clientIdError
    case tokenError
    case invalidated
}

protocol AuthServiceInterface {
    func checkAuthenticationState() -> String?
    func signInWithGoogle() -> AnyPublisher<UserEntity, ServiceError>
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) -> String
    func handleSignInWithAppleCompletion(_ authorization: ASAuthorization, none: String) -> AnyPublisher<UserEntity, ServiceError>
    func logout() -> AnyPublisher<Void, ServiceError>
    func signInAnonyMously() -> AnyPublisher<UserEntity, ServiceError>
}

class AuthService: AuthServiceInterface {
    func signInAnonyMously() -> AnyPublisher<UserEntity, ServiceError> {
        Future<UserEntity, ServiceError> { promise in
            Auth.auth().signInAnonymously { authResult, error in
                if let error = error {
                    promise(.failure(.error(error)))
                    return
                }
                guard let user = authResult?.user else {
                    let customError = NSError(domain: "AuthService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve user data after anonymous sign-in."])
                    promise(.failure(.error(customError as Error)))
                    return
                }
                let newUser = UserEntity(
                    id: user.uid,
                    nickname: "익명 사용자",
                    createdAt: user.metadata.creationDate ?? Date()
                )
                promise(.success(newUser))
            }
        }.eraseToAnyPublisher()
    }
    
    func checkAuthenticationState() -> String? {
        if let user = Auth.auth().currentUser {
            return user.uid
        } else {
            return nil
        }
    }
    
    func signInWithGoogle() -> AnyPublisher<UserEntity, ServiceError> {
        Future { [weak self] promise in
            self?.signInWithGoogle { result in
                switch result {
                case .success(let user):
                    promise(.success(user))
                case .failure(let error):
                    promise(.failure(.error(error)))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) -> String {
        request.requestedScopes = [.fullName, .email] 
        let nonce = randomNonceString()
        request.nonce = sha256(nonce)
        return nonce
    }
    
    func handleSignInWithAppleCompletion(_ authorization: ASAuthorization, none: String) -> AnyPublisher<UserEntity, ServiceError> {
        Future { [weak self] promise in
            self?.handleSignInWithAppleCompletion(authorization, nonce: none) { result in
                switch result {
                case .success(let user):
                    promise(.success(user))
                case .failure(let error):
                    promise(.failure(.error(error)))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func logout() -> AnyPublisher<Void, ServiceError> {
        Future { promise in
            do {
                try Auth.auth().signOut()
                promise(.success(()))
            } catch {
                promise(.failure(.error(error)))
            }
        }.eraseToAnyPublisher()
    }
}

extension AuthService {
    
    private func signInWithGoogle(completion: @escaping (Result<UserEntity, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(.failure(AuthServiceError.clientIdError))
            return
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
            if let error {
                completion(.failure(error))
                return
            }
            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                completion(.failure(AuthServiceError.tokenError))
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            
            self?.authenticateUserWithFirebase(credential: credential, completion: completion)
            
        }
    }
    
    private func handleSignInWithAppleCompletion(_ authorization: ASAuthorization,
                                                 nonce: String,
                                                 completion: @escaping (Result<UserEntity, Error>) -> Void) {
        guard let appleIdCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let appleIDToken = appleIdCredential.identityToken else { // idToken은 데이터형식임 -> String형식으로 변환 필요하다
            completion(.failure(AuthServiceError.tokenError))
            return
        }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            completion(.failure(AuthServiceError.tokenError))
            return
        }
        
        let credential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: idTokenString,
            rawNonce: nonce
        )
        authenticateUserWithFirebase(credential: credential) { result in
            switch result {
            case var .success(user):
                user.nickname = [appleIdCredential.fullName?.givenName, appleIdCredential.fullName?.familyName]
                    .compactMap({$0})
                    .joined(separator: " ")
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: Firebase 인증하는 함수
    private func authenticateUserWithFirebase(credential: AuthCredential, completion: @escaping (Result<UserEntity, Error>) -> Void) {
        Auth.auth().signIn(with: credential) { result, error in
            if let error {
                completion(.failure(error))
                return
            }
            guard let result else {
                completion(.failure(AuthServiceError.invalidated))
                return
            }
            let firebaseUser = result.user
            let user: UserEntity = .init(
                id: firebaseUser.uid,
                nickname: firebaseUser.displayName ?? "",
                createdAt: firebaseUser.metadata.creationDate ?? Date()
            )
            completion(.success(user))
        }
    }
}

class StubAuthService: AuthServiceInterface {
    func signInAnonyMously() -> AnyPublisher<UserEntity, ServiceError> {
        Empty().eraseToAnyPublisher()
    }
    
    func checkAuthenticationState() -> String? {
        return nil
    }
    
    func signInWithGoogle() -> AnyPublisher<UserEntity, ServiceError> {
        Empty().eraseToAnyPublisher()

    }
    
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) -> String {
        return ""
    }
    
    func handleSignInWithAppleCompletion(_ authorization: ASAuthorization, none: String) -> AnyPublisher<UserEntity, ServiceError> {
        Empty().eraseToAnyPublisher()
    }
    
    func logout() -> AnyPublisher<Void, ServiceError> {
        Empty().eraseToAnyPublisher()
    }
}
