/*****************************************************************************************************************************//**
 *     PROJECT: Chadakoin
 *    FILENAME: URLInputStream.swift
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
import Rubicon

let BUFFER_SIZE: Int = (1024 * 1024)

class URLInputStream: InputStream {
    //@f:0
    var status:       Stream.Status               = .notOpen
    var error:        Error?                      = nil
    var inputStream:  InputStream?                = nil
    var properties:   [Stream.PropertyKey: Any]   = [:]
    var authenticate: AuthenticationCallback      = { _ in .UseDefault }
    let lock:         Conditional                 = Conditional()
    var bytes:        UnsafeMutablePointer<UInt8> = UnsafeMutablePointer<UInt8>.allocate(capacity: BUFFER_SIZE)
    var byteCount:    Int                         = 0
    let config:       URLSessionConfiguration
    let url:          URL

    lazy var session: URLSession = URLSession(configuration: config, delegate: ChadakoinDelegate(self), delegateQueue: nil)
    lazy var thread:  PGThread   = PGThread(qualityOfService: .userInitiated) { [weak self] in while let o = self { guard o.threadGood && o.doBackground() else { break } } }

    override var streamStatus:      Stream.Status { lock.withLock { (hasError ? .error : status)                                            } }
    override var streamError:       Error?        { lock.withLock { (hasError ? error : nil)                                                } }
    override var hasBytesAvailable: Bool          { lock.withLock { (isGoodToGo && (hasBytes || (inputStream?.hasBytesAvailable ?? false))) } }
    //@f:1

    init(url: URL, options: URLInputStreamOptions, authenticate: AuthenticationCallback?) {
        config = options.urlSessionConfig
        if let auth = authenticate { self.authenticate = auth }
        self.url = url
        super.init(data: Data())
    }

    deinit {
        lock.withLock {
            if thread.isExecuting { thread.cancel() }
            if let s = inputStream { s.close() }
            inputStream = nil
            status = .closed
            byteCount = 0
        }
        bytes.deallocate()
        session.invalidateAndCancel()
    }

    override func read(_ buffer: UnsafeMutablePointer<UInt8>, maxLength len: Int) -> Int {
        lock.withLock { isOpen ? read(into: buffer, maxLength: (len < 0) ? Int.max : len) : 0 }
    }

    override func getBuffer(_ buffer: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>, length len: UnsafeMutablePointer<Int>) -> Bool {
        lock.withLock { ((isOpen && isGoodToGo && hasBytes) ? setBuffer(buffer, bytes, len, byteCount, true) : setBuffer(buffer, nil, len, 0, false)) }
    }

    override func open() {
        lock.withLock {
            guard isNotOpen else { return }
            session.dataTask(with: url).resume()

            while !hasStream && nilError { lock.broadcastWait() }
            guard hasStream else { status = .closed; return }

            status = .open
            thread.start()
        }
    }

    override func close() {
        lock.withLock {
            guard isOpen else { return }
            session.finishTasksAndInvalidate()
            closeInputStream()
            byteCount = 0
            status = .closed
            while hasStream { lock.broadcastWait() }
        }
    }

    override func property(forKey key: PropertyKey) -> Any? { (properties[key] ?? super.property(forKey: key)) }

    private var  uuid: String = UUID().uuidString
    override var hash: Int { uuid.hashValue }
}
