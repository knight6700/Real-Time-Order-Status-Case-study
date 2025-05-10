import Foundation

struct OrderRequest: Encodable {
    let action: String
    let orderId: String
}
