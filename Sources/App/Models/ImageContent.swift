//
//  ImageContents.swift
//  
//
//  Created by David Jordan Manalu on 26/11/20.
//

import FluentPostgreSQL
import Vapor

final class ImageContent: Content, PostgreSQLUUIDModel {
    var id: UUID?
    var imageData: String
}
