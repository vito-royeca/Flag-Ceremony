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
    @State private var isShowingSearch = false

    var body: some View {
        MapView()
            .navigationTitle("MapViewVC_map".localized)
            .sheet(item: $viewModel.selectedCountry) { selectedCountry in
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
                    MapSearchView()
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
                // This is used for screenshots
                #if targetEnvironment(simulator)
                let environment = ProcessInfo.processInfo.environment
                if environment["isUITest"] != nil {
                    if viewModel.selectedCountry == nil {
                        viewModel.selectedCountry = FCCountry(key: MapViewModel.defaultCountryID, dict: [:])
                    }
                }
                #endif
            }
    }
}

struct MapView: UIViewControllerRepresentable {
    public typealias UIViewControllerType = GeographicViewController

    @EnvironmentObject var viewModel: MapViewModel

    func makeUIViewController(context: Context) -> GeographicViewController {
        let mapVC = GeographicViewController(type: .map)
        mapVC.map?.delegate = context.coordinator
        return mapVC
    }

    func updateUIViewController(_ uiViewController: GeographicViewController, context: Context) {
        uiViewController.relocateTo(longitude: viewModel.longitude,
                                    latitude: viewModel.latitude)
        uiViewController.add(countries: viewModel.countries.filter({ $0.id != viewModel.highlightedCountry?.id }),
                             highlighted: viewModel.highlightedCountry)
    }
    
    func makeCoordinator() -> MapView.Coordinator {
        return Coordinator(self)
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
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
                parent.viewModel.selectedCountry = country
            }
        }

        func maplyViewController(_ viewC: MaplyViewController,
                                 didStopMoving corners: UnsafeMutablePointer<MaplyCoordinate>,
                                 userMotion: Bool) {
            guard userMotion else {
                return
            }

            var position = MaplyCoordinate(x: 0, y: 0)
            var height = Float(0)

            viewC.getPosition(&position, height: &height)
            parent.viewModel.longitude = position.x
            parent.viewModel.latitude = position.y
        }
    }
}

