//
//  ChartsView.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 6/27/20.
//  Copyright © 2020 Jovit Royeca. All rights reserved.
//

import SwiftUI

enum TopCharts: String, CaseIterable, Identifiable {
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
    @State var topChart: TopCharts = .topViewed
    
    var body: some View {
        VStack {
            Picker("Top", selection: $topChart) {
                ForEach(TopCharts.allCases, id: \.id) { index in
                    Text(index.description)
                        .tag(index)
                }
            }
                .pickerStyle(.segmented)
                .padding()
                .onChange(of: topChart) { _ in
                    fetchData()
                }
                .onAppear() {
                    fetchData()
                }
            
            switch topChart {
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
    }
    
    func fetchData() {
        switch topChart {
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
    
    var topViewed: some View {
        List {
            ForEach(Array(viewModel.topViewedCountries.enumerated()), id: \.element) { index, country in
                ChartCountryRowView(index: index+1,
                                    name: country.displayName,
                                    count: country.views ?? 0,
                                    countIcon: Image(systemName: "eye.fill"))
            }
        }
            .listStyle(.plain)
    }
    
    var topPlayed: some View {
        List {
            ForEach(Array(viewModel.topPlayedCountries.enumerated()), id: \.element) { index, country in
                ChartCountryRowView(index: index+1,
                                    name: country.displayName,
                                    count: country.plays ?? 0,
                                    countIcon: Image(systemName: "play.fill"))
            }
        }
            .listStyle(.plain)
    }
    
    var topViewers: some View {
        List {
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
            .listStyle(.plain)
    }
    
    var topPlayers: some View {
        List {
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
            .listStyle(.plain)
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
            Text("#\(index+1)")
            Text(name)
            Spacer()
            Text("\(count)")
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
            Text("#\(index)")
            AsyncImage(
                url: photoUrl,
                content: { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 25, height: 25)
                        .clipShape(Circle())
                },
                placeholder: {
                    Image(systemName: "person.circle")
                        .imageScale(.large)
                }
            )
                
            Text(name)
            Spacer()
            Text("\(count)")
            countIcon
                .imageScale(.small)
        }
    }
}
