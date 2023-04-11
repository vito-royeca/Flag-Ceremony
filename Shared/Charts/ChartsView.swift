//
//  ChartsView.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 6/27/20.
//  Copyright © 2020 Jovit Royeca. All rights reserved.
//

import SwiftUI

enum ChartsTab: String, CaseIterable, Identifiable {
    case topViewed, topPlayed, topViewers, topPlayers
    
    var id: String {
        return self.rawValue
    }
    
    var description: String {
        switch self {
        case .topViewed:
            return "Top Viewed"
        case .topPlayed:
            return "Top Played"
        case .topViewers:
            return "Top Viewers"
        case .topPlayers:
            return "Top Players"
        }
    }
}

// MARK: - ChartsView

struct ChartsView: View {
    @StateObject var viewModel = ChartsViewModel()
    @State var tab: ChartsTab = .topViewed
    
    var body: some View {
        VStack {
            List {
                tabView
                switch tab {
                case .topViewed:
                    topViewed
                case .topPlayed:
                    topPlayed
                case .topViewers:
                    topViewers
                case .topPlayers:
                    topPlayers
                }
            }
                .listStyle(.plain)
        }
            .navigationTitle("Charts")
            .onAppear() {
                fetchData()
            }
            .onDisappear {
                viewModel.muteData()
            }
    }
    
    func fetchData() {
        switch tab {
        case .topViewed:
            viewModel.fetchTopViewedCountries()
        case .topPlayed:
            viewModel.fetchTopPlayedCountries()
        case .topViewers:
            viewModel.fetchUsers()
            viewModel.fetchTopViewers()
        case .topPlayers:
            viewModel.fetchUsers()
            viewModel.fetchTopPlayers()
        }
    }
    
    var tabView: some View {
        Picker("", selection: $tab) {
            ForEach(ChartsTab.allCases, id: \.id) { index in
                Text(index.description)
                    .tag(index)
            }
        }
            .onChange(of: tab) { _ in
                fetchData()
            }
            .pickerStyle(.segmented)
            .listRowSeparator(.hidden)
    }

    var topViewed: some View {
        ForEach(Array(viewModel.topViewedCountries.enumerated()), id: \.element) { index, country in
            ChartCountryRowView(index: index+1,
                                name: country.displayName,
                                count: country.views ?? 0,
                                countIcon: Image(systemName: "eye.fill"))
        }
    }
    
    var topPlayed: some View {
        ForEach(Array(viewModel.topPlayedCountries.enumerated()), id: \.element) { index, country in
            ChartCountryRowView(index: index+1,
                                name: country.displayName,
                                count: country.plays ?? 0,
                                countIcon: Image(systemName: "play.fill"))
        }
    }
    
    var topViewers: some View {
        ForEach(Array(viewModel.topViewers.enumerated()), id: \.element) { index, activity in
            if let user = viewModel.users.first(where: { $0.id == activity.id}) {
                ChartUserRowView(index: index+1,
                                 photoUrl: URL(string: user.photoURL ?? ""),
                                 name: user.displayName ?? "",
                                 count: activity.viewCount ?? 0,
                                 countIcon: Image(systemName: "eye.fill"))
            } else {
                EmptyView()
            }
        }
    }
    
    var topPlayers: some View {
        ForEach(Array(viewModel.topPlayers.enumerated()), id: \.element) { index, activity in
            if let user = viewModel.users.first(where: { $0.id == activity.id}) {
                ChartUserRowView(index: index+1,
                                 photoUrl: URL(string: user.photoURL ?? ""),
                                 name: user.displayName ?? "",
                                 count: activity.playCount ?? 0,
                                 countIcon: Image(systemName: "play.fill"))
            } else {
                EmptyView()
            }
        }
    }
}

struct ChartsView_Previews: PreviewProvider {
    static var previews: some View {
        ChartsView()
    }
}

// MARK: - ChartCountryRowView

struct ChartCountryRowView: View {
    @State var index: Int
    @State var name: String
    @State var count: Int
    @State var countIcon: Image
    
    var body: some View {
        HStack {
            Text("\(index)")
                .font(Font.callout.monospacedDigit())
            Text(name)
            Spacer()
            Text("\(count)")
                .font(Font.callout.monospacedDigit())
            countIcon
                .imageScale(.small)
        }
    }
}

// MARK: - ChartUserRowView

struct ChartUserRowView: View {
    @State var index: Int
    @State var photoUrl: URL?
    @State var name: String
    @State var count: Int
    @State var countIcon: Image

    var body: some View {
        HStack {
            Text("\(index)")
                .font(Font.callout.monospacedDigit())
            AsyncImage(
                url: photoUrl,
                content: { image in
                    image
                        .resizable()
                        .frame(width: 25, height: 25)
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                },
                placeholder: {
                    Image(systemName: "person.circle")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                }
            )
                
            Text(name)
            Spacer()
            Text("\(count)")
                .font(Font.callout.monospacedDigit())
            countIcon
                .imageScale(.small)
        }
    }
}
