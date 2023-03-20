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
    @EnvironmentObject var accountViewModel: AccountViewModel
    @State var tab: AccountTab = .viewed
    @State var parentalGateApproved = false
    @State var authenticated = false

    var body: some View {
        VStack {
            if accountViewModel.account != nil {
                dataView
            } else {
                if parentalGateApproved {
                    if authenticated {
                        dataView
                    } else {
                        AuthenticateView(authenticated: $authenticated)
                    }
                } else {
                    ParentalGateView(parentalGateApproved: $parentalGateApproved)
                        .background(Color(uiColor: kBlueColor))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
    }
    
    var dataView: some View {
        VStack(alignment: .leading) {
            switch tab {
            case .viewed:
                viewed
            case .played:
                played
            case .favorites:
                favorites
            }
        }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if accountViewModel.account != nil {
                        Button("Sign Out") {
                            accountViewModel.signOut()
                        }
                    } else {
                        EmptyView()
                    }
                }
            }
            .onAppear {
                accountViewModel.fetchUserData()
            }
    }

    var headerView: some View {
        VStack(alignment: .leading) {
            HStack {
                AsyncImage(
                    url: accountViewModel.account?.photoURL,
                    content: { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                    },
                    placeholder: {
                        Image(systemName: "person.circle")
                            .imageScale(.large)
                    }
                )
                Text(accountViewModel.account?.displayName ?? "")
            }
            HStack {
                Text("\(accountViewModel.activity?.viewCount ?? 0)")
                Image(systemName: "eye.fill")
                    .imageScale(.small)
                Text("\(accountViewModel.activity?.playCount ?? 0)")
                Image(systemName: "play.fill")
                    .imageScale(.small)
            }
        }
            .listRowSeparator(.hidden)
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
    }

    var viewed: some View {
        List {
            headerView
                .padding()
            tabView
            ForEach(Array(accountViewModel.viewedCountries.enumerated()), id: \.element) { index, country in
                HStack {
                    Text(country.displayName)
                    Spacer()
                    Text("\(country.userViews)")
                    Image(systemName: "eye.fill")
                        .imageScale(.small)
                }
            }
        }
            .listStyle(.plain)
    }
    
    var played: some View {
        List {
            headerView
                .padding()
            tabView
            ForEach(Array(accountViewModel.playedCountries.enumerated()), id: \.element) { index, country in
                HStack {
                    Text(country.displayName)
                    Spacer()
                    Text("\(country.userPlays)")
                    Image(systemName: "play.fill")
                        .imageScale(.small)
                }
            }
        }
            .listStyle(.plain)
    }
    
    var favorites: some View {
        List {
            headerView
                .padding()
            tabView
            ForEach(Array(accountViewModel.favoriteCountries.enumerated()), id: \.element) { index, country in
                Text(country.displayName)
            }
                .onDelete(perform: removeFavorites)
        }
            .listStyle(.plain)
    }
    
    func removeFavorites(at offsets: IndexSet) {
        let keysToDelete = offsets.map { accountViewModel.favoriteCountries[$0].key }

        _ = keysToDelete.compactMap { key in
            if let key = key {
                accountViewModel.toggleFavorite(key: key)
            }
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        let accountViewModel = AccountViewModel()
        AccountView()
            .environmentObject(accountViewModel)
            .onAppear {
                accountViewModel.fetchUserData()
            }
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
            Image("splash screen")
            Text("Sign In with your account to get access to advance features.")
                .foregroundColor(.white)
            Button(action: {
                showChallenge = true
                randomNumber = NSNumber.randomNumber()
            }) {
                Image(systemName: "arrow.right.circle")
                    .foregroundColor(.white)
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
        answer = ""
    }
}
