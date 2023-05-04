//
//  GlobeView.swift
//  Flag Ceremony
//
//  Created by Vito Royeca on 6/27/20.
//

import SwiftUI
import WhirlyGlobe

struct GlobeViewVC: View {
    @EnvironmentObject var viewModel: MapViewModel
    @State private var isShowingSearch = false

    var body: some View {
        GlobeView()
            .navigationTitle("GlobeViewVC_globe".localized)
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
    }
}

struct GlobeView: UIViewControllerRepresentable {
    public typealias UIViewControllerType = GeographicViewController

    @EnvironmentObject var viewModel: MapViewModel

    func makeUIViewController(context: Context) -> GeographicViewController {
        let globeVC = GeographicViewController(type: .globe)
        globeVC.globe?.delegate = context.coordinator
        return globeVC
    }

    func updateUIViewController(_ uiViewController: GeographicViewController, context: Context) {
        uiViewController.relocateTo(longitude: viewModel.longitude,
                                    latitude: viewModel.latitude)
        uiViewController.add(countries: viewModel.countries.filter({ $0.id != viewModel.highlightedCountry?.id }),
                             highlighted: viewModel.highlightedCountry)
    }
    
    func makeCoordinator() -> GlobeView.Coordinator {
        return Coordinator(self)
    }
}


struct GlobeView_Previews: PreviewProvider {
    static var previews: some View {
        GlobeView()
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
                parent.viewModel.selectedCountry = country
            }
        }

        func globeViewController(_ viewC: WhirlyGlobeViewController,
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

