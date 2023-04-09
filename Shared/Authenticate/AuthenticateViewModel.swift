//
//  AuthenticateViewModel.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 3/19/23.
//

import CryptoKit
import SwiftUI
import FirebaseCore
import FirebaseAuth

enum AuthenticateError : Error {
    case clientID, user, general, cancelled
}

class AuthenticateViewModel: NSObject, ObservableObject {
    @Published var authenticated = false
    var currentNonce = ""

    func authWithFirebase(with credential: AuthCredential, completion: @escaping (Result<Bool,Error>) -> Void) {
        Auth.auth().signIn(with: credential) { result, error in
            if let error = error {
                completion(.failure(error))
            } else {
                self.authenticated = true
                completion(.success(true))
            }
        }
    }
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }
}
