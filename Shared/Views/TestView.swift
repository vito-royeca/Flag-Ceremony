//
//  TestView.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 3/18/23.
//

import SwiftUI

struct TestView: View {
    @State private var showingWelcome = false
    @State var count = 0

    var body: some View {
        VStack {
            
            Button("Increment") {
                withAnimation(.spring(response: 2)) {
                    count += 1
                }
                
            }
            Spacer()
            Text("\(count)")
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
