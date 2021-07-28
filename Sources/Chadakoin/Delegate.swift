/*****************************************************************************************************************************//**
 *     PROJECT: Chadakoin
 *    FILENAME: Delegate.swift
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

class ChadakoinDelegate: NSObject, URLSessionStreamDelegate, URLSessionDataDelegate {
    weak var stream: URLInputStream?

    init(_ stream: URLInputStream) {
        self.stream = stream
    }

    func urlSession(_ session: URLSession, streamTask: URLSessionStreamTask, didBecome inputStream: InputStream, outputStream: OutputStream) {
        guard let stream = stream else { return }
        stream.lock.withLock {
            outputStream.close()
            inputStream.open()
            stream.inputStream = inputStream
        }
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler handler: @escaping (URLSession.ResponseDisposition) -> Void) {
        guard let stream = stream else { return }
        stream.lock.withLock { () -> Void in
            if let scheme = stream.url.scheme, Chadakoin.value(scheme, isOneOf: "http", "https") {
                guard let response = (response as? HTTPURLResponse) else {
                    stream.error = URLISErrors.BadResponse(description: "The response returned was not the correct type.")
                    handler(.cancel)
                    return
                }

                stream.properties[Stream.PropertyKey.httpStatusCodeKey] = response.statusCode
                stream.properties[Stream.PropertyKey.httpStatusTextKey] = HTTPURLResponse.localizedString(forStatusCode: response.statusCode)
                stream.properties[Stream.PropertyKey.httpHeadersKey] = response.allHeaderFields
                stream.properties[Stream.PropertyKey.httpCookiesKey] = (stream.config.httpCookieStorage?.cookies ?? [])

                guard (200 ... 299).contains(response.statusCode) else {
                    stream.error = URLISErrors.HTTPError(description: "\(response.statusCode) - \(HTTPURLResponse.localizedString(forStatusCode: response.statusCode).capitalized)")
                    handler(.cancel)
                    return
                }
            }
            else {
                stream.properties[Stream.PropertyKey.httpHeadersKey] = [:]
                stream.properties[Stream.PropertyKey.httpCookiesKey] = []
            }

            if let mimeType = response.mimeType { stream.properties[Stream.PropertyKey.mimeTypeKey] = mimeType }
            if let encoding = response.textEncodingName { stream.properties[Stream.PropertyKey.textEncodingNameKey] = encoding }
            handler(.becomeStream)
        }
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome streamTask: URLSessionStreamTask) {
        guard let stream = stream else { return }
        stream.lock.withLock { streamTask.captureStreams() }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler handler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let stream = stream else { return }
        stream.lock.withLock { () -> Void in
            switch stream.authenticate(challenge.protectionSpace) {
                case .Credentials(username: let username, password: let password): handler(.useCredential, URLCredential(user: username, password: password, persistence: .forSession))
                case .UseDefault:                                                  handler(.performDefaultHandling, nil)
                case .Cancel:                                                      handler(.cancelAuthenticationChallenge, nil)
                case .RejectProtectionSpace:                                       handler(.rejectProtectionSpace, nil)
            }
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let stream = stream else { return }
        stream.lock.withLock { if stream.error == nil { stream.error = (error ?? StreamError.UnknownError()) } }
    }

    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        guard let stream = stream else { return }
        stream.lock.withLock { if stream.error == nil { stream.error = (error ?? StreamError.UnknownError()) } }
    }
}
