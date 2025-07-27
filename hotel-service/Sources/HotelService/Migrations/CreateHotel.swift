import Fluent

struct CreateHotel: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("hotels")
            .id()
            .field("name", .string, .required)
            .field("city", .string, .required)
            .field("address", .string, .required)
            .field("description", .string, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("hotels").delete()
    }
}
