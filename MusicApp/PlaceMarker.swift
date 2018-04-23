//
//  PlaceMarker.swift
//  MusicApp
//
//  Created by Mikołaj Bujok on 22.04.2018.
//  Copyright © 2018 Mikołaj. All rights reserved.
//

import Foundation
import MapKit

protocol AnnotationChangeDelegate: class {
    func remove(marker: PlaceMarker)
}

class PlaceMarker: NSObject, MKAnnotation {

    let id: String
    let title: String?
    let locationType: String
    let lifeSpan: Int
    let coordinate: CLLocationCoordinate2D

    private var timer: Timer?

    weak var delegate: AnnotationChangeDelegate?

    init(id: String, title: String, lifeSpan: Int, locationType: String, coordinate: CLLocationCoordinate2D) {
        self.id = id
        self.title = title
        self.lifeSpan = lifeSpan
        self.locationType = locationType
        self.coordinate = coordinate

        super.init()
    }

    var subtitle: String? {
        return locationType
    }

    var imageName: String?  {
        switch locationType {
        case "Venue":
            return "venue"
        case "Stadium":
            return "stadium"
        case "Studio":
            return "note"
        default:
            return "music"
        }
    }

    @objc func selfDestruct() {
        if delegate != nil {
            delegate!.remove(marker: self)
        }
    }

    func startLife(_ delegate: AnnotationChangeDelegate?) {
        if delegate != nil {
            self.delegate = delegate
        }

        self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(self.lifeSpan), target: self, selector: #selector(self.selfDestruct), userInfo: nil, repeats: false)
    }

    func resetLife() {
        self.timer?.invalidate()
        self.startLife(nil)
    }
}
