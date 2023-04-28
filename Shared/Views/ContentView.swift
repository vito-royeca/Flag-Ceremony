//
//  ContentView.swift
//  Flag Ceremony (iOS)
//
//  Created by Vito Royeca on 4/27/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabNavigationView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(MapViewModel())
    }
}
