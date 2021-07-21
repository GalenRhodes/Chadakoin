/*****************************************************************************************************************************//**
 *     PROJECT: Chadakoin
 *    FILENAME: URLInputStreamExt.swift
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
import Rubicon

extension URLInputStream {
    //@f:0
    @inlinable var hasBytes:   Bool { (byteCount > 0)                                    }
    @inlinable var isOpen:     Bool { (status == .open)                                  }
    @inlinable var isClosed:   Bool { (status == .closed)                                }
    @inlinable var isNotOpen:  Bool { (status == .notOpen)                               }
    @inlinable var hasStream:  Bool { (inputStream != nil)                               }
    @inlinable var nilError:   Bool { (error == nil)                                     }
    @inlinable var bufferFull: Bool { (byteCount >= BUFFER_SIZE)                         }
    @inlinable var threadGood: Bool { !thread.isCancelled                                }
    @inlinable var hasError:   Bool { ((isClosed || (isOpen && !hasBytes)) && !nilError) }
    @inlinable var isGoodToGo: Bool { (isOpen && hasStream && (nilError || hasBytes))    }
    //@f:1

    @inlinable func getStreamError(_ inputStream: InputStream) -> Error { (inputStream.streamError ?? StreamError.UnknownError()) }

    func read(into buffer: UnsafeMutablePointer<UInt8>, maxLength len: Int) -> Int {
        var cc = 0
        while cc < len {
            while isGoodToGo && !hasBytes { lock.broadcastWait() }
            guard isOpen else { return cc }

            let l = min((len - cc), byteCount)
            guard l > 0 else { return (nilError ? cc : -1) }
            getBytes(into: buffer, atOffset: &cc, count: l)
        }
        return cc
    }

    @inlinable func setBuffer(_ buffer: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>, _ v1: UnsafeMutablePointer<UInt8>?, _ len: UnsafeMutablePointer<Int>, _ v2: Int, _ v3: Bool) -> Bool {
        buffer.pointee = v1
        len.pointee = v2
        return v3
    }

    @inlinable func getBytes(into buffer: UnsafeMutablePointer<UInt8>, atOffset offset: inout Int, count: Int) {
        byteCount -= count
        memcpy((buffer + offset), bytes, count)
        if hasBytes { memcpy(bytes, (bytes + count), byteCount) }
        offset += count
    }

    func doBackground() -> Bool {
        lock.withLock {
            guard let inputStream = inputStream else { return false }
            while bufferFull && isGoodToGo && threadGood { guard lock.broadcastWait(until: Date(timeIntervalSinceNow: 0.5)) else { return true } }
            guard isGoodToGo && threadGood else { return closeInputStream() }

            let res = inputStream.read((bytes + byteCount), maxLength: (BUFFER_SIZE - byteCount))

            guard res > 0 else {
                if res < 0 { error = getStreamError(inputStream) }
                return closeInputStream()
            }

            byteCount += res
            return true
        }
    }

    @discardableResult @inlinable func closeInputStream(_ ret: Bool = false) -> Bool {
        if let inputStream = inputStream {
            inputStream.close()
            self.inputStream = nil
        }
        return ret
    }

    @inlinable static func == (lhs: URLInputStream, rhs: URLInputStream) -> Bool { lhs === rhs }
}
