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
            // Google
            Button(action: {
                signWithGoogle()
            }) {
                HStack {
                    Image("google")
                    Spacer()
                    Text("AuthenticateView_sign_in_google".localized)
                        .foregroundColor(Color(uiColor: kBlueColor))
                    Spacer()
                }
            }
                .buttonStyle(.borderedProminent)
                .tint(.white)
            
            // Apple
            Button(action: {
                signWithApple()
            }) {
                HStack {
                    Image("apple")
                    Spacer()
                    Text("AuthenticateView_sign_in_apple".localized)
                        .foregroundColor(Color(uiColor: kBlueColor))
                    Spacer()
                }
            }
                .buttonStyle(.borderedProminent)
                .tint(.white)
        }
            .padding()
    }

    // MARK: - Actions

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
    
    func signWithApple() {
        viewModel.signInWithApple()
    }
}

struct AuthenticateView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticateView(authenticated: .constant(false))
    }
}

