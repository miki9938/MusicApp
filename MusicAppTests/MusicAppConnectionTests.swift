//
//  MusicAppConnectionTests.swift
//  MusicAppTests
//
//  Created by Mikołaj Bujok on 23.04.2018.
//  Copyright © 2018 Mikołaj. All rights reserved.
//

import XCTest
@testable import MusicApp

class MusicAppConnectionTests: XCTestCase {
    var connector: RestConnector!

    override func setUp() {
        super.setUp()
        connector = RestConnector()
    }

    override func tearDown() {
        connector = nil
        super.tearDown()
    }

    func testUrlFormatting() {

        var urlComponents = URLComponents()

        urlComponents.scheme = "https"
        urlComponents.host = "musicbrainz.org"
        urlComponents.path = "/ws/2/place"
        let query: String = String(format: "%@ AND begin:[%@ TO *]", "warsaw", String(1990))
        urlComponents.queryItems = [URLQueryItem(name: "query", value: query),
                                    URLQueryItem(name: "limit", value: String(1)),
                                    URLQueryItem(name: "offset", value: String(0))]

        let promise = expectation(description: "Form url")
        guard let url = urlComponents.url else { fatalError("Could not create URL from components")}

        XCTAssertTrue(url.absoluteString == "https://musicbrainz.org/ws/2/place?query=warsaw%20AND%20begin:%5B1990%20TO%20*%5D&limit=1&offset=0")
        promise.fulfill()
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testMusicPlaceData() {
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
        waitForExpectations(timeout: 15, handler: nil)
    }
}
