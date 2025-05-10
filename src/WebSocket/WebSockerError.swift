import Foundation

/// Defines the set of errors that can occur while using the `WebSocketService`.
///
/// These errors cover connection issues, encoding/decoding failures, and invalid messages.
/// You can use these cases to provide meaningful feedback to users or to log specific failure reasons.
enum WebSocketError: Error {
    case connectionFailed
    case disconnected
    case invalidMessage
    case decodingFailed(Error)
    case encodingFaild(Error)
    case serverError(String)
}

