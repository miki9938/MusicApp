//
//  PlaceMarkerView.swift
//  MusicApp
//
//  Created by Mikołaj Bujok on 23.04.2018.
//  Copyright © 2018 Mikołaj. All rights reserved.
//

import Foundation
import MapKit

class PlaceMarkerView: MKMarkerAnnotationView {

    // Custom place marker view, setting marker image
    override var annotation: MKAnnotation? {
        willSet {
            guard let placeMarker = newValue as? PlaceMarker else { return }

            if let imageName = placeMarker.imageName {
                glyphImage = UIImage(named: imageName)
            } else {
                glyphImage = nil
            }
        }
    }
}
