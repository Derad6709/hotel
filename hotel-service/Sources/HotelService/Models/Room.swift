import Fluent
import Vapor

final class Room: Model, Content,  @unchecked Sendable {
    static let schema = "rooms"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "hotel_id")
    var hotel: Hotel

    @Field(key: "room_number")
    var roomNumber: String

    @Field(key: "type")
    var type: String

    @Field(key: "price_per_night")
    var pricePerNight: Double

    init() {}

    init(id: UUID? = nil, hotelID: UUID, roomNumber: String, type: String, pricePerNight: Double) {
        self.id = id
        self.$hotel.id = hotelID
        self.roomNumber = roomNumber
        self.type = type
        self.pricePerNight = pricePerNight
    }
}
