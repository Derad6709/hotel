import Fluent
import JWT
import Vapor

struct RegisterRequest: Content {
    let email: String
    let password: String
    let role: String
}

struct LoginRequest: Content {
    let email: String
    let password: String
}

struct TokenResponse: Content {
    let token: String
}

struct UserPayload: JWTPayload, Content, AsyncResponseEncodable {
    var subject: SubjectClaim
    var expiration: ExpirationClaim
    var email: String
    var role: String

    func verify(using algorithm: some JWTAlgorithm) async throws {
        try self.expiration.verifyNotExpired()
    }
}

struct AuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.post("register", use: register)
        routes.post("login", use: login)
        routes.get("verify", use: verify)
    }

    func register(req: Request) async throws -> TokenResponse {
        let data = try req.content.decode(RegisterRequest.self)
        guard try await User.query(on: req.db).filter(\.$email == data.email).first() == nil else {
            throw Abort(.badRequest, reason: "Email already registered")
        }
        let hash = try Bcrypt.hash(data.password)
        let user = User(email: data.email, passwordHash: hash, role: data.role)
        try await user.save(on: req.db)
        let token = try await generateToken(for: user, req: req)
        return TokenResponse(token: token)
    }

    func login(req: Request) async throws -> TokenResponse {
        let data = try req.content.decode(LoginRequest.self)
        guard let user = try await User.query(on: req.db).filter(\.$email == data.email).first(),
            try Bcrypt.verify(data.password, created: user.passwordHash)
        else {
            throw Abort(.unauthorized, reason: "Invalid credentials")
        }
        let token = try await generateToken(for: user, req: req)
        return TokenResponse(token: token)
    }

    func verify(req: Request) async throws -> UserPayload {
        let payload = try await req.jwt.verify(as: UserPayload.self)
        return payload
    }

    private func generateToken(for user: User, req: Request) async throws -> String {
        let payload = UserPayload(
            subject: .init(value: user.id!.uuidString),
            expiration: .init(value: .init(timeIntervalSinceNow: 60 * 60 * 24)),
            email: user.email, role: user.role
        )
        return try await req.jwt.sign(payload)
    }
}
