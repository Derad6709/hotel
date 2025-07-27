import Vapor

enum BookingStatusDTO: String, Content {
    case pending, confirmed, cancelled
}

struct BookingDTO: Content {
    var id: UUID?
    var userID: UUID
    var roomID: UUID
    var startDate: Date
    var endDate: Date
    var totalPrice: Double
    var status: BookingStatusDTO
}
