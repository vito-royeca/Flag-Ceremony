//
//  TestView.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 3/18/23.
//

import SwiftUI

struct TestView: View {
    init() {
//        UITabBar.appearance().isTranslucent = true
//        UITabBar.appearance().unselectedItemTintColor = UIColor(Color.primary)
//        UITabBar.appearance().barTintColor = .white
//        UITabBar.appearance().tintColor = .white
        UITabBar.appearance().backgroundColor = .white
    }

    var body: some View {
//        if #available(iOS 16, *) {
            TabView {
                Group {
                    Text("Home")
                        .tabItem {
                            Image(systemName: "house")
                            Text("Home")
                        }
                    Text("Search")
                        .tabItem {
                            Label("Search", systemImage: "magnifyingglass")
                        }
                        .foregroundColor(.white)
                    Text("Notification")
                        .tabItem {
                            Label("Notification", systemImage: "bell")
                        }
                    Text("Settings")
                        .tabItem {
                            Label("Settings", systemImage: "gearshape")
                        }
                }
//                .toolbar(.visible, for: .tabBar)
//                .toolbarBackground(Color.blue, for: .tabBar)
//                .edgesIgnoringSafeArea(.top)
                
            }
//        } else {
//            EmptyView()
//        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
