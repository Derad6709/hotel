import Fluent
import Vapor

// MARK: - Hotel <-> HotelDTO
extension Hotel {
    func toDTO() -> HotelDTO {
        HotelDTO(
            id: self.id,
            name: self.name,
            city: self.city,
            address: self.address,
            description: self.description
        )
    }
}

final class Hotel: Model, Content,  @unchecked Sendable {
    static let schema = "hotels"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "city")
    var city: String

    @Field(key: "address")
    var address: String

    @Field(key: "description")
    var description: String

    @Children(for: \.$hotel)
    var rooms: [Room]

    init() {}

    init(id: UUID? = nil, name: String, city: String, address: String, description: String) {
        self.id = id
        self.name = name
        self.city = city
        self.address = address
        self.description = description
    }
}
