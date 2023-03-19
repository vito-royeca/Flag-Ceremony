//
//  AccountView.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 6/27/20.
//  Copyright © 2020 Jovit Royeca. All rights reserved.
//

import SwiftUI

enum AccountTab: String, CaseIterable, Identifiable {
    case viewed, played, favorites
    
    var id: String {
        return self.rawValue
    }
    
    var description: String {
        switch self {
        case .viewed:
            return "Viewed"
        case .played:
            return "Played"
        case .favorites:
            return "Favorites"
        }
    }
}

struct AccountView: View {
    @StateObject var viewModel = AccountViewModel()
    @State var tab: AccountTab = .viewed
    @State var parentalGateApproved = false

    var body: some View {
        VStack {
            if viewModel.isLoggedIn {
                mainView
            } else {
                if parentalGateApproved {
                    AuthenticateView()
                } else {
                    ParentalGateView(parentalGateApproved: $parentalGateApproved)
                }
            }
        }
    }
    
    func fetchData() {
        switch tab {
        case .viewed:
            viewModel.fetchViewedCountries()
        case .played:
            viewModel.fetchPlayedCountries()
        case .favorites:
            ()
        }
    }
    
    var mainView: some View {
        VStack {
            switch tab {
            case .viewed:
                viewed
            case .played:
                played
            case .favorites:
                favorites
            }
        }
            .navigationTitle("Charts")
            .onAppear() {
                fetchData()
            }
            .onDisappear {
                viewModel.muteData()
            }
    }

    var tabView: some View {
        Picker("", selection: $tab) {
            ForEach(AccountTab.allCases, id: \.id) { index in
                Text(index.description)
                    .tag(index)
            }
        }
            .pickerStyle(.segmented)
            .listRowSeparator(.hidden)
            .onAppear() {
                fetchData()
            }
    }

    var viewed: some View {
        List {
            tabView
            ForEach(Array(viewModel.viewedCountries.enumerated()), id: \.element) { index, country in
                ChartCountryRowView(index: index+1,
                                    name: country.displayName,
                                    count: country.views ?? 0,
                                    countIcon: Image(systemName: "eye.fill"))
            }
        }
            .listStyle(.plain)
    }
    
    var played: some View {
        List {
            tabView
            ForEach(Array(viewModel.playedCountries.enumerated()), id: \.element) { index, country in
                ChartCountryRowView(index: index+1,
                                    name: country.displayName,
                                    count: country.plays ?? 0,
                                    countIcon: Image(systemName: "play.fill"))
            }
        }
            .listStyle(.plain)
    }
    
    var favorites: some View {
        List {
            tabView
            ForEach(Array(viewModel.playedCountries.enumerated()), id: \.element) { index, country in
                ChartCountryRowView(index: index+1,
                                    name: country.displayName,
                                    count: country.plays ?? 0,
                                    countIcon: Image(systemName: "play.fill"))
            }
        }
            .listStyle(.plain)
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}

struct ParentalGateView: View {
    @State private var showChallenge = false
    @State private var showFailure = false
    @State private var answer: String = ""
    @State private var randomNumber = NSNumber.randomNumber()
    @Binding var parentalGateApproved: Bool

    var body: some View {
        VStack {
            Text("Signin with your account to get access to advance features.")
            Button(action: {
                showChallenge = true
                randomNumber = NSNumber.randomNumber()
            }) {
                Image(systemName: "arrow.right.circle")
                    .font(Font.largeTitle)
                    .imageScale(.large)
            }
                .alert("Parental Gate", isPresented: $showChallenge, actions: {
                    TextField("Answer", text: $answer)
                        .keyboardType(.numberPad)
                    
                    Button("Submit", action: checkAnswer)
                    Button("Cancel", role: .cancel) {}
                }, message: {
                    Text("Ask your parent or guardian to help you answer the question below.\n\nThe Roman Numeral \(randomNumber.toRomanNumeral()) is equivalent to?")
                })
                .alert("The answer is incorrect.", isPresented: $showFailure) {
                    Button("OK", role: .cancel) {}
                }
        }
    }
    
    func checkAnswer() {
        parentalGateApproved = answer == randomNumber.stringValue
        showFailure = !parentalGateApproved
    }
}
