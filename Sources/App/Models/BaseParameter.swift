//
//  BaseParameter.swift
//  
//
//  Created by David Jordan Manalu on 26/11/20.
//

import FluentPostgreSQL
import Vapor

struct BaseParameter<T: Content>: Content, PostgreSQLModel, Parameter {
    var id: Int?
    var data: T
    var token: String
}
