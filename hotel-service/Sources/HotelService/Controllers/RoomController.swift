import Fluent
import Vapor
import Vapor

struct RoomController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let rooms = routes.grouped("rooms")
        rooms.get(use: index)
        rooms.post(use: create)
        rooms.group(":roomID") { room in
            room.get(use: get)
        }
    }

    func index(req: Request) async throws -> [RoomDTO] {
        let rooms = try await Room.query(on: req.db).all()
        return rooms.map { $0.toDTO() }
    }

    func create(req: Request) async throws -> RoomDTO {
        let dto = try req.content.decode(RoomDTO.self)
        let room = Room(
            hotelID: dto.hotelID,
            roomNumber: dto.roomNumber,
            type: dto.type,
            pricePerNight: dto.pricePerNight
        )
        try await room.save(on: req.db)
        return room.toDTO()
    }

    func get(req: Request) async throws -> RoomDTO {
        guard let room = try await Room.find(req.parameters.get("roomID"), on: req.db) else {
            throw Abort(.notFound)
        }
        return room.toDTO()
    }
}

// MARK: - Room <-> RoomDTO
extension Room {
    func toDTO() -> RoomDTO {
        RoomDTO(
            id: self.id,
            hotelID: self.$hotel.id,
            roomNumber: self.roomNumber,
            type: self.type,
            pricePerNight: self.pricePerNight
        )
    }
}
