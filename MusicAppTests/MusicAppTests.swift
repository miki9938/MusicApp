//
//  MusicAppTests.swift
//  MusicAppTests
//
//  Created by Mikołaj Bujok on 21.04.2018.
//  Copyright © 2018 Mikołaj. All rights reserved.
//

import XCTest
@testable import MusicApp

class MusicAppTests: XCTestCase {

    var viewController: ViewController!

    override func setUp() {
        super.setUp()

        viewController = ViewController()
    }

    override func tearDown() {
        viewController = nil
        super.tearDown()
    }

    func testJsonDecoder() {

    }

}
