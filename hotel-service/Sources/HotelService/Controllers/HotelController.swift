import Fluent
import Vapor

struct UserPayload: Content {
    let subject: String
    let expiration: String
    let email: String
    let role: String
}

struct AuthServiceClient {
    let client: any Client
    let authServiceURL: String

    func verifyToken(_ token: String, on req: Request) async throws -> UserPayload {
        let response = try await client.get("\(authServiceURL)/verify") { req in
            req.headers.bearerAuthorization = .init(token: token)
        }
        guard response.status == .ok else {
            throw Abort(.unauthorized, reason: "Invalid token")
        }
        return try response.content.decode(UserPayload.self)
    }
}

struct HotelController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let hotels = routes.grouped("hotels")
        hotels.get(use: index)
        hotels.post(use: create)
        hotels.group(":hotelID") { hotel in
            hotel.get(use: get)
            hotel.get("rooms", use: rooms)
        }
    }

    func index(req: Request) async throws -> [HotelDTO] {
        let hotels = try await Hotel.query(on: req.db).all()
        return hotels.map { $0.toDTO() }
    }

    func create(req: Request) async throws -> HotelDTO {
        guard let token = req.headers.bearerAuthorization?.token else {
            throw Abort(.unauthorized, reason: "No bearer token provided")
        }
        let authServiceURL = Environment.get("AUTH_SERVICE_URL") ?? "http://auth-service:8080"
        let authClient: AuthServiceClient = AuthServiceClient(
            client: req.client, authServiceURL: authServiceURL)
        let user = try await authClient.verifyToken(token, on: req)
        guard user.role == "host" else {
            throw Abort(.forbidden, reason: "Only users with host role can create hotels")
        }

        let dto = try req.content.decode(HotelDTO.self)
        let hotel = Hotel(
            name: dto.name,
            city: dto.city,
            address: dto.address,
            description: dto.description
        )
        try await hotel.save(on: req.db)
        return hotel.toDTO()
    }

    func get(req: Request) async throws -> HotelDTO {
        guard let hotel = try await Hotel.find(req.parameters.get("hotelID"), on: req.db) else {
            throw Abort(.notFound)
        }
        return hotel.toDTO()
    }

    func rooms(req: Request) async throws -> [RoomDTO] {
        guard let hotel = try await Hotel.find(req.parameters.get("hotelID"), on: req.db) else {
            throw Abort(.notFound)
        }
        let rooms = try await hotel.$rooms.query(on: req.db).all()
        return rooms.map { $0.toDTO() }
    }
}
