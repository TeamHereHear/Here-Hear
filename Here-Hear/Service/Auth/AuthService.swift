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
    case failedToRetrieveAnonymousUserData
    case credentialAlreadyInUse
}

protocol AuthServiceInterface {
    // MARK: - User ID 확인
    func checkAuthenticationState() -> String?
    // MARK: - Sign In
    func signInWithGoogle() -> AnyPublisher<UserModel, ServiceError>
    
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) -> String
    func handleSignInWithAppleCompletion(_ authorization: ASAuthorization, nonce: String) -> AnyPublisher<UserModel, ServiceError>
    // MARK: - Log Out
    func logout() -> AnyPublisher<Void, ServiceError>
    // MARK: - Anonymous Sign In
    func anonymousSignIn() -> AnyPublisher<UserModel, ServiceError>
    func isAnonyMousUser() -> Bool
    // MARK: - Linking
    func linkGoogleAccount() -> AnyPublisher<UserModel, ServiceError>
    func handleLinkWithAppleCompletion(_ authorization: ASAuthorization, nonce: String) -> AnyPublisher<UserModel, ServiceError>
}

class AuthService: AuthServiceInterface {
    // MARK: - User ID 확인
    func checkAuthenticationState() -> String? {
        if let user = Auth.auth().currentUser {
            return user.uid
        }
        
        return nil
    }
    
    // MARK: - Sign In
    func signInWithGoogle() -> AnyPublisher<UserModel, ServiceError> {
        Future { [weak self] promise in
            self?.signInWithGoogle(isLinkingUser: false, completion: promise)
        }.eraseToAnyPublisher()
    }
    
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) -> String {
        request.requestedScopes = [.fullName, .email] 
        let nonce = randomNonceString()
        request.nonce = sha256(nonce)
        return nonce
    }
    
    func handleSignInWithAppleCompletion(_ authorization: ASAuthorization, nonce: String) -> AnyPublisher<UserModel, ServiceError> {
        Future { [weak self] promise in
            self?.handleSignInWithAppleCompletion(authorization, nonce: nonce, completion: promise)
        }.eraseToAnyPublisher()
    }
    
    // MARK: - Log Out
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
    
    // MARK: - Anonymous Sign In
    func anonymousSignIn() -> AnyPublisher<UserModel, ServiceError> {
        Future { promise in
            Auth.auth().signInAnonymously { authResult, error in
                
                if let error = error {
                    promise(.failure(.error(error)))
                    return
                }
                
                guard let user = authResult?.user else {
                    promise(.failure(.error(AuthServiceError.failedToRetrieveAnonymousUserData)))
                    return
                }
                
                let newUser = UserModel(
                    id: user.uid,
                    nickname: "익명 사용자",
                    createdAt: user.metadata.creationDate ?? Date()
                )
                
                promise(.success(newUser))
            }
        }.eraseToAnyPublisher()
    }
    
    func isAnonyMousUser() -> Bool {
        Auth.auth().currentUser?.isAnonymous ?? true
    }
    
    // MARK: - Linking
    func linkGoogleAccount() -> AnyPublisher<UserModel, ServiceError> {
        Future { [weak self] promise in
            self?.signInWithGoogle(
                isLinkingUser: true,
                completion: promise
            )
        }
        .eraseToAnyPublisher()
    }
    
    func handleLinkWithAppleCompletion(
        _ authorization: ASAuthorization,
        nonce: String
    ) -> AnyPublisher<UserModel, ServiceError> {
        
        Future { [weak self] promise in
            self?.handleLinkWithAppleCompletion(
                authorization,
                nonce: nonce,
                completion: promise
            )
        }
        .eraseToAnyPublisher()
    }
}

extension AuthService {
    
