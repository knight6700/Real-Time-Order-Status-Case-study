import Foundation
/// A generic structure for WebSocket responses.
/// `T` represents the expected type of the payload.
struct WebSocketMessage<T: Codable>: Codable {
    let type: String
    let payload: T
    let meta: Meta?
    
    struct Meta: Codable {
        let timestamp: Date?
    }
}
