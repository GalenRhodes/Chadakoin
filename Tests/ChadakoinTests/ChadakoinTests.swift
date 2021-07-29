/*****************************************************************************************************************************//**
 *     PROJECT: Chadakoin
 *    FILENAME: ChadakoinTests.swift
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: July 19, 2021
 *
  * Permission to use, copy, modify, and distribute this software for any purpose with or without fee is hereby granted, provided
 * that the above copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR
 * CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
 * NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *//*****************************************************************************************************************************/

import XCTest
import Foundation
import CoreFoundation
@testable import Chadakoin

class ChadakoinTests: XCTestCase {

    override func setUpWithError() throws {}

    override func tearDownWithError() throws {}

    func testResponseCodeMessage() throws {
        let codes: [ClosedRange<Int>] = [
            100 ... 101,
            200 ... 299,
            300 ... 307,
            400 ... 417,
            500 ... 505,
        ]
        for cr in codes {
            for c in cr {
                print("\(c) - \"\(HTTPURLResponse.localizedString(forStatusCode: c).capitalized)\"")
            }
        }
    }

    func testPropertiesFetch() throws {
        let urls: [String] = [ "https://www.w3.org/2001/XMLSchema.xsd" ]

        for strUrl in urls {
            do {
                guard let url = URL(string: strUrl) else { throw URLISErrors.General(description: "Malformed URL.") }
                let inputStream = try InputStream.getInputStream(url: url)
                inputStream.open()
                defer { inputStream.close() }

                print("      Cookies: \(inputStream.property(forKey: .httpCookiesKey) ?? "")")
                print("      Headers: \(inputStream.property(forKey: .httpHeadersKey) ?? "")")
                print("  Status Code: \(inputStream.property(forKey: .httpStatusCodeKey) ?? "")")
                print("  Status Text: \(inputStream.property(forKey: .httpStatusTextKey) ?? "")")
                print("    MIME Type: \(inputStream.property(forKey: .mimeTypeKey) ?? "")")
                print("Text Encoding: \(inputStream.property(forKey: .textEncodingNameKey) ?? "")")
            }
            catch let e {
                XCTFail("\(e)")
            }
        }
    }

    func test001() throws {
        let urls: [String] = [ "https://www.w3.org/2001/XMLSchema.xsd" ]

        for strUrl in urls {
            do {
                guard let url = URL(string: strUrl) else { throw URLISErrors.General(description: "Malformed URL.") }
                let inputStream = try InputStream.getInputStream(url: url)

                print("      Cookies: \(inputStream.property(forKey: .httpCookiesKey) ?? "")")
                print("      Headers: \(inputStream.property(forKey: .httpHeadersKey) ?? "")")
                print("  Status Code: \(inputStream.property(forKey: .httpStatusCodeKey) ?? "")")
                print("  Status Text: \(inputStream.property(forKey: .httpStatusTextKey) ?? "")")
                print("    MIME Type: \(inputStream.property(forKey: .mimeTypeKey) ?? "")")
                print("Text Encoding: \(inputStream.property(forKey: .textEncodingNameKey) ?? "")")
                print("")

                guard let str = String(fromInputStream: inputStream, encoding: .utf8) else { throw StreamError.UnknownError(description: "Could not read data.") }
                print(str)
            }
            catch let e {
                XCTFail("\(e)")
            }
        }
    }

//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
}
