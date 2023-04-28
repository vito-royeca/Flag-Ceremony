//
//  ContentView.swift
//  Flag Ceremony Watch App
//
//  Created by Vito Royeca on 4/27/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        CountryListView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(MapViewModel())
    }
}
