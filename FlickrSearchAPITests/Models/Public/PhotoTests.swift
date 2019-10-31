import XCTest
@testable import FlickrSearchAPI

final class PhotoTests: XCTestCase {
    func testPhotoCanBeSuccessfullyDecoded() {
        let data =
        """
        {
          "id": "48989296253",
          "owner": "8740272@N04",
          "secret": "82251b8570",
          "server": "65535",
          "farm": 66,
          "title": "♦♦♦ Happy Halloween ♦♦♦",
          "ispublic": 1,
          "isfriend": 0,
          "isfamily": 0
        }
        """.data(using: .utf8)!
        let decode = {
            try JSONDecoder().decode(Photo.self, from: data)
        }
        let expectedModel = Photo(
            id: "48989296253",
            owner: "8740272@N04",
            secret: "82251b8570",
            server: "65535",
            farm: 66,
            title: "♦♦♦ Happy Halloween ♦♦♦",
            isPublic: true,
            isFriend: false,
            isFamily: false
        )
        XCTAssertNoThrow(decode)
        XCTAssertEqual(try decode(), expectedModel)
    }

    func testPhotoCanBuildSourceURL() {
        let photo = Photo(
            id: "48989296253",
            owner: "8740272@N04",
            secret: "82251b8570",
            server: "65535",
            farm: 66,
            title: "♦♦♦ Happy Halloween ♦♦♦",
            isPublic: true,
            isFriend: false,
            isFamily: false
        )
        let expectedURL = URL(string: "http://farm66.static.flickr.com/65535/48989296253_82251b8570.jpg")
        XCTAssertEqual(photo.sourceURL, expectedURL)
    }
}
