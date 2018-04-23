//
//  ResponseModel.swift
//  MusicApp
//
//  Created by Mikołaj Bujok on 22.04.2018.
//  Copyright © 2018 Mikołaj. All rights reserved.
//

import Foundation

struct ResponseModel: Codable {

    var created: String?
    var count: Int
    var offset: Int
    var places: [PlaceModel]
}