    /// Google Sign in 과정을 수행하는 메서드
    /// - Parameters:
    ///   - isLinkingUser: 익명로그인 사용자가 기존 계정에 연결하는지 여부
    ///   - completion: (Result<UserModel, ServiceError>) -> Void
    private func signInWithGoogle(isLinkingUser: Bool, completion: @escaping (Result<UserModel, ServiceError>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(.failure(.error(AuthServiceError.clientIdError)))
            return
        }

        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            completion(.failure(.error(AuthServiceError.invalidated)))
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
            if let error {
                completion(.failure(.error(error)))
                return
            }
            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                completion(.failure(.error(AuthServiceError.tokenError)))
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            // 익명 사용자가 기존 계정에 연결하는지에 따라 분기
            if isLinkingUser {
                self?.linkUserWithFirebase(credetial: credential, completion: completion)
            } else {
                self?.authenticateUserWithFirebase(credential: credential, completion: completion)
            }
        }
    }
    
    private func handleSignInWithAppleCompletion(_ authorization: ASAuthorization,
                                                 nonce: String,
                                                 completion: @escaping (Result<UserModel, ServiceError>) -> Void) {
        guard let appleIdCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let appleIDToken = appleIdCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else { // idToken은 데이터형식임 -> String형식으로 변환 필요하다
            completion(.failure(.error(AuthServiceError.tokenError)))
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
                    .compactMap({ $0 })
                    .joined(separator: " ")
                completion(.success(user))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    private func handleLinkWithAppleCompletion(_ authorization: ASAuthorization,
                                               nonce: String,
                                               completion: @escaping (Result<UserModel, ServiceError>) -> Void) {
        guard let appleIdCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let appleIDToken = appleIdCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            // idToken은 데이터형식임 -> String형식으로 변환 필요하다
            completion(.failure(.error(AuthServiceError.tokenError)))
            return
        }
        
        let credential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: idTokenString,
            rawNonce: nonce
        )
        
        linkUserWithFirebase(credetial: credential) { result in
            switch result {
            case var .success(user):
                user.nickname = [appleIdCredential.fullName?.givenName, appleIdCredential.fullName?.familyName]
                    .compactMap({$0})
                    .joined(separator: " ")
                completion(.success(user))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: Firebase 인증하는 함수
    private func authenticateUserWithFirebase(credential: AuthCredential, completion: @escaping (Result<UserModel, ServiceError>) -> Void) {
        Auth.auth().signIn(with: credential) { result, error in
            if let error {
                print(error.localizedDescription)
                completion(.failure(.error(error)))
                return
            }
            guard let result else {
                completion(.failure(.error(AuthServiceError.invalidated)))
                return
            }
            let firebaseUser = result.user
            let user: UserModel = .init(
                id: firebaseUser.uid,
                nickname: firebaseUser.displayName ?? "",
                createdAt: firebaseUser.metadata.creationDate ?? Date()
            )
            completion(.success(user))
        }
    }
    
    private func linkUserWithFirebase(
        credetial: AuthCredential,
        completion: @escaping ((Result<UserModel, ServiceError>) -> Void)
    ) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(.error(AuthServiceError.invalidated)))
            return
        }
        
        user.link(with: credetial) { result, error in
            if let error {
                completion(.failure(.error(error)))
                return
            }
            
            guard let result else {
                completion(.failure(.error(AuthServiceError.invalidated)))
                return
            }
            
            let linkingUser: UserModel = .init(
                id: result.user.uid,
                nickname: result.user.displayName ?? "",
                createdAt: result.user.metadata.creationDate ?? Date()
            )
            
            completion(.success(linkingUser))
        }
    }
     
}

class StubAuthService: AuthServiceInterface {
    
    func anonymousSignIn() -> AnyPublisher<UserModel, ServiceError> {
        Empty().eraseToAnyPublisher()
    }
    
    func checkAuthenticationState() -> String? {
        return nil
    }
    
    func signInWithGoogle() -> AnyPublisher<UserModel, ServiceError> {
        Empty().eraseToAnyPublisher()

    }
    
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) -> String {
        return ""
    }
    
    func handleSignInWithAppleCompletion(_ authorization: ASAuthorization, nonce: String) -> AnyPublisher<UserModel, ServiceError> {
        Empty().eraseToAnyPublisher()
    }
    
    func linkGoogleAccount() -> AnyPublisher<UserModel, ServiceError> {
        Empty().eraseToAnyPublisher()
    }
    
    func handleLinkWithAppleCompletion(_ authorization: ASAuthorization, nonce: String) -> AnyPublisher<UserModel, ServiceError> {
        Empty().eraseToAnyPublisher()
    }
    
    func logout() -> AnyPublisher<Void, ServiceError> {
        Empty().eraseToAnyPublisher()
    }
    
    func isAnonyMousUser() -> Bool {
        true
    }
}
