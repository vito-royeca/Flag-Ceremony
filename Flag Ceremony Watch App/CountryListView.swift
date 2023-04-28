//
//  CountryListView.swift
//  Flag Ceremony Watch App
//
//  Created by Vito Royeca on 4/27/23.
//

import SwiftUI

struct CountryListView: View {
    @EnvironmentObject var viewModel: MapViewModel

    var body: some View {
        NavigationView {
            let dictionary = viewModel.searchResults(searchText: "")
            let keys = dictionary.keys.sorted()
            
            List {
                ForEach(keys, id:\.self) { key in
                    Section(header: Text(key)) {
                        ForEach(dictionary[key] ?? [], id: \.self) { country in
                            NavigationLink {
                                #if targetEnvironment(simulator)
                                CountryView(id: country.id, isAutoPlay: false)
                                #else
                                CountryView(id: country.id, isAutoPlay: true)
                                #endif
                            } label: {
                                Text(country.displayName)
                            }
                        }
                    }
                }
            }
                .navigationTitle("Flag Ceremony")
        }
            .task {
                viewModel.fetchAllCountries()
            }
    }
}

struct CountryListView_Previews: PreviewProvider {
    static var previews: some View {
        CountryListView()
            .environmentObject(MapViewModel())
    }
}
