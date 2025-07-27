import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    try app.register(collection: HotelController())
    try app.register(collection: RoomController())
    try app.register(collection: BookingController())
    try app.register(collection: ReviewController())
}
