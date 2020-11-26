//
//  File.swift
//  
//
//  Created by David Jordan Manalu on 26/11/20.
//

import Authentication
import FluentPostgreSQL
import Vapor

final class User: Content, PostgreSQLUUIDModel, Parameter {
    var id: UUID?
    var email: String
    var password: String
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}

extension User: PostgreSQLMigration {
    static func prepare(on connection: PostgreSQLConnection) -> EventLoopFuture<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            
            builder.unique(on: \.email)
        }
    }
}

extension User: BasicAuthenticatable {
    static var usernameKey: UsernameKey = \User.email
    static var passwordKey: PasswordKey = \User.password
}

extension User: TokenAuthenticatable {
    typealias TokenType = Token
}
