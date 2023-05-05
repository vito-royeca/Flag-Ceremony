//
//  AccountView.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 6/27/20.
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
    @EnvironmentObject var viewModel: AccountViewModel
    @State var tab: AccountTab = .viewed
    @State var authenticated = false
    @State private var isShowingEdit = false

    var body: some View {
        VStack {
            if viewModel.isLoggedIn {
                dataView
            } else {
                if authenticated {
                    dataView
                } else {
                    AuthenticateView(authenticated: $authenticated)
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
                    .environmentObject(viewModel)
            }
        })
        .task {
            do {
                try await viewModel.fetchUserData()

                guard let account = viewModel.account else {
                    isShowingEdit = true
                    return
                }
                
                if let name = account.displayName {
                    isShowingEdit = name.trimmingCharacters(in: .whitespaces).isEmpty
                } else {
                    isShowingEdit = true
                }
            } catch let error {
                
            }
            
        }
    }

    var headerView: some View {
        VStack(alignment: .leading) {
            HStack {
                AccountImageView(photoURL: .constant(URL(string: viewModel.account?.photoURL ?? "")))
                Text(viewModel.account?.displayName ?? "")
                    .font(Font.title)
            }
            HStack(alignment: .center) {
                VStack {
                    Image(systemName: "eye.fill")
                        .imageScale(.large)
                    Text("AccountView_viewed_count".localized(viewModel.activity?.viewCount ?? 0))
                        .font(Font.callout.monospacedDigit())
                }
                Spacer()
                VStack {
                    Image(systemName: "play.fill")
                        .imageScale(.large)
                    Text("AccountView_played_count".localized(viewModel.activity?.playCount ?? 0))
                        .font(Font.callout.monospacedDigit())
                }
                Spacer()
                VStack {
                    Image(systemName: "star.fill")
                        .imageScale(.large)
                    Text("AccountView_favorites_count".localized(viewModel.favoriteCountries.count))
                        .font(Font.callout.monospacedDigit())
                    
                }
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
        ForEach(Array(viewModel.viewedCountries.enumerated()), id: \.element) { index, country in
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
        ForEach(Array(viewModel.playedCountries.enumerated()), id: \.element) { index, country in
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
        ForEach(Array(viewModel.favoriteCountries.enumerated()), id: \.element) { index, country in
            HStack {
                Text(country.displayName)
                Spacer()
            }
        }
        .onDelete(perform: removeFavorites)
    }
    
    func removeFavorites(at offsets: IndexSet) {
        let keysToDelete = offsets.map { viewModel.favoriteCountries[$0].key }

        _ = keysToDelete.compactMap { key in
            if let key = key {
                viewModel.toggleFavorite(key: key)
            }
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = AccountViewModel()

        AccountView()
            .environmentObject(viewModel)
            .task {
                do {
                    try await viewModel.fetchUserData()
                } catch let error {
                    
                }
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
