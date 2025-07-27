import Fluent

struct CreateBooking: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("bookings")
            .id()
            .field("user_id", .uuid, .required)
            .field("room_id", .uuid, .required, .references("rooms", "id"))
            .field("start_date", .date, .required)
            .field("end_date", .date, .required)
            .field("total_price", .double, .required)
            .field("status", .string, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("bookings").delete()
    }
}
