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
    let locationType: PlaceTypeEnum
    let lifeTime: Int
    let coordinate: CLLocationCoordinate2D

    private var timer: Timer?
    weak var delegate: AnnotationChangeDelegate?

    init(id: String, title: String, lifeSpan: Int, locationType: PlaceTypeEnum, coordinate: CLLocationCoordinate2D) {
        self.id = id
        self.title = title
        self.lifeTime = lifeSpan
        self.locationType = locationType
        self.coordinate = coordinate

        super.init()
    }

    var subtitle: String? {
        return locationType.rawValue
    }

    var imageName: String? {
        switch locationType {
        case .venue:
            return "venue"
        case .stadium:
            return "arena"
        case .religiousBuilding:
            return "chapel"
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

        self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(self.lifeTime), target: self, selector: #selector(self.selfDestruct), userInfo: nil, repeats: false)
    }
}
