//
//  ContentView.swift
//  Shared
//
//  Created by Vito Royeca on 5/28/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
//        #if os(iOS)
//        if horizontalSizeClass == .compact {
            TabNavigationView()
                .environment(\.horizontalSizeClass, horizontalSizeClass)
//        } else {
//            SideNavigationView()
//                .environment(\.horizontalSizeClass, horizontalSizeClass)
//        }
//        #else
//        SideNavigationView()
//        #endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
