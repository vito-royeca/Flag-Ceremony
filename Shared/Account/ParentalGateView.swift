//
//  ParentalGateView.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 4/20/23.
//

import SwiftUI

struct ParentalGateView: View {
    @State private var showChallenge = false
    @State private var showFailure = false
    @State private var answer: String = ""
    @State private var randomNumber = NSNumber.randomNumber()
    @Binding var parentalGateApproved: Bool

    var body: some View {
        VStack {
            Spacer()
            Image("logo")
            Spacer()
            Text("ParentalGateView_body_text".localized)
                .foregroundColor(.white)
            buttonView
            Spacer()
        }
        .padding()
        .background(Color(uiColor: kBlueColor))
    }
    
    var buttonView: some View {
        VStack {
            Button(action: {
                randomNumber = NSNumber.randomNumber()
                showChallenge = true
            }) {
                HStack {
                    Spacer()
                    Text("ParentalGateView_sign_in".localized)
                        .foregroundColor(Color(uiColor: kBlueColor))
                    Spacer()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.white)
            .alert("ParentalGateView_parental_gate".localized, isPresented: $showChallenge, actions: {
                TextField("ParentalGateView_answer".localized, text: $answer)
                    .keyboardType(.numberPad)
                Button("ParentalGateView_submit".localized, action: checkAnswer)
                Button("ParentalGateView_cancel".localized, role: .cancel) { }
            }, message: {
                Text("ParentalGateView_question".localized(randomNumber.toRomanNumeral()))
            })
            .alert("ParentalGateView_incorrect".localized, isPresented: $showFailure) {
                Button("ParentalGateView_ok".localized, role: .cancel) { }
            }
        }
        .padding()
    }

    func checkAnswer() {
        parentalGateApproved = answer == randomNumber.stringValue
        showFailure = !parentalGateApproved
        answer = ""
    }
}

struct ParentalGateView_Previews: PreviewProvider {
    static var previews: some View {
        ParentalGateView(parentalGateApproved: .constant(false))
    }
}
