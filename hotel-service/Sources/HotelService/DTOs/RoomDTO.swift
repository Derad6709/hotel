import Vapor

struct RoomDTO: Content {
    var id: UUID?
    var hotelID: UUID
    var roomNumber: String
    var type: String
    var pricePerNight: Double
}
