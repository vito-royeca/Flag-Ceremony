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
        case cards
    }
    
    @State private var selection: TabItem = .map
    
    var body: some View {
        TabView(selection: $selection) {
            NavigationView {
                MapView()
            }
                .navigationViewStyle(.stack)
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")
                }
                .tag(TabItem.map)

            NavigationView {
                GlobeView()
            }
                .navigationViewStyle(.stack)
                .tabItem {
                    Image(systemName: "globe")
                    Text("Globe")
                }
                .tag(TabItem.globe)
            
        }
    }
}

struct TabNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        TabNavigationView()
    }
}
