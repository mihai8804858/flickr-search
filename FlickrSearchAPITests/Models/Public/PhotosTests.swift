import XCTest
@testable import FlickrSearchAPI

final class PhotosTests: XCTestCase {
    func testPhotoCanBeSuccessfullyDecoded() {
        let data =
        """
        {
          "photos": {
            "page": 1,
            "pages": 1695,
            "perpage": 100,
            "total": "169480",
            "photo": [
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
            ]
          }
        }
        """.data(using: .utf8)!
        let decode = {
            try JSONDecoder().decode(Photos.self, from: data)
        }
        let expectedModel = Photos(page: PhotosPage(
            pageNumber: 1,
            totalPagesCount: 1695,
            perPageCount: 100,
            totalPhotosCount: 169480,
            photos: [
                Photo(
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
            ]
        ))
        XCTAssertNoThrow(decode)
        XCTAssertEqual(try decode(), expectedModel)
    }
}
