//
//  MapSearchView.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 3/27/23.
//

import SwiftUI

struct MapSearchView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: MapViewModel
    @State private var searchText = ""
    @Binding var highlightedCountry: FCCountry?

    var body: some View {
        List {
            ForEach(searchResults, id: \.self) { country in
                HStack {
                    VStack(alignment: .leading) {
                        Text(country.displayName)
                        Text("Capital: \(country.capital?[FCCountry.Keys.CapitalName] as? String ?? "")")
                            .font(Font.footnote)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        let radians = country.getGeoRadians()
                        
                        viewModel.location = MaplyCoordinateMake(Float(radians[0]), Float(radians[1]))
                        highlightedCountry = country
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "location.circle")
                            .renderingMode(.original)
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle(Text("Search"))
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                }
            }
        }
        .searchable(text: $searchText)
        .onAppear {
            viewModel.fetchAllCountries()
        }
    }
    
    var searchResults: [FCCountry] {
        if searchText.isEmpty {
            return viewModel.countries
        } else {
            return viewModel.countries.filter { ($0.name ?? "").contains(searchText) }
        }
    }
}

struct MapSearchView_Previews: PreviewProvider {
    static var previews: some View {
        MapSearchView(highlightedCountry: .constant(nil))
            .environmentObject(MapViewModel())
    }
}
