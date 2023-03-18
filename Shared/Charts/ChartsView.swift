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
    
    var id: String { return self.rawValue }
    
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
                HStack {
                    Text("#\(index+1)")
                    Text(country.displayName)
                    Spacer()
                    Text("\(country.views ?? 0)")
                    Image(systemName: "eye.fill")
                        .imageScale(.small)
                }
            }
        }
            .listStyle(.plain)
    }
    
    var topPlayed: some View {
        List {
            ForEach(Array(viewModel.topPlayedCountries.enumerated()), id: \.element) { index, country in
                HStack {
                    Text("#\(index+1)")
                    Text(country.displayName)
                    Spacer()
                    Text("\(country.plays ?? 0)")
                    Image(systemName: "play.fill")
                        .imageScale(.small)
                }
            }
        }
            .listStyle(.plain)
    }
    
    var topViewers: some View {
        List {
            ForEach(Array(viewModel.topViewers.enumerated()), id: \.element) { index, activity in
                if let user = viewModel.users.first(where: { $0.id == activity.id}) {
                    HStack {
                        Text("#\(index+1)")
//                        AsyncImage(
//                            url: URL(string: user.photoURL ?? ""),
//                            content: { image in
//                                image
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fit)
//                            },
//                            placeholder: {
//                                ProgressView()
//                            }
//                        )
                        Text(user.displayName ?? "")
                        Spacer()
                        Text("\(activity.viewCount ?? 0)")
                        Image(systemName: "eye.fill")
                            .imageScale(.small)
                    }
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
                    HStack {
                        Text("#\(index+1)")
                        Text(user.displayName ?? "")
                        Spacer()
                        Text("\(activity.playCount ?? 0)")
                        Image(systemName: "play.fill")
                            .imageScale(.small)
                    }
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
