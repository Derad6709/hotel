import Vapor
import Kafka
import Vapor

struct BookingController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let bookings = routes.grouped("bookings")
        bookings.get(use: index)
        bookings.post(use: create)
        bookings.group(":bookingID") { booking in
            booking.get(use: get)
        }
    }

    func index(req: Request) async throws -> [BookingDTO] {
        let bookings = try await Booking.query(on: req.db).all()
        return bookings.map { $0.toDTO() }
    }

    func create(req: Request) async throws -> BookingDTO {
        let dto = try req.content.decode(BookingDTO.self)
        guard dto.startDate < dto.endDate else {
            throw Abort(.badRequest, reason: "startDate must be before endDate")
        }
        let booking = Booking(
            userID: dto.userID,
            roomID: dto.roomID,
            startDate: dto.startDate,
            endDate: dto.endDate,
            totalPrice: dto.totalPrice,
            status: .pending
        )
        try await booking.save(on: req.db)
        let bookingDTO = booking.toDTO()

        // Отправка события в Kafka
        if let kafkaService = req.application.storage[KafkaProducerServiceKey.self] {
            _ = try await kafkaService.sendBookingEvent(bookingDTO, on: req.eventLoop).get()
        }

        return bookingDTO
    }
    // MARK: - DI Key для KafkaProducerService
    struct KafkaProducerServiceKey: Vapor.StorageKey {
        typealias Value = KafkaProducerService
    }

    func get(req: Request) async throws -> BookingDTO {
        guard let booking = try await Booking.find(req.parameters.get("bookingID"), on: req.db)
        else {
            throw Abort(.notFound)
        }
        return booking.toDTO()
    }
}

// MARK: - Booking <-> BookingDTO
extension Booking {
    func toDTO() -> BookingDTO {
        BookingDTO(
            id: self.id,
            userID: self.userID,
            roomID: self.$room.id,
            startDate: self.startDate,
            endDate: self.endDate,
            totalPrice: self.totalPrice,
            status: BookingStatusDTO(rawValue: self.status.rawValue) ?? .pending
        )
    }
}
