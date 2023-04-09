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
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var accountViewModel: AccountViewModel
    @State var tab: AccountTab = .viewed
    @State var parentalGateApproved = false
    @State var authenticated = false
    @State private var isShowingEdit = false

    var body: some View {
        VStack {
            if accountViewModel.isLoggedIn {
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
                }
            }
        }
    }
    
    var dataView: some View {
        VStack(alignment: .leading) {
            List {
                headerView
                    .padding()
                tabView
                switch tab {
                case .viewed:
                    viewed
                case .played:
                    played
                case .favorites:
                    favorites
                }
            }
                .listStyle(.plain)
        }
            .toolbar {
                AccountViewToolbar(presentationMode: presentationMode,
                                   isShowingEdit: $isShowingEdit)
            }
            .sheet(isPresented: $isShowingEdit, content: {
                NavigationView {
                    EditAccountView()
                        .environmentObject(accountViewModel)
                }
            })
            .onAppear {
                accountViewModel.fetchUserData {
                    guard let account = accountViewModel.account else {
                        isShowingEdit = true
                        return
                    }
                    
                    if let name = account.displayName {
                        isShowingEdit = name.trimmingCharacters(in: .whitespaces).isEmpty
                    } else {
                        isShowingEdit = true
                    }
                }
            }
    }

    var headerView: some View {
        VStack(alignment: .leading) {
            HStack {
                AccountImageView(photoURL: .constant(URL(string: accountViewModel.account?.photoURL ?? "")))
                Text(accountViewModel.account?.displayName ?? "")
                    .font(Font.title)
            }
            HStack(alignment: .center) {
                Text("\(accountViewModel.activity?.viewCount ?? 0)")
                Image(systemName: "eye.fill")
                    .imageScale(.small)
                Text("\u{2022}")
                
                Text("\(accountViewModel.activity?.playCount ?? 0)")
                Image(systemName: "play.fill")
                    .imageScale(.small)
                Text("\u{2022}")
                
                Text("\(accountViewModel.favoriteCountries.count)")
                Image(systemName: "star.fill")
                    .imageScale(.small)
                Spacer()
            }
        }
            .frame(maxWidth: .infinity)
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
    
    var played: some View {
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
    
    var favorites: some View {
        ForEach(Array(accountViewModel.favoriteCountries.enumerated()), id: \.element) { index, country in
            HStack {
                Text(country.displayName)
                Spacer()
            }
        }
            .onDelete(perform: removeFavorites)
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

// MARK: - AccountViewToolbar

struct AccountViewToolbar: ToolbarContent {
    @EnvironmentObject var viewModel: AccountViewModel
    @Binding var presentationMode: PresentationMode
    @Binding var isShowingEdit: Bool

    init(presentationMode: Binding<PresentationMode>, isShowingEdit: Binding<Bool>) {
        _presentationMode = presentationMode
        _isShowingEdit = isShowingEdit
    }
    
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarLeading) {
            Button("Sign Out") {
                viewModel.signOut()
            }
        }
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button("Edit") {
                isShowingEdit.toggle()
            }
        }
    }
}


// MARK: - ParentalGateView

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
            Text("Sign In with your account to get access to advance features.")
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
                    Text("Sign In")
                        .foregroundColor(Color(uiColor: kBlueColor))
                    Spacer()
                }
            }
                .buttonStyle(.borderedProminent)
                .tint(.white)
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
            .padding()
    }

    func checkAnswer() {
        parentalGateApproved = answer == randomNumber.stringValue
        showFailure = !parentalGateApproved
        answer = ""
    }
}

// MARK: - AccountImageView

struct AccountImageView: View {
    @Binding var photoURL: URL?

    var body: some View {
        AsyncImage(
            url: photoURL,
            content: { image in
                image
                    .resizable()
                    .cornerRadius(50)
                    .padding(.all, 4)
                    .frame(width: 100, height: 100)
                    .background(Color.black.opacity(0.2))
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
            },
            placeholder: {
                Image(systemName: "person.circle")
                    .resizable()
                    .cornerRadius(50)
                    .frame(width: 100, height: 100)
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
            }
        )
    }
}
