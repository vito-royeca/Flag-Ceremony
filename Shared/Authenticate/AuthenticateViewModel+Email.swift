//
//  AuthenticateViewModel+Email.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 4/8/23.
//

import FirebaseCore
import FirebaseAuth
import GoogleSignIn

extension AuthenticateViewModel {
    func signIn(withEmail email: String, password: String, completion: @escaping (Result<Bool,Error>) -> Void) {
        guard let viewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {
            completion(.failure(AuthenticateError.general))
            return
        }

        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(.failure(AuthenticateError.clientID))
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
          
          
        }
    }
}
