import Foundation
import Kafka
import Vapor

final class KafkaProducerService: @unchecked Sendable {
    private let producer: KafkaProducer
    private let topic: String

    init(bootstrapServers: String, topic: String, logger: Logger) throws {
        self.topic = topic
        // Parse comma-separated brokers, e.g. "localhost:9092,otherhost:9092"
        let brokers = bootstrapServers.split(separator: ",").compactMap { part -> KafkaConfiguration.BrokerAddress? in
            let hostPort = part.split(separator: ":")
            guard hostPort.count == 2, let port = Int(hostPort[1]) else { return nil }
            return .init(host: String(hostPort[0]), port: port)
        }
        let config = KafkaProducerConfiguration(bootstrapBrokerAddresses: brokers)
        self.producer = try KafkaProducer(configuration: config, logger: logger)
    }

    func sendBookingEvent(_ booking: BookingDTO, on eventLoop: any EventLoop) -> EventLoopFuture<Void> {
        let promise = eventLoop.makePromise(of: Void.self)
        do {
            let data = try JSONEncoder().encode(booking)
            let bytes = [UInt8](data)
            let message = KafkaProducerMessage<Never, [UInt8]>(
                topic: topic,
                value: bytes
            )
            try producer.send(message)
            promise.succeed(())
        } catch {
            promise.fail(error)
        }
        return promise.futureResult
    }
}
