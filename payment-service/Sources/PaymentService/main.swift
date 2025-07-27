import Foundation
import Kafka
import Logging
import NIOCore  // Import NIOCore for ByteBuffer
import ServiceLifecycle
import Vapor

private func setupKafkaConsumer(app: Application) async throws {
    let broker = Environment.get("KAFKA_BROKER") ?? "localhost:9092"

    // Parse broker string into BrokerAddress array
    let brokerAddresses: [KafkaConfiguration.BrokerAddress] = parseBrokerAddresses(broker)

    // Create consumer configuration
    let consumerConfig = KafkaConsumerConfiguration(
        consumptionStrategy: .group(id: "payment-service-group", topics: ["bookings"]),
        bootstrapBrokerAddresses: brokerAddresses
    )

    // Create producer configuration
    let producerConfig = KafkaProducerConfiguration(
        bootstrapBrokerAddresses: brokerAddresses
    )

    do {
        let consumer = try KafkaConsumer(
            configuration: consumerConfig,
            logger: app.logger
        )

        let producer = try KafkaProducer(
            configuration: producerConfig,
            logger: app.logger
        )

        app.logger.info("Kafka consumer and producer initialized")

        // Use updated constructor for ServiceGroup
        let serviceGroup = ServiceGroup(
            services: [consumer],
            gracefulShutdownSignals: [],
            cancellationSignals: [],
            logger: app.logger
        )

        // Run the consumer service in a background task
        Task {
            do {
                try await serviceGroup.run()
            } catch {
                app.logger.error("Kafka service group failed: \(error)")
            }
        }

        // Process messages using the async API
        Task {
            do {
                app.logger.info("Starting to consume messages from bookings topic")

                // Process messages using async iterator
                for try await message in consumer.messages {
                    app.logger.info("Received booking message, processing payment")

                    // Access message value directly as ByteBuffer
                    let valueBuffer = message.value

                    do {
                        // Convert ByteBuffer to Data for JSON parsing
                        let valueData = Data(valueBuffer.readableBytesView)

                        guard
                            let json = try JSONSerialization.jsonObject(with: valueData)
                                as? [String: Any]
                        else {
                            app.logger.error("Failed to parse booking data")
                            continue
                        }

                        var updatedBooking = json
                        updatedBooking["status"] = "confirmed"

                        // Create the result JSON data
                        let resultData = try JSONSerialization.data(withJSONObject: updatedBooking)

                        // Create value buffer
                        var resultBuffer = ByteBuffer()
                        resultBuffer.writeBytes(resultData)

                        // Create empty key buffer (when you don't want a key)
                        let emptyKeyBuffer = ByteBuffer()

                        // Use non-optional ByteBuffer for both key and value
                        let resultMessage = KafkaProducerMessage<ByteBuffer, ByteBuffer>(
                            topic: "payments",
                            key: emptyKeyBuffer,
                            value: resultBuffer
                        )

                        try await producer.send(resultMessage)
                        app.logger.info("Payment confirmation sent")
                    } catch {
                        app.logger.error("Error processing booking: \(error)")
                    }
                }
            } catch {
                app.logger.error("Error consuming Kafka messages: \(error)")
            }
        }
    } catch {
        app.logger.error("Failed to initialize Kafka: \(error)")
        throw error
    }
}

// Helper function to parse broker string into BrokerAddress array
private func parseBrokerAddresses(_ brokerString: String) -> [KafkaConfiguration.BrokerAddress] {
    return brokerString.split(separator: ",").map { brokerPart in
        let parts = brokerPart.split(separator: ":")
        let host = String(parts[0])
        let port = parts.count > 1 ? Int(parts[1]) ?? 9092 : 9092
        return KafkaConfiguration.BrokerAddress(host: host, port: port)
    }
}

public func main() async throws {
    let app = try await Application.make(.production)

    // Setup Kafka consumer/producer
    try await setupKafkaConsumer(app: app)

    // Execute the application
    try await app.execute()
}

// Start the application
try await main()
