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
    @State private var email: String = ""
    @State private var password: String = ""
    @Binding var authenticated: Bool
    
    init(authenticated: Binding<Bool>) {
        _authenticated = authenticated
        _viewModel = StateObject(wrappedValue: AuthenticateViewModel())
    }

    var body: some View {
        VStack {
            Image("splash screen")
            
            Group {
                Spacer()
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button {
                    
                } label: {
                    Text("Sign In")
                        .frame(maxWidth: .infinity)
                        .background(.white)
                        .foregroundColor(Color(uiColor: kBlueColor))
                        .clipShape(Capsule())
                }
                    .buttonStyle(.borderedProminent)
                    .tint(.white)
            }
            
            Group {
                Spacer()
                Text("Or Sign In with your other accounts")
                    .foregroundColor(.white)
                HStack {
//                    Spacer()
//                    Button(action: {
//
//                    }) {
//                        Image("facebook")
//                            .renderingMode(.template)
//                            .foregroundColor(.white)
//                    }
//                    Spacer()
//                    Button(action: {
//
//                    }) {
//                        Image("twitter")
//                            .renderingMode(.template)
//                            .foregroundColor(.white)
//                    }
                    Spacer()
                    Button(action: {
                        viewModel.signInWithGoogle { result in
                            switch result {
                            case .failure(let error):
                                print(error)
                            case.success(let authenticated):
                                self.authenticated = authenticated
                            }
                            
                        }
                    }) {
                        Image("google+")
                            .renderingMode(.template)
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
            }
            
            Group {
                Spacer()
                Text("No account yet?")
                    .foregroundColor(.white)
                Button {
                    
                } label: {
                    Text("Sign Up")
                        .frame(maxWidth: .infinity)
                        .background(.white)
                        .foregroundColor(Color(uiColor: kBlueColor))
                        .clipShape(Capsule())
                }
                    .buttonStyle(.borderedProminent)
                    .tint(.white)
            }
            
            
            
            Group {
                
                Spacer()
                Text("Forgot your password?")
                    .foregroundColor(.white)
                Button {
                    
                } label: {
                    Text("Retrieve password")
                        .frame(maxWidth: .infinity)
                        .background(.white)
                        .foregroundColor(Color(uiColor: kBlueColor))
                        .clipShape(Capsule())
                }
                    .buttonStyle(.borderedProminent)
                    .tint(.white)
            }
                
            Spacer()
        }
            .padding()
            .background(Color(uiColor: kBlueColor))
    }
}

struct AuthenticateView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticateView(authenticated: .constant(false))
    }
}
