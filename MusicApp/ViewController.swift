//
//  ViewController.swift
//  MusicApp
//
//  Created by Mikołaj Bujok on 21.04.2018.
//  Copyright © 2018 Mikołaj. All rights reserved.
//

import MapKit
import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!

    var objects = [PlaceModel]()
    var restConnector: RestConnector = RestConnector()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        loadPoints(searchTerm: "")

        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            if let backgroundView = textfield.subviews.first {
                backgroundView.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.7)
                backgroundView.layer.cornerRadius = 10;
                backgroundView.clipsToBounds = true;
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func buttonTapped() {

    }

    func loadPoints(searchTerm: String) {

        restConnector.getPlaces(search: searchTerm, errorHandler: errorHandler, succesHandler: successHandler)


//        restConnector.getPosts() { (result) in
//            switch result {
//            case .success(let results):
//                self.objects.append(contentsOf: results.places)
//                //                for place in results.places {
//                //                    self.objects.append(contentsOf: r)
//                //                }
//                let initialLocation = CLLocation(latitude: Double(self.objects[0].coordinates.latitude)!, longitude: Double(self.objects[0].coordinates.longitude)!)
//
//                self.setMapToLocation(initialLocation)
//                print(results.offset)
//            case .failure(let error):
//                fatalError("error: \(error.localizedDescription)")
//            }
//        }
    }

    func errorHandler(_ error: String?) {
        print(error as Any)
    }

    func successHandler(_ places: [PlaceModel]) {
        if places.isEmpty {
            print("no results")
        } else {
        let initialLocation = CLLocation(latitude: Double(places[0].coordinates!.latitude)!,
                                         longitude: Double(places[0].coordinates!.longitude)!)
        self.setMapToLocation(initialLocation)

            for place in places {
                if place.coordinates != nil {
                    addAnnotation(object: place)
                }
            }
        }
    }

    func setMapToLocation(_ location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 2000, 2000)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    func addAnnotation(object: PlaceModel) {
        let place = PlaceMarker(title: object.name!,
                                lifeSpan: object.lifeSpan.beginYear,
                              locationType: object.type ?? "Other",
                              coordinate: CLLocationCoordinate2D(latitude: Double(object.coordinates!.latitude)!, longitude: Double(object.coordinates!.longitude)!))
        DispatchQueue.main.async {
            self.mapView.addAnnotation(place)
            place.startLife(self)
        }
    }

    func removeAnnotation(_ marker: PlaceMarker) {
        DispatchQueue.main.async {
            self.mapView.removeAnnotation(marker)
        }
    }

}

extension ViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange: String) {

//        filterContentFor(searchText: textDidChange)
        if textDidChange == "" {
            self.view.endEditing(true)
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        filterContentFor(searchText: searchBar.text!)
        loadPoints(searchTerm: searchBar.text!)
        self.view.endEditing(true)
    }

}

extension ViewController: AnnotationChangeDelegate {
    func remove(marker: PlaceMarker) {
        removeAnnotation(marker)
    }
}

//extension ViewController: UISearchResultsUpdating {
//    func updateSearchResults(for searchController: UISearchController) {
//
//        filterContentFor(searchText: searchController.searchBar.text!)
//    }
//}
