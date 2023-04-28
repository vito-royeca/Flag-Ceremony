//
//  MapView.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 6/27/20.
//

import SwiftUI
import WhirlyGlobe

struct MapViewVC: View {
    @EnvironmentObject var viewModel: MapViewModel
    @State var selectedCountry: FCCountry? = nil
    @State var highlightedCountry: FCCountry? = nil
    @State var latitude = DefaultLocationLatitude
    @State var longitude = DefaultLocationLongitude
    @State private var isShowingSearch = false

    var body: some View {
        MapView(selectedCountry: $selectedCountry,
                highlightedCountry: $highlightedCountry,
                latitude: $latitude,
                longitude: $longitude)
            .navigationTitle("MapViewVC_map".localized)
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
                latitude = viewModel.latitude
                longitude = viewModel.longitude
                highlightedCountry = viewModel.highlightedCountry
                
                // This is used for screenshots
                #if targetEnvironment(simulator)
                let environment = ProcessInfo.processInfo.environment
                if environment["isUITest"] != nil {
                    if selectedCountry == nil {
                        selectedCountry = FCCountry(key: MapViewModel.defaultCountryID, dict: [:])
                    }
                }
                #endif
            }
            .onDisappear {
                viewModel.latitude = latitude
                viewModel.longitude = longitude
                viewModel.highlightedCountry = highlightedCountry
            }
    }
}

struct MapView: UIViewControllerRepresentable {
    public typealias UIViewControllerType = GeographicViewController

    @EnvironmentObject var viewModel: MapViewModel
    @Binding var selectedCountry: FCCountry?
    @Binding var highlightedCountry: FCCountry?
    @Binding var latitude: Float
    @Binding var longitude: Float

    func makeUIViewController(context: Context) -> GeographicViewController {
        let mapVC = GeographicViewController(type: .map)
        mapVC.map?.delegate = context.coordinator
        
        return mapVC
    }

    func updateUIViewController(_ uiViewController: GeographicViewController, context: Context) {
        uiViewController.relocateTo(latitude: viewModel.latitude,
                                    longitude: viewModel.longitude)
        uiViewController.add(countries: viewModel.countries.filter({ $0.id != highlightedCountry?.id }),
                             highlighted: highlightedCountry)
    }
    
    func makeCoordinator() -> MapView.Coordinator {
        return Coordinator(self)
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        let country = FCCountry(key: MapViewModel.defaultCountryID, dict: [:])

        MapView(selectedCountry: .constant(country),
                highlightedCountry: .constant(nil),
                latitude: .constant(DefaultLocationLatitude),
                longitude: .constant(DefaultLocationLongitude))
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

        func maplyViewController(_ viewC: MaplyViewController,
                                 didStopMoving corners: UnsafeMutablePointer<MaplyCoordinate>,
                                 userMotion: Bool) {
            var position = MaplyCoordinate(x: 0, y: 0)
            var height = Float(0)

            viewC.getPosition(&position, height: &height)
            parent.latitude = position.y
            parent.longitude = position.x
        }
    }
}

