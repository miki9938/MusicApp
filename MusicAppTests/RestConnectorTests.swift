//
//  MusicAppConnectionTests.swift
//  MusicAppTests
//
//  Created by Mikołaj Bujok on 23.04.2018.
//  Copyright © 2018 Mikołaj. All rights reserved.
//

import XCTest
@testable import MusicApp

class RestConnectorTests: XCTestCase {
    var connector: RestConnector!

    override func setUp() {
        super.setUp()
        connector = RestConnector()
    }

    override func tearDown() {
        connector = nil
        super.tearDown()
    }

    func testUrlCreation() {
        let url = connector.createUrl(searchTerm: "Warsaw", offset: 0)

        let promise = expectation(description: "Form correct url")
        let expectedUrl = String("https://musicbrainz.org/ws/2/place?query=Warsaw%20AND%20begin:%5B\(RestConnector.minimumYear)%20TO%20*%5D&limit=\(RestConnector.batchSize)&offset=0")

        XCTAssertTrue(url?.absoluteString == expectedUrl)
        promise.fulfill()
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testJsonParsing() {
        guard let url = URL(string: "https://musicbrainz.org/ws/2/place?query=warsaw%20AND%20begin:%5B1990%20TO%20*%5D&limit=1&offset=0") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        let promise = expectation(description: "Place query request")
        let session = URLSession(configuration: URLSessionConfiguration.default)
        session.dataTask(with: request) { data, _, _ in

            guard let data = data else { return }

            let decoder = JSONDecoder()
            do {
                let json = try decoder.decode(ResponseModel.self, from: data)

                XCTAssertTrue(json.offset == 0)
                XCTAssertTrue(json.places.count == 1)
                XCTAssertTrue(json.places[0].id == "828307df-fcb8-46f3-8479-13b38d459200")
                promise.fulfill()
            } catch let decoderError {
                print(decoderError.localizedDescription)
            }
            }.resume()
        waitForExpectations(timeout: 10, handler: nil)
    }

    // Testing if getPlaces() returns correct number of results (places)
    // As for writing this test there are 6 places that fits that query
    func testGetPlaces() {

        let promise = expectation(description: "Get places for selected query")
        connector.getPlaces(searchTerm: "Warsaw", succesHandler: { places in

            if RestConnector.batchSize >= 6 {
                XCTAssertTrue(places.count == 6)
            } else {
                XCTAssertTrue(places.count == RestConnector.batchSize)
            }
        }, errorHandler: { error in })

        promise.fulfill()
        waitForExpectations(timeout: 10, handler: nil)
    }
}
