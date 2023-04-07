//
//  MapView.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 6/27/20.
//  Copyright © 2020 Jovit Royeca. All rights reserved.
//

import SwiftUI
import WhirlyGlobe

struct MapViewVC: View {
    @EnvironmentObject var viewModel: MapViewModel
    @State var selectedCountry: FCCountry? = nil
    @State var highlightedCountry: FCCountry? = nil
    @State var location = MapViewModel.defaultLocation
    @State private var isShowingSearch = false

    var body: some View {
        MapView(selectedCountry: $selectedCountry,
                highlightedCountry: $highlightedCountry,
                location: $location)
            .navigationTitle("Map")
            .sheet(item: $selectedCountry) { selectedCountry in
                NavigationView {
                    CountryView(id: selectedCountry.id, isAutoPlay: true)
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
                highlightedCountry = viewModel.highleightedCountry
            }
            .onDisappear {
                viewModel.location = location
                viewModel.highleightedCountry = highlightedCountry
            }
    }
}

struct MapView: UIViewControllerRepresentable {
    public typealias UIViewControllerType = GeographicViewController

    @EnvironmentObject var viewModel: MapViewModel
    @Binding var selectedCountry: FCCountry?
    @Binding var highlightedCountry: FCCountry?
    @Binding var location: MaplyCoordinate

    func makeUIViewController(context: Context) -> GeographicViewController {
        let mapVC = GeographicViewController(mbTilesFetcher: viewModel.mbTilesFetcher, type: .map)
        mapVC.map?.delegate = context.coordinator
        
        return mapVC
    }

    func updateUIViewController(_ uiViewController: GeographicViewController, context: Context) {
        uiViewController.relocate(to: viewModel.location)
        uiViewController.add(countries: viewModel.countries.filter({ $0.id != highlightedCountry?.id }),
                             highlighted: highlightedCountry)
    }
    
    func makeCoordinator() -> MapView.Coordinator {
        return Coordinator(self)
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        let country = FCCountry(key: "PH", dict: [:])

        MapView(selectedCountry: .constant(country),
                highlightedCountry: .constant(nil),
                location: .constant(MapViewModel.defaultLocation))
           .environmentObject(MapViewModel())
    }
}

extension MapView {
    class Coordinator: NSObject, MaplyViewControllerDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        func maplyViewController(_ viewC: MaplyViewController, didSelect selectedObj: NSObject) {
            if let selectedObject = selectedObj as? MaplyScreenLabel {
                let country = selectedObject.userObject as? FCCountry
                parent.selectedCountry = country
            }
        }

        func maplyViewController(_ viewC: MaplyViewController, didStopMoving corners: UnsafeMutablePointer<MaplyCoordinate>, userMotion: Bool) {
            var position = MaplyCoordinate(x: 0, y: 0)
            var height = Float(0)

            viewC.getPosition(&position, height: &height)
            parent.location = position
        }
    }
}

