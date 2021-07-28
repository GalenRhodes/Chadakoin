/*****************************************************************************************************************************//**
 *     PROJECT: Chadakoin
 *    FILENAME: InputStream.swift
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

import Foundation
import CoreFoundation

extension InputStream {

    /*==========================================================================================================*/
    /// Create and return an InputStream that reads from a non-file URL.
    /// 
    /// - Parameters:
    ///   - url: The URL. If the URL's scheme is "file" then a normal InputStream is created and returned.
    ///   - options: The options for the remote URL InputStream.
    ///   - authenticate: The closure that will be used to answer authentication challenges.
    /// - Returns: A new InputStream that will read data from a remote URL such as a website or an FTP server.
    /// - Throws: If an error occurs.
    ///
    public static func getInputStream(url: URL, options: URLInputStreamOptions = [], authenticate: AuthenticationCallback? = nil) throws -> InputStream {
        if url.scheme == nil || url.scheme == "file" {
            guard let inputStream = InputStream(url: url) else { throw URLISErrors.General(description: "Unable to open URL: \"\(url.absoluteString)\"") }
            return inputStream
        }
        else {
            return URLInputStream(url: url, options: options, authenticate: authenticate)
        }
    }
}

extension Stream.PropertyKey {
    /*==========================================================================================================*/
    /// A key to get the mime-type from the input stream's properties.
    ///
    public static let mimeTypeKey:         Stream.PropertyKey = Stream.PropertyKey("MIME-TYPE")
    /*==========================================================================================================*/
    /// A key to get the text encoding name, if any, from the input stream's properties.
    ///
    public static let textEncodingNameKey: Stream.PropertyKey = Stream.PropertyKey("TEXT-ENCODING-NAME")
    /*==========================================================================================================*/
    /// A key to get the HTTP status code, if any, from the input stream's properties.
    ///
    public static let httpStatusCodeKey:   Stream.PropertyKey = Stream.PropertyKey("HTTP-STATUS-CODE")
    /*==========================================================================================================*/
    /// A key to get the human readable HTTP status code, if any, from the input stream's properties.
    ///
    public static let httpStatusTextKey:   Stream.PropertyKey = Stream.PropertyKey("HTTP-STATUS-TEXT")
    /*==========================================================================================================*/
    /// A key to get all of the HTTP headers, if any, from the input stream's properties.
    ///
    public static let httpHeadersKey:      Stream.PropertyKey = Stream.PropertyKey("HTTP-HEADERS")
    /*==========================================================================================================*/
    /// A key to get all of the HTTP cookies, if any, from the input stream's properties.
    ///
    public static let httpCookiesKey:      Stream.PropertyKey = Stream.PropertyKey("HTTP-COOKIES")
}
