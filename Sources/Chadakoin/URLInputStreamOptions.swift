/*****************************************************************************************************************************//**
 *     PROJECT: Chadakoin
 *    FILENAME: URLInputStreamOptions.swift
 *         IDE: AppCode
 *      AUTHOR: Galen Rhodes
 *        DATE: July 20, 2021
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

public enum URLInputStreamOptionItem: Hashable, CaseIterable {
    case NoCellularAccess
    case NoConstrainedNetworkAccess
    case NoExpensiveNetworkAccess
    case NeverAcceptCookies
    case NeverAccept3rdPartyCookies
    case IgnoreLocalCache
    case IgnoreRemoteCache
}

public typealias URLInputStreamOptions = Set<URLInputStreamOptionItem>

extension URLInputStreamOptions {
    private var cacheOption: URLRequest.CachePolicy {
        if contains(URLInputStreamOptionItem.IgnoreLocalCache) { return .reloadIgnoringLocalCacheData }
        if contains(URLInputStreamOptionItem.IgnoreRemoteCache) { return .reloadIgnoringLocalAndRemoteCacheData }
        return .useProtocolCachePolicy
    }

    private var cookieOption: HTTPCookie.AcceptPolicy {
        if contains(URLInputStreamOptionItem.NeverAcceptCookies) { return .never }
        if contains(URLInputStreamOptionItem.NeverAccept3rdPartyCookies) { return .onlyFromMainDocumentDomain }
        return .always
    }

    var urlSessionConfig: URLSessionConfiguration {
        let cache   = cacheOption
        let cookies = cookieOption
        let config  = URLSessionConfiguration.default

        config.httpShouldUsePipelining = false
        config.httpCookieAcceptPolicy = cookies
        config.requestCachePolicy = cache
        config.networkServiceType = .responsiveData

        config.allowsCellularAccess = !contains(URLInputStreamOptionItem.NoCellularAccess)
        config.allowsConstrainedNetworkAccess = !contains(URLInputStreamOptionItem.NoConstrainedNetworkAccess)
        config.allowsExpensiveNetworkAccess = !contains(URLInputStreamOptionItem.NoExpensiveNetworkAccess)

        config.httpCookieStorage = ((cookies == .never) ? nil : HTTPCookieStorage())
        config.urlCache = ((cache == .useProtocolCachePolicy) ? URLCache.shared : nil)

        return config
    }
}
