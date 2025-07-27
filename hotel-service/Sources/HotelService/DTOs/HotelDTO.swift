import Vapor

struct HotelDTO: Content {
    var id: UUID?
    var name: String
    var city: String
    var address: String
    var description: String
}
