//
//  File.swift
//  
//
//  Created by David Jordan Manalu on 26/11/20.
//

import Authentication
import FluentPostgreSQL
import Vapor

final class Token: Content, PostgreSQLUUIDModel {
    var id: UUID?
    var token: String
    var userID: User.ID
    
    init(token: String, userID: User.ID) {
        self.token = token
        self.userID = userID
    }
    
    static func generate(for user: User) throws -> Token {
        let randomToken: String = try CryptoRandom().generateData(count: 16).base64EncodedString()
        
        return try Token(token: randomToken, userID: user.requireID())
    }
}

extension Token: PostgreSQLMigration {
    static func prepare(on connection: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            
            builder.reference(from: \.userID, to: \User.id)
        }
    }
}

extension Token: Authentication.Token {
    static var userIDKey: UserIDKey = \Token.userID
    typealias UserType = User
}

extension Token: BearerAuthenticatable {
    static var tokenKey: TokenKey = \Token.token
}
