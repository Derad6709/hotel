import Fluent

struct CreateRoom: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("rooms")
            .id()
            .field("hotel_id", .uuid, .required, .references("hotels", "id"))
            .field("room_number", .string, .required)
            .field("type", .string, .required)
            .field("price_per_night", .double, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("rooms").delete()
    }
}
