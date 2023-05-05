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
            return "CountryInfoView_anthem".localized
        case .flag:
            return "CountryInfoView_flag".localized
        case .country:
            return "CountryInfoView_country".localized
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
            Text(viewModel.formatLong(text: viewModel.anthem?.info ?? ""))
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
                Text("CountryInfoView_capital".localized)
                Spacer()
                Text("\(viewModel.country?.capital?["Name"] as? String ?? "")")
            }
            HStack {
                Text("CountryInfoView_telephone_prefix".localized)
                Spacer()
                Text("\(viewModel.country?.telPref ?? "")")
            }
            Section(header: Text("CountryInfoView_country_codes".localized)) {
                HStack {
                    Text("CountryInfoView_fifs".localized)
                    Spacer()
                    Text("\(viewModel.country?.countryCodes?["fips"] as? String ?? "")")
                }
                HStack {
                    Text("CountryInfoView_iso2".localized)
                    Spacer()
                    Text("\(viewModel.country?.countryCodes?["iso2"] as? String ?? "")")
                }
                HStack {
                    Text("CountryInfoView_iso3".localized)
                    Spacer()
                    Text("\(viewModel.country?.countryCodes?["iso3"] as? String ?? "")")
                }
                HStack {
                    Text("CountryInfoView_ison".localized)
                    if let ison = viewModel.country?.countryCodes?["isoN"] as? Int {
                        Spacer()
                        Text("\(ison)")
                    }
                }
                HStack {
                    Text("CountryInfoView_tld".localized)
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
            .task {
                await viewModel.fetchData()
            }
        }
    }
}
