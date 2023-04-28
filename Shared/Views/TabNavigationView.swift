//
//  TabNavigationView.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 5/29/22.
//

import SwiftUI
import WhirlyGlobe

struct TabNavigationView: View {
    enum TabItem {
        case map
        case globe
        case charts
        case account
    }
    
    @EnvironmentObject var mapViewModel: MapViewModel
    @StateObject var accountViewModel = AccountViewModel()
    @State private var selection: TabItem = .map
    
    var body: some View {
        tabView
            .environmentObject(mapViewModel)
            .environmentObject(accountViewModel)
            .onAppear {
                mapViewModel.fetchAllCountries()
                mapViewModel.requestLocation()
            }
            .task {
                do {
                    try await accountViewModel.fetchUserData()
                } catch let error {
                    
                }
            }
    }
    
    var tabView: some View {
        TabView(selection: $selection) {
            NavigationView {
                MapViewVC()
            }
                .navigationViewStyle(.stack)
                .tabItem {
                    Image(systemName: "map")
                    Text("TabNavigationView_map".localized)
                }
                .tag(TabItem.map)
            
            NavigationView {
                GlobeViewVC()
            }
                .navigationViewStyle(.stack)
                .tabItem {
                    Image(systemName: "globe")
                    Text("TabNavigationView_globe".localized)
                }
                .tag(TabItem.globe)
            
            NavigationView {
                ChartsView()
            }
                .navigationViewStyle(.stack)
                .tabItem {
                    Image(systemName: "chart.bar.doc.horizontal")
                    Text("TabNavigationView_charts".localized)
                }
                .tag(TabItem.charts)
            
            NavigationView {
                AccountView()
            }
                .navigationViewStyle(.stack)
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("TabNavigationView_account".localized)
                }
                .tag(TabItem.account)
        }
    }
}

struct TabNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        TabNavigationView()
    }
}
