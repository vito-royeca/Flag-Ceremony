//
//  MapSearchView.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 3/27/23.
//

import SwiftUI
import Collections
import WhirlyGlobe

struct MapSearchView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: MapViewModel
    @State private var searchText = ""
    @Binding var highlightedCountry: FCCountry?

    var body: some View {
        VStack {
            let dictionary = searchResults()
            let keys = dictionary.keys.sorted()
            
            ScrollViewReader { scrollProxy in
                ZStack {
                    List {
                        ForEach(keys, id:\.self) { key in
                            Section(header: Text(key)) {
                                ForEach(dictionary[key] ?? [], id: \.self) { country in
                                    MapSearchRowView(flag: country.emojiFlag,
                                                     country: country.name ?? "",
                                                     capital: country.capital?[FCCountry.Keys.CapitalName] as? String ?? "",
                                                     matching: searchText,
                                                     action: {
                                                        select(country: country)
                                                    })
                                }
                            }
                        }
                    }
                        .listStyle(.plain)

                    VStack {
                        ForEach(keys, id: \.self) { letter in
                            HStack {
                                Spacer()
                                Button(action: {
                                    withAnimation {
                                        scrollProxy.scrollTo(letter, anchor: .top)
                                    }
                                }, label: {
                                    Text(letter)
                                        .font(Font.footnote.monospacedDigit())
                                        .padding(.trailing, 7)
                                })
                            }
                        }
                    }
                    
                }
            }
        }
        .navigationTitle(Text("MapSearchView_search".localized))
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                    }
                }
            }
            .searchable(text: $searchText, prompt: "MapSearchView_country_or_capital".localized)
            .onAppear {
                viewModel.fetchAllCountries()
            }
    }
    
    func searchResults() -> [String: [FCCountry]] {
        var results = [String: [FCCountry]]()
        let countries = searchText.isEmpty ? viewModel.countries :
            viewModel.countries.filter { country in
                let text = searchText.lowercased()
                let name = (country.name ?? "").lowercased()
                let capital = (country.capital?[FCCountry.Keys.CapitalName] as? String ?? "").lowercased()
                
                if text.count == 1 {
                    return name.starts(with: text) || capital.starts(with: text)
                } else {
                    return name.contains(text) || capital.contains(text)
                }
            }
        
        for country in countries {
            if let name = country.name,
               !name.isEmpty {
                let key = String(name.prefix(1))
                
                var array = results[key] ?? [FCCountry]()
                array.append(country)
                results[key] = array
            }
        }

        return results
    }
    
    func select(country: FCCountry) {
        let radians = country.getGeoRadians()
        
        viewModel.location = MaplyCoordinateMake(Float(radians[0]), Float(radians[1]))
        highlightedCountry = country
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Previews

struct MapSearchView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MapSearchView(highlightedCountry: .constant(nil))
                .environmentObject(MapViewModel())
        }
    }
}

// MARK: - MapSearchRowView

struct MapSearchRowView: View {
    let flag: String
    let country: String
    let capital: String
    let matching: String
    let action: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text(flag)
                    HighlightedText(country, matching: matching)
                }
                HStack {
                    Text("\("MapSearchView_capital".localized):")
                        .font(Font.footnote)
                    HighlightedText(capital, matching: matching)
                        .font(Font.footnote)
                }
            }

            Spacer()

            Button(action: action) {
                Image(systemName: "location.circle")
//                    .renderingMode(.original)
            }
        }
    }
}
