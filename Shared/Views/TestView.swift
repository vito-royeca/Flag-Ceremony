//
//  TestView.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 3/18/23.
//

import SwiftUI

struct TestView: View {
    let colors: [Color] = [.red, .green, .yellow, .blue]
        
        var columns: [GridItem] =
            Array(repeating: .init(.flexible(), alignment: .center), count: 3)
        
        var body: some View {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(0...100, id: \.self) { index in
                        Text("Tab \(index)")
                            .frame(width: 110, height: 200)
                            .background(colors[index % colors.count])
                        .cornerRadius(8)
                    }
                }
            }
        }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
