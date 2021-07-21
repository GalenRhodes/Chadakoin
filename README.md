# CHADAKOIN

Chadakoin is a libaray to provide remote URL reading abilities to the InputStream class.  Currently the [InputStream](https://developer.apple.com/documentation/foundation/inputstream) and [FileHandle](https://developer.apple.com/documentation/foundation/filehandle) classes only read [file URLs (URLs that use the "file://" protocol)](https://en.wikipedia.org/wiki/File_URI_scheme) but not other protocols such as "http", "https", and "ftp".  For non-file URLs you have to use the [URL Loading System](https://developer.apple.com/documentation/foundation/url_loading_system) which is a bit like killing house flies with an atom-bomb.  This library attempts to simplify that greatly.

## Usage

Using this library is pretty simple. I've create a new static factory method for the [InputStream](https://developer.apple.com/documentation/foundation/inputstream) class to facilitate creating an instance of InputStream that reads from a URL.

```swift
guard let url = URL(string: "https://www.w3.org/2001/XMLSchema.xsd") else { fatalError("Malformed URL.") }
let inputStream = try InputStream.getInputStream(url: url)
guard let str = String(fromInputStream: inputStream, encoding: .utf8) else { fatalError("Could not read data.") }
print(str)
```
### Options

There are various options that can be specified:

- **NoCellularAccess** - The connection will fail if the device is on a cellular network.  The default is allow connections on cellular networks.
- **NoConstrainedNetworkAccess** - The connection will fail if the device is on a slow or constrained network.  The default is to allow connections on constrained networks.
- **NoExpensiveNetworkAccess** - The connection will fail if the device is on a metered (pay-by-the-byte) network.  The default is to allow connections on metered networks.
- **NeverAcceptCookies** - The connection will not receive cookies.  The default is to accept all cookies.
- **NeverAccept3rdPartyCookies** - The connection will not receive 3<sup>rd</sup> party cookies.  The default is to accept all cookies.
- **IgnoreLocalCache** - The connection will ignore any locally cached data.  The default is to use the default caching policy specified by the protocol.
- **IgnoreRemoteCache** - The connection will ignore any remote cached data.  This setting also implies ***IgnoreLocalCache***.  The default is to use the default caching policy specified by the protocol.

To create an InputStream using options:

```swift
let inputStream = try InputStream.getInputStream(url: url, options: [ .NoCellularAccess, .IgnoreLocalCache ])
```

### Stream Properties

Several new [Stream.PropertyKeys](https://developer.apple.com/documentation/foundation/stream/propertykey) have been added to support remote URLs. They include the following:

- **mimeTypeKey** - Returns a [String](https://developer.apple.com/documentation/swift/string) containing the MIME type returned by the remote host.
- **textEncodingNameKey** - Returns a [String](https://developer.apple.com/documentation/swift/string) containing the text encoding of the data or *nil* if the encoding is not known.
- **httpStatusCodeKey** - If the URL was an HTTP/HTTPS request then this key returns a value of type [Int](https://developer.apple.com/documentation/swift/int) containing the numeric response, such as 404, that was returned by the remote host or *nil* if the URL was not an HTTP/HTTPS request.
- **httpStatusTextKey** - If the URL was an HTTP/HTTPS request then this key returns a value of type [String](https://developer.apple.com/documentation/swift/string) containing the human readable response to the numeric response.  For example, if the numeric response was 404 then the human readable response will be "not found". This key will return *nil* if the URL was not an HTTP/HTTPS request.
- **httpHeadersKey** - If the URL was an HTTP/HTTPS request then this key returns a value of type [[AnyHashable:Any]](https://developer.apple.com/documentation/swift/dictionary) that contains all of the headers returned by the remote host.  If the URL was not an HTTP/HTTPS request then the [Dictionary](https://developer.apple.com/documentation/swift/dictionary) will be empty.
- **httpCookiesKey** - If the URL was an HTTP/HTTPS request then this key returns a value of type [[HTTPCookie]](https://developer.apple.com/documentation/swift/array), where the values are of type [HTTPCookie](https://developer.apple.com/documentation/foundation/httpcookie), that contains all of the cookies, if any, returned by the remote host.  If the URL was not an HTTP/HTTPS request or the ***NeverAcceptCookies*** option was specified then the Array will always be empty.

### Authentication

Simple authentication can be accomplished by providing a closure of type <code>([URLProtectionSpace](https://developer.apple.com/documentation/foundation/urlprotectionspace)) -> AuthenticationResponse</code>. Authentication response is defined as:

```swift
public enum AuthenticationResponse {
    case Credentials(username: String, password: String)
    case UseDefault
    case Cancel
    case RejectProtectionSpace
}
```

- **Credentials** - Return this enum with the username and password to return to the remote host.
- **UseDefault** - Return this enum to indicate that the protocols default handling of an Authentication Challenge should be used.
- **Cancel** - Return this enum to cancel the request in response to an Authentication Challenge. The connection will fail.
- **RejectProtectionSpace** - Return this enum to reject this challenge, and call the authentication closure again with the next authentication protection space.  This response is only appropriate in fairly unusual situations. For example, a Windows server might use both [NSURLAuthenticationMethodNegotiate](https://developer.apple.com/documentation/foundation/nsurlauthenticationmethodnegotiate) and [NSURLAuthenticationMethodNTLM](https://developer.apple.com/documentation/foundation/nsurlauthenticationmethodntlm). If your app can only handle NTLM, you would want to reject the Negotiate challenge, in order to then receive the queued NTLM challenge.

## API Documentation

Documentation of the API can be found here: [Chadakoin API](http://galenrhodes.com/Chadakoin/)

## Why the name Chadakoin?

Borrowing from the concept of being able to read from a stream, the [Chadakoin is a river](https://en.wikipedia.org/wiki/Chadakoin_River) in Western New York which drains [Chautauqua Lake](https://en.wikipedia.org/wiki/Chautauqua_Lake), eventually, into the Gulf of Mexico.  See [Chadakoin River](https://en.wikipedia.org/wiki/Chadakoin_River)

[Copyright © 2021 Galen Rhodes. All rights reserved.](LICENSE)
