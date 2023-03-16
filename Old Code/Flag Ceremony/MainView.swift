//
//  MainView.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 6/27/20.
//  Copyright © 2020 Jovit Royeca. All rights reserved.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView{
            NavigationView {
                
                MapView().navigationBarItems(trailing:
                    HStack {
                        Image("splash screen")
                            .resizable()
                            .foregroundColor(.white)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 40, alignment: .center)
                            .padding(UIScreen.main.bounds.size.width/4+30)
                        Button(action: {}) {
                            Image(systemName: "magnifyingglass")
                        }
                    })
                
            }.tabItem {
                Image(systemName: "map")
                Text("Map")
            }
            
            NavigationView {
                GlobeView().navigationBarItems(trailing:
                    Button(action: {}) {
                        Image(systemName: "magnifyingglass")
                    })
            }.tabItem {
                Image(systemName: "globe")
                Text("Globe")
            }
            
            NavigationView {
                ChartsView()
            }.tabItem {
                Image(systemName: "list.number")
                Text("Charts")
            }
            
            NavigationView {
                AccountView().navigationBarItems(trailing:
                    Button(action: {}) {
                        Text("Login")
                    })
            }.tabItem {
                Image(systemName: "person")
                Text("Account")
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
