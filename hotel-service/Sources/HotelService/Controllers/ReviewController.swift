import Fluent
import Vapor
import Vapor

struct ReviewController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let reviews = routes.grouped("reviews")
        reviews.get(use: index)
        reviews.post(use: create)
        reviews.group(":reviewID") { review in
            review.get(use: get)
        }
    }

    func index(req: Request) async throws -> [ReviewDTO] {
        let reviews = try await Review.query(on: req.db).all()
        return reviews.map { $0.toDTO() }
    }

    func create(req: Request) async throws -> ReviewDTO {
        let dto = try req.content.decode(ReviewDTO.self)
        let review = Review(
            userID: dto.userID,
            hotelID: dto.hotelID,
            rating: dto.rating,
            comment: dto.comment,
            createdAt: dto.createdAt
        )
        try await review.save(on: req.db)
        return review.toDTO()
    }

    func get(req: Request) async throws -> ReviewDTO {
        guard let review = try await Review.find(req.parameters.get("reviewID"), on: req.db) else {
            throw Abort(.notFound)
        }
        return review.toDTO()
    }
}

// MARK: - Review <-> ReviewDTO
extension Review {
    func toDTO() -> ReviewDTO {
        ReviewDTO(
            id: self.id,
            userID: self.userID,
            hotelID: self.$hotel.id,
            rating: self.rating,
            comment: self.comment,
            createdAt: self.createdAt
        )
    }
}
