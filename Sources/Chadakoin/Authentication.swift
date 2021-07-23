/*****************************************************************************************************************************//**
 *     PROJECT: Chadakoin
 *    FILENAME: Authentication.swift
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

/*==============================================================================================================*/
/// This enumeration represents the response to be returned from an authentication challenge callback.
///
public enum AuthenticationResponse {
    /*==========================================================================================================*/
    /// Return this to respond to the challenge with a username and password.
    ///
    case Credentials(username: String, password: String)
    /*==========================================================================================================*/
    /// Return this to respond to the challenge using the default action.
    ///
    case UseDefault
    /*==========================================================================================================*/
    /// Return this to cancel the challenge.
    ///
    case Cancel
    /*==========================================================================================================*/
    /// Return this to reject the protection space and have the callback closure called with the next projection
    /// space, if any.
    ///
    case RejectProtectionSpace
}

/*==============================================================================================================*/
/// The authentication callback closure type.
///
public typealias AuthenticationCallback = (URLProtectionSpace) -> AuthenticationResponse
