import Fluent

struct CreateReview: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("reviews")
            .id()
            .field("user_id", .uuid, .required)
            .field("hotel_id", .uuid, .required, .references("hotels", "id"))
            .field("rating", .int, .required)
            .field("comment", .string, .required)
            .field("created_at", .datetime, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("reviews").delete()
    }
}
