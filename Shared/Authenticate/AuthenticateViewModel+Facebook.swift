//
//  AuthenticateViewModel+Facebook.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 4/8/23.
//

import FirebaseCore
import FirebaseAuth
import FacebookLogin

extension AuthenticateViewModel {
    func signInWithFacebook(completion: @escaping (Result<Bool,Error>) -> Void) {
        /*
         let nonce = randomNonceString()
         currentNonce = nonce
         //        loginButton.delegate = self
         //        loginButton.loginTracking = .limited
         //        loginButton.nonce = sha256(nonce)
         
         
         let idTokenString = AuthenticationToken.current?.tokenString
         let credential = OAuthProvider.credential(withProviderID: "facebook.com",
         idToken: idTokenString!,
         rawNonce: currentNonce)
         
         
         //        let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
         //        authWithFirebase(with: credential, completion: completion)
         */
        
        let manager = LoginManager()
        manager.logIn(permissions: ["public_profile"], from: nil, handler: { (result, error) -> Void in
            if let error = error {
                completion(.failure(error))
            } else {
                if let result = result {
                    if result.isCancelled {
                        completion(.failure(AuthenticateError.cancelled))
                    } else {
                        if result.grantedPermissions.contains("public_profile") {
                            let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
                            self.authWithFirebase(with: credential, completion: completion)
                        } else {
                            completion(.failure(error ?? AuthenticateError.general))
                        }
                    }
                }
            }
        })
    }
}
