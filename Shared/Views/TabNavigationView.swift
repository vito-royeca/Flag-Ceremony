//
//  TabNavigationView.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 5/29/22.
//

import SwiftUI

import SwiftUI

struct TabNavigationView: View {
    enum TabItem {
        case map
        case globe
        case charts
        case account
    }
    
    @State private var selection: TabItem = .map
    @StateObject var geodata = Geodata()
    @StateObject var accountViewModel = AccountViewModel()
    
    var body: some View {
        TabView(selection: $selection) {
            NavigationView {
                MapViewVC()
            }
                .navigationViewStyle(.stack)
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")
                }
                .tag(TabItem.map)

            NavigationView {
                GlobeViewVC()
            }
                .navigationViewStyle(.stack)
                .tabItem {
                    Image(systemName: "globe")
                    Text("Globe")
                }
                .tag(TabItem.globe)
            
            NavigationView {
                ChartsView()
            }
                .navigationViewStyle(.stack)
                .tabItem {
                    Image(systemName: "chart.bar.doc.horizontal")
                    Text("Charts")
                }
                .tag(TabItem.charts)
            
            NavigationView {
                AccountView()
            }
                .navigationViewStyle(.stack)
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Account")
                }
                .tag(TabItem.account)
        }
            .environmentObject(geodata)
            .environmentObject(accountViewModel)
            .onAppear {
                geodata.fetchAllCountries()
                accountViewModel.fetchUserData()
            }
    }
}

struct TabNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        TabNavigationView()
    }
}
