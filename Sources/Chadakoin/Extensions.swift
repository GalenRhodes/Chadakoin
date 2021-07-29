/*****************************************************************************************************************************//**
 *     PROJECT: Chadakoin
 *    FILENAME: String.swift
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: July 21, 2021
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

extension String {
    @inlinable public init?(fromInputStream inputStream: InputStream, encoding: String.Encoding = .utf8) {
        guard let data = Data(fromInputStream: inputStream) else { return nil }
        self.init(data: data, encoding: encoding)
    }
}

extension Data {
    public init?(fromInputStream inputStream: InputStream) {
        self.init()
        defer { inputStream.close() }
        inputStream.open()
        let sz   = (1024 * 1024)
        let buff = UnsafeMutablePointer<UInt8>.allocate(capacity: sz)
        defer { buff.deallocate() }
        var rs = inputStream.read(buff, maxLength: sz)
        while rs > 0 {
            append(buff, count: rs)
            rs = inputStream.read(buff, maxLength: sz)
        }
        guard rs == 0 else { return nil }
    }
}

extension Thread {
    public convenience init(qualityOfService: QualityOfService, block: @escaping () -> Void) {
        self.init(block: block)
        self.qualityOfService = qualityOfService
    }
}

extension NSCondition {

    @inlinable @discardableResult public func withLock<T>(_ body: () throws -> T) rethrows -> T {
        lock()
        defer {
            broadcast()
            unlock()
        }
        return try body()
    }

    @inlinable public func broadcastWait() {
        broadcast()
        wait()
    }
    @inlinable public func broadcastWait(until when: Date) -> Bool {
        broadcast()
        return wait(until: when)
    }

}
