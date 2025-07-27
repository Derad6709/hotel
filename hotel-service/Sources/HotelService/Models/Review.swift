import Fluent
import Vapor

final class Review: Model, Content,  @unchecked Sendable {
    static let schema = "reviews"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "user_id")
    var userID: UUID

    @Parent(key: "hotel_id")
    var hotel: Hotel

    @Field(key: "rating")
    var rating: Int

    @Field(key: "comment")
    var comment: String

    @Field(key: "created_at")
    var createdAt: Date

    init() {}

    init(
        id: UUID? = nil, userID: UUID, hotelID: UUID, rating: Int, comment: String, createdAt: Date
    ) {
        self.id = id
        self.userID = userID
        self.$hotel.id = hotelID
        self.rating = rating
        self.comment = comment
        self.createdAt = createdAt
    }
}
