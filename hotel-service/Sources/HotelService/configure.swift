import Fluent
import FluentPostgresDriver
import Kafka
import NIOSSL
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    app.migrations.add(CreateBooking())
    app.migrations.add(CreateReview())
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(
        DatabaseConfigurationFactory.postgres(
            configuration: .init(
                hostname: Environment.get("DATABASE_HOST") ?? "localhost",
                port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:))
                    ?? SQLPostgresConfiguration.ianaPortNumber,
                username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
                password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
                database: Environment.get("DATABASE_NAME") ?? "vapor_database",
                tls: .prefer(try .init(configuration: .clientDefault)))
        ), as: .psql)

    app.migrations.add(CreateHotel())
    app.migrations.add(CreateRoom())

    // Инициализация KafkaProducerService (MVP, без сложной логики)
    if let kafkaBroker = Environment.get("KAFKA_BROKER"),
        let kafkaTopic = Environment.get("KAFKA_TOPIC")
    {
        do {
            let kafkaService = try KafkaProducerService(
                bootstrapServers: kafkaBroker, topic: kafkaTopic, logger: app.logger)
            app.storage[BookingController.KafkaProducerServiceKey.self] = kafkaService
        } catch {
            app.logger.error("KafkaProducerService init failed: \(error.localizedDescription)")
        }
    }

    // register routes
    try routes(app)
}
