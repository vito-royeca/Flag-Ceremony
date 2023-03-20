//
//  AuthenticateViewModel.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 3/19/23.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

enum AuthenticateError : Error {
    case clientID, user, general
}

class AuthenticateViewModel: NSObject, ObservableObject {
    @Published var authenticated = false

    func signInWithGoogle(completion: @escaping (Result<Bool,Error>) -> Void) {
        guard let viewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {
            completion(.failure(AuthenticateError.general))
            return
        }

        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(.failure(AuthenticateError.clientID))
            return
        }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { [unowned self] result, error in
            guard error == nil else {
                completion(.failure(AuthenticateError.general))
                return
            }

            guard let user = result?.user,
               let idToken = user.idToken?.tokenString else {
                completion(.failure(AuthenticateError.user))
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)

            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    self.authenticated = true
                    completion(.success(true))
                }
            }
        }
    }
}
