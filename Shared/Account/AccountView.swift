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
            return "AccountView_viewed".localized
        case .played:
            return "AccountView_played".localized
        case .favorites:
            return "AccountView_favorites".localized
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
                                   isShowingEdit: $isShowingEdit,
                                   isAuthenticated: $authenticated)
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
                    .font(Font.callout.monospacedDigit())
                Image(systemName: "eye.fill")
                    .imageScale(.small)
                Text("\u{2022}")
                
                Text("\(accountViewModel.activity?.playCount ?? 0)")
                    .font(Font.callout.monospacedDigit())
                Image(systemName: "play.fill")
                    .imageScale(.small)
                Text("\u{2022}")
                
                Text("\(accountViewModel.favoriteCountries.count)")
                    .font(Font.callout.monospacedDigit())
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
    @Binding var isAuthenticated: Bool

    init(presentationMode: Binding<PresentationMode>,
         isShowingEdit: Binding<Bool>,
         isAuthenticated: Binding<Bool>) {
        _presentationMode = presentationMode
        _isShowingEdit = isShowingEdit
        _isAuthenticated = isAuthenticated
    }
    
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarLeading) {
            Button("AccountView_sign_out".localized) {
                viewModel.signOut()
                isAuthenticated = false
            }
        }
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button("AccountView_edit".localized) {
                isShowingEdit.toggle()
            }
        }
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
