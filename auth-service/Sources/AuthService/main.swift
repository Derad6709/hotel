import Fluent
import FluentPostgresDriver
import JWT
import Vapor

func configure(_ app: Application) async throws {
    app.databases.use(
        .postgres(
            configuration: .init(
                hostname: Environment.get("DATABASE_HOST") ?? "localhost",
                port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? 5432,
                username: Environment.get("DATABASE_USERNAME") ?? "vapor",
                password: Environment.get("DATABASE_PASSWORD") ?? "password",
                database: Environment.get("DATABASE_NAME") ?? "auth"
            )
        ), as: .psql)
    app.migrations.add(CreateUser())
    // JWT key setup
    try await app.jwt.keys.add(
        hmac: HMACKey(stringLiteral: Environment.get("JWT_SECRET") ?? "secret"),
        digestAlgorithm: .sha256)
    try app.register(collection: AuthController())
}

public func main() async throws {

    let env = try Environment.detect()
    let app = try await Application.make(env)

    try await configure(app)
    try await app.execute()
}

try await main()
