import Foundation

struct OrderDTO: Decodable {
    let id: String
    let title: String
    let startTime: Date
    let endTime: Date
    let location: String
    let orderStatus: OrderStatus
}

enum OrderStatus: String, Decodable {
    case submitted
    case routed
    case partiallyFilled = "partially_filled"
    case filled
    case cancelled
    case rejected
}
