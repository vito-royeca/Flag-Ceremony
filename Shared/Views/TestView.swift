//
//  TestView.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 3/18/23.
//

import SwiftUI
import AVKit

struct TestView: View {
    @State var query: String = ""

      var body: some View {
        NavigationView {
          SearchableView()
        }.searchable(text: .constant("Search"))
      }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}

struct SearchableView: View {
  @Environment(\.isSearching) var isSearching

  var body: some View {
    if isSearching {
      Text("Searching!")
    } else {
      Text("Not searching.")
    }
  }
}
