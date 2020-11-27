//
//  Profile.swift
//  
//
//  Created by David Jordan Manalu on 27/11/20.
//

import FluentPostgreSQL
import Vapor

final class Profile: Content, PostgreSQLUUIDModel, Parameter {
    var id: UUID?
    var userID: User.ID
    var name: String
    var gender: String
    var phoneNumber: String
    
    var user: Parent<Profile, User> {
        return parent(\.userID)
    }
    
    init(userID: User.ID) {
        self.userID = userID
        name = ""
        gender = ""
        phoneNumber = ""
    }
}

extension Profile: PostgreSQLMigration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            
            builder.reference(from: \.userID, to: \User.id)
        }
    }
}
