//
//  AuthenticateView.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 3/18/23.
//

import SwiftUI
import Firebase

struct AuthenticateView: View {
    @StateObject var viewModel: AuthenticateViewModel
    
    init(authenticated: Binding<Bool>) {
        _viewModel = StateObject(wrappedValue: AuthenticateViewModel(authenticated: authenticated))
    }

    var body: some View {
        VStack {
            Spacer()
            Image("logo")
            buttons
                .padding()
            Spacer()
        }
            .padding()
            .background(Color(uiColor: kBlueColor))
    }
    
    var buttons: some View {
        VStack {
            // Mail
//            Button(action: {
//                signWithEmail()
//            }) {
//                HStack {
//                    Image("mail")
//                    Spacer()
//                    Text("Sign in with email")
//                        .foregroundColor(Color(uiColor: kBlueColor))
//                    Spacer()
//                }
//            }
//            .buttonStyle(.borderedProminent)
//            .tint(.white)
            
            // Google
            Button(action: {
                signWithGoogle()
            }) {
                HStack {
                    Image("google")
                    Spacer()
                    Text("Sign in with Google")
                        .foregroundColor(Color(uiColor: kBlueColor))
                    Spacer()
                }
            }
                .buttonStyle(.borderedProminent)
                .tint(.white)
            
            // Facebook
//            Button(action: {
//                signWithFacebook()
//            }) {
//                HStack {
//                    Image("facebook")
//                    Spacer()
//                    Text("Sign in with Facebook")
//                        .foregroundColor(Color(uiColor: kBlueColor))
//                    Spacer()
//                }
//            }
//            .buttonStyle(.borderedProminent)
//            .tint(.white)
            
            // Apple
            Button(action: {
                signWithApple()
            }) {
                HStack {
                    Image("apple")
                    Spacer()
                    Text("Sign in with Apple")
                        .foregroundColor(Color(uiColor: kBlueColor))
                    Spacer()
                }
            }
                .buttonStyle(.borderedProminent)
                .tint(.white)
            
            // Phone
//            Button(action: {
//                signWithPhone()
//            }) {
//                HStack {
//                    Image("phone")
//                    Spacer()
//                    Text("Sign in with phone")
//                        .foregroundColor(Color(uiColor: kBlueColor))
//                    Spacer()
//                }
//            }
//            .buttonStyle(.borderedProminent)
//            .tint(.white)

            // Anonymous
//            Button(action: {
//                signAnonymously()
//            }) {
//                HStack {
//                    Image("anonymous")
//                    Spacer()
//                    Text("Sign in anonymously")
//                        .foregroundColor(Color(uiColor: kBlueColor))
//                    Spacer()
//                }
//            }
//            .buttonStyle(.borderedProminent)
//            .tint(.white)
        }
            .padding()
    }

    // MARK: - Actions

    func signWithEmail() {
        
    }

    func signWithGoogle() {
        viewModel.signInWithGoogle { result in
            switch result {
            case .failure(let error):
                print(error)
            case.success:
                ()
            }
        }
    }
    
    func signWithFacebook() {
//        viewModel.signInWithFacebook { result in
//            switch result {
//            case .failure(let error):
//                print(error)
//            case.success:
//                ()
//            }
//        }
    }
    
    func signWithApple() {
        viewModel.signInWithApple()
    }
    
    func signWithPhone() {
        
    }
    
    func signAnonymously() {
        
    }
}

struct AuthenticateView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticateView(authenticated: .constant(false))
    }
}

