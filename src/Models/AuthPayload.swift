import Foundation

struct AuthPayload: Encodable {
    let token: String
    let action: String = "authenticate"
}
