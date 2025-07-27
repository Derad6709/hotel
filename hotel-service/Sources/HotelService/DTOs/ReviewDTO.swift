import Vapor

struct ReviewDTO: Content {
    var id: UUID?
    var userID: UUID
    var hotelID: UUID
    var rating: Int
    var comment: String
    var createdAt: Date
}
