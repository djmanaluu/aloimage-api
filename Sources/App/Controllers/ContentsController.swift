//
//  ContentsController.swift
//  
//
//  Created by David Jordan Manalu on 26/11/20.
//

import Fluent
import Vapor

final class ContentsController: RouteCollection {
    // MARK: - RouteCollection
    
    func boot(router: Router) throws {
        let contentsRoute: Router = router.grouped("api", "contents")
        
        contentsRoute.get(use: getContents(_:))
        contentsRoute.post(BaseParameter<ImageContent>.self, at: "add", use: addContent(_:parameter:))
    }
    
    // MARK: - Request
    
    private func getContents(_ req: Request) throws -> Future<[ImageContent]> {
        return ImageContent.query(on: req).all()
    }
    
    private func addContent(_ req: Request, parameter: BaseParameter<ImageContent>) throws -> Future<HTTPStatus> {
        return Token.query(on: req).filter(\.token == parameter.token).first().flatMap { token -> Future<HTTPStatus> in
            guard let _: Token = token else { throw Abort(.unauthorized) }
            
            return parameter.data.save(on: req).transform(to: .created)
        }
    }
}
