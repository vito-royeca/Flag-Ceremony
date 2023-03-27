//
//  CountryInfoView.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 3/21/23.
//

import SwiftUI

enum CountryInfoTab: String, CaseIterable, Identifiable {
    case anthem, flag, country
    
    var id: String {
        return self.rawValue
    }
    
    var description: String {
        switch self {
        case .anthem:
            return "Anthem"
        case .flag:
            return "Flag"
        case .country:
            return "Country"
        }
    }
}

struct CountryInfoView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: CountryViewModel
    @State var tab: CountryInfoTab = .anthem

    var body: some View {
        VStack {
            switch tab {
            case .anthem:
                anthemView
            case .flag:
                flagView
            case .country:
                countryView
            }
        }
            .navigationTitle(viewModel.country?.displayName ?? "")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                    }
                }
        }
    }
    
    var tabView: some View {
        Picker("", selection: $tab) {
            ForEach(CountryInfoTab.allCases, id: \.id) { index in
                Text(index.description)
                    .tag(index)
            }
        }
            .pickerStyle(.segmented)
            .listRowSeparator(.hidden)
    }

    var anthemView: some View {
        List {
            tabView
            Text(viewModel.anthem?.info ?? "")
                .listRowSeparator(.hidden)
        }
            .listStyle(.plain)
    }

    var flagView: some View {
        List {
            tabView
            Text(viewModel.formatLong(text: viewModel.anthem?.flagInfo ?? ""))
                .listRowSeparator(.hidden)
        }
            .listStyle(.plain)
    }
    
    var countryView: some View {
        List {
            tabView
            HStack {
                Text("Capital")
                Spacer()
                Text("\(viewModel.country?.capital?["Name"] as? String ?? "")")
            }
            HStack {
                Text("Telephone Prefix")
                Spacer()
                Text("\(viewModel.country?.telPref ?? "")")
            }
            Section(header: Text("Country Codes")) {
                HStack {
                    Text("FIFS")
                    Spacer()
                    Text("\(viewModel.country?.countryCodes?["fips"] as? String ?? "")")
                }
                HStack {
                    Text("ISO 2")
                    Spacer()
                    Text("\(viewModel.country?.countryCodes?["iso2"] as? String ?? "")")
                }
                HStack {
                    Text("ISO 3")
                    Spacer()
                    Text("\(viewModel.country?.countryCodes?["iso3"] as? String ?? "")")
                }
                HStack {
                    Text("ISO N")
                    if let ison = viewModel.country?.countryCodes?["isoN"] as? Int {
                        Spacer()
                        Text("\(ison)")
                    }
                }
                HStack {
                    Text("TLD")
                    Spacer()
                    Text("\(viewModel.country?.countryCodes?["tld"] as? String ?? "")")
                }
            }
            Text(viewModel.formatLong(text: viewModel.anthem?.background ?? ""))
                .listRowSeparator(.hidden)
        }
            .listStyle(.plain)
    }
}

struct CountryInfoView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = CountryViewModel(id: "PH")
        
        NavigationView {
            CountryInfoView().environmentObject(viewModel)
                .onAppear {
                    viewModel.fetchData {}
                }
        }
    }
}
