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
    @IBOutlet weak var fitMarkersButton: UIButton!

    private var restConnector: RestConnector = RestConnector()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            if let backgroundView = textfield.subviews.first {
                backgroundView.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.7)
                backgroundView.layer.cornerRadius = 10
                backgroundView.clipsToBounds = true
            }
        }

        fitMarkersButton.layer.cornerRadius = 20

        mapView.register(PlaceMarkerView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.showsUserLocation = false
    }

    @IBAction func onFitAll(_ sender: Any) {

        var mapRect = MKMapRectNull
        for annotation in mapView.annotations {
            let marker = MKMapPointForCoordinate(annotation.coordinate)
            let pointRect = MKMapRectMake(marker.x, marker.y, 1, 1)

            mapRect = MKMapRectUnion(mapRect, pointRect)
        }
       mapView.setVisibleMapRect(mapRect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
    }

    func showFitButton(_ show: Bool) {
        if show {
            DispatchQueue.main.async {
                self.fitMarkersButton.isHidden = false
            }
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.fitMarkersButton.isHidden = true
            })
        }
    }

    func loadPoints(searchTerm: String) {

        restConnector.getPlaces(search: searchTerm, errorHandler: errorHandler, succesHandler: successHandler)
        DispatchQueue.main.async {
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
    }

    func errorHandler(_ error: String?) {
        print(error ?? "some error")
    }

    func successHandler(_ places: [PlaceModel]) {
        if places.isEmpty {
            print("no results")
        } else {
            for place in places where place.coordinates != nil && place.lifeSpan.lifeTime > 0 {
                    addAnnotation(object: place)
            }
        }
    }

    func addAnnotation(object: PlaceModel) {

        let place = PlaceMarker(id: object.id,
                                title: object.name!,
                                lifeSpan: object.lifeSpan.lifeTime,
                                locationType: (object.type?.rawValue ?? PlaceTypeEnum.other.rawValue),
                                coordinate: CLLocationCoordinate2D(latitude: object.coordinates!.latitude,
                                                                   longitude: object.coordinates!.longitude))

            DispatchQueue.main.async {
                self.mapView.addAnnotation(place)
                place.startLife(self)
            }
            showFitButton(true)
    }

    func removeAnnotation(_ marker: PlaceMarker) {
        DispatchQueue.main.async {
            self.mapView.removeAnnotation(marker)
        }
        if mapView.annotations.count <= 1 {
            showFitButton(false)
        }
    }
}

extension ViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange: String) {
        if textDidChange == "" {
            self.view.endEditing(true)
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        loadPoints(searchTerm: searchBar.text!)
        self.view.endEditing(true)
    }
}

extension ViewController: AnnotationChangeDelegate {
    func remove(marker: PlaceMarker) {
        removeAnnotation(marker)
    }
}
