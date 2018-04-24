//
//  MapViewController.swift
//  MusicApp
//
//  Created by Mikołaj Bujok on 21.04.2018.
//  Copyright © 2018 Mikołaj. All rights reserved.
//

import MapKit
import UIKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var fitMarkersButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!

    private var restConnector: RestConnector = RestConnector()

    override func viewDidLoad() {
        super.viewDidLoad()

        //Add custom layout for views
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            if let backgroundView = textfield.subviews.first {
                backgroundView.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.85)
                backgroundView.layer.cornerRadius = 10
                backgroundView.clipsToBounds = true
            }
        }

        let blur = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.prominent))
        blur.frame = fitMarkersButton.bounds
        blur.isUserInteractionEnabled = false
        blur.layer.cornerRadius = 15
        blur.clipsToBounds = true
        fitMarkersButton.layer.cornerRadius = 15
        fitMarkersButton.insertSubview(blur, at: 0)

        mapView.register(PlaceMarkerView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
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

    /**
     Shows or hides "Fit all markers" button
     - parameter show: Bool inicating desired isHidden state
     */
    func showFitButton(_ show: Bool) {
        if show {
            DispatchQueue.main.async {
                if self.fitMarkersButton.isHidden {
                    self.fitMarkersButton.alpha = 0
                    self.fitMarkersButton.isHidden = false
                    UIView.animate(withDuration: 0.4,
                                   delay: 0.0,
                                   options: UIViewAnimationOptions.curveEaseIn,
                                   animations: {
                                    self.fitMarkersButton.alpha = 1.0
                    }, completion: nil)
                }

            }
        } else {
            fitMarkersButton.isHidden = false
            UIView.animate(withDuration: 0.4,
                           delay: 0.0,
                           options: UIViewAnimationOptions.curveEaseIn,
                           animations: {
                            self.fitMarkersButton.alpha = 0.0
            }, completion: {_ in self.fitMarkersButton.isHidden = true
                self.fitMarkersButton.alpha = 1
            })
        }
    }

    func showError(_ error: String) {
        DispatchQueue.main.async {
            self.errorLabel.text = error
            self.errorLabel.isHidden = false
        }
    }

    /**
     Requests via restConnector music places by search term
     - parameter searchTerm: String search term for API query
     */
    func loadPoints(searchTerm: String) {

        restConnector.getPlaces(searchTerm: searchTerm, succesHandler: loadSuccessHandler, errorHandler: { error in self.showError(error) })
        DispatchQueue.main.async {
            self.errorLabel.isHidden = true
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
    }

    /**
     Success handler for rest connector's getPlaces func.
     - parameter places: An array of received places
     */
    func loadSuccessHandler(_ places: [PlaceModel]) {
        if places.isEmpty {
            showError("No results")
        } else {
            for place in places where place.coordinates != nil && place.lifeSpan.lifeTime > 0 {
                    addPlaceToMap(place)
            }
        }
    }

    /**
     Adds and annotation to map
     - parameter place: A place model to be added
     */
    func addPlaceToMap(_ place: PlaceModel) {

        let place = PlaceMarker(id: place.id,
                                title: place.name!,
                                lifeSpan: place.lifeSpan.lifeTime,
                                locationType: (place.type ?? PlaceTypeEnum.other),
                                coordinate: CLLocationCoordinate2D(latitude: place.coordinates!.latitude,
                                                                   longitude: place.coordinates!.longitude))

            DispatchQueue.main.async {
                self.mapView.addAnnotation(place)
                place.startLife(self)
            }
            showFitButton(true)
    }

    /**
     Removes indicated annotation from map
     - parameter marker: A place marker to be removed
     */
    func removeAnnotation(_ marker: PlaceMarker) {
        DispatchQueue.main.async {
            self.mapView.removeAnnotation(marker)
        }
        if mapView.annotations.count <= 1 {
            showFitButton(false)
        }
    }
}

extension MapViewController: UISearchBarDelegate {

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

extension MapViewController: AnnotationChangeDelegate {

    /**
     Removes indicated annotation from map
     - parameter marker: A place marker to be removed
     */
    func remove(marker: PlaceMarker) {
        removeAnnotation(marker)
    }
}
