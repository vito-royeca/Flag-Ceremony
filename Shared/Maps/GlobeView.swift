//
//  GlobeView.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 6/27/20.
//  Copyright © 2020 Jovit Royeca. All rights reserved.
//

import SwiftUI
import WhirlyGlobe

struct GlobeViewVC: View {
    @EnvironmentObject var viewModel: MapViewModel
    @State var selectedCountry: FCCountry? = nil
    @State var highlightedCountry: FCCountry? = nil
    @State var location = MapViewModel.defaultLocation
    @State private var isShowingSearch = false

    var body: some View {
        GlobeView(selectedCountry: $selectedCountry,
                  highlightedCountry: $highlightedCountry,
                  location: $location)
            .navigationTitle("Globe")
            .sheet(item: $selectedCountry) { selectedCountry in
                NavigationView {
                    #if targetEnvironment(simulator)
                    CountryView(id: selectedCountry.id, isAutoPlay: false)
                    #else
                    CountryView(id: selectedCountry.id, isAutoPlay: true)
                    #endif
                }
            }
            .sheet(isPresented: $isShowingSearch, content: {
                NavigationView {
                    MapSearchView(highlightedCountry: $highlightedCountry)
                        .environmentObject(viewModel)
                }
            })
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: {
                        isShowingSearch.toggle()
                    }) {
                        Image(systemName: "magnifyingglass")
                    }
                }
            }
            .onAppear {
                location = viewModel.location
                highlightedCountry = viewModel.highlightedCountry
            }
            .onDisappear {
                viewModel.location = location
                viewModel.highlightedCountry = highlightedCountry
            }
    }
}

struct GlobeView: UIViewControllerRepresentable {
    public typealias UIViewControllerType = GeographicViewController

    @EnvironmentObject var viewModel: MapViewModel
    @Binding var selectedCountry: FCCountry?
    @Binding var highlightedCountry: FCCountry?
    @Binding var location: MaplyCoordinate

    func makeUIViewController(context: Context) -> GeographicViewController {
        let globeVC = GeographicViewController(mbTilesFetcher: viewModel.mbTilesFetcher, type: .globe)
        globeVC.globe?.delegate = context.coordinator
        
        return globeVC
    }

    func updateUIViewController(_ uiViewController: GeographicViewController, context: Context) {
        uiViewController.relocate(to: viewModel.location)
        uiViewController.add(countries: viewModel.countries.filter({ $0.id != highlightedCountry?.id }),
                             highlighted: highlightedCountry)
    }
    
    func makeCoordinator() -> GlobeView.Coordinator {
        return Coordinator(self)
    }
}


struct GlobeView_Previews: PreviewProvider {
    static var previews: some View {
        let country = FCCountry(key: MapViewModel.defaultCountryID, dict: [:])

        GlobeView(selectedCountry: .constant(country),
                  highlightedCountry: .constant(nil),
                  location: .constant(MapViewModel.defaultLocation))
           .environmentObject(MapViewModel())
    }
}

extension GlobeView {
    class Coordinator: NSObject, WhirlyGlobeViewControllerDelegate {
        var parent: GlobeView

        init(_ parent: GlobeView) {
            self.parent = parent
        }

        func globeViewController(_ viewC: WhirlyGlobeViewController, didSelect selectedObj: NSObject) {
            if let selectedObject = selectedObj as? MaplyScreenLabel {
                let country = selectedObject.userObject as? FCCountry
                parent.selectedCountry = country
            }
        }

        func globeViewController(_ viewC: WhirlyGlobeViewController, didStopMoving corners: UnsafeMutablePointer<MaplyCoordinate>, userMotion: Bool) {
            var position = MaplyCoordinate(x: 0, y: 0)
            var height = Float(0)

            viewC.getPosition(&position, height: &height)
            parent.location = position
        }
    }
}

