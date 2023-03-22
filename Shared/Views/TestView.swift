//
//  TestView.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 3/18/23.
//

import SwiftUI
import AVKit

struct TestView: View {
    @State private var airPlayView = AirPlayView()

    var body: some View {
        VStack {
            // other views

            Button(action: {
                // other actions
                airPlayView.showAirPlayMenu()
            }) {
                HStack {
                    Text("Show AirPlay menu")
                    
                    Spacer()
                    
                    airPlayView
                        .frame(width: 32, height: 32)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}


