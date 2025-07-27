import Fluent
import Vapor

enum BookingStatus: String, Codable {
    case pending, confirmed, cancelled
}

final class Booking: Model, Content,  @unchecked Sendable {
    static let schema = "bookings"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "user_id")
    var userID: UUID

    @Parent(key: "room_id")
    var room: Room

    @Field(key: "start_date")
    var startDate: Date

    @Field(key: "end_date")
    var endDate: Date

    @Field(key: "total_price")
    var totalPrice: Double

    @Field(key: "status")
    var status: BookingStatus

    init() {}

    init(
        id: UUID? = nil, userID: UUID, roomID: UUID, startDate: Date, endDate: Date,
        totalPrice: Double, status: BookingStatus
    ) {
        self.id = id
        self.userID = userID
        self.$room.id = roomID
        self.startDate = startDate
        self.endDate = endDate
        self.totalPrice = totalPrice
        self.status = status
    }
}
