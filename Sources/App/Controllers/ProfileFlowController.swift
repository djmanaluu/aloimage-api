//
//  File.swift
//  
//
//  Created by David Jordan Manalu on 27/11/20.
//

import Fluent
import Vapor

final class ProfileFlowController: RouteCollection {
    // MARK: - RouterCollection
    
    func boot(router: Router) throws {
        let grouped: Router = router.grouped("api", "profile")
        
        grouped.get(User.parameter, use: getProfile(_:))
        grouped.post(BaseParameter.self, use: postProfile(_:baseParameter:))
    }
    
    // MARK: - Request
    
    private func getProfile(_ req: Request) throws -> Future<Profile> {
        return try req.parameters.next(User.self).flatMap { user -> Future<Profile> in
            return try user.profiles.query(on: req).first().map { profile -> Profile in
                guard let profile: Profile = profile else {
                    return Profile(userID: user.id!)
                }
                
                return profile
            }
        }
    }
    
    private func postProfile(_ req: Request, baseParameter: BaseParameter<Profile>) throws -> Future<EmptyResponse> {
        return Token.query(on: req).filter(\.token == baseParameter.token).first().flatMap { token -> Future<EmptyResponse> in
            let profile: Profile = baseParameter.data
            
            return User.query(on: req).filter(\.id == profile.userID).first().flatMap { user -> Future<EmptyResponse> in
                guard let user: User = user else { throw Abort(HTTPStatus.notFound) }
                
                return try user.profiles.query(on: req).first().flatMap { savedProfile -> Future<EmptyResponse> in
                    guard let savedProfile: Profile = savedProfile else {
                        return profile.save(on: req).transform(to: EmptyResponse())
                    }
                    
                    return savedProfile.delete(on: req).flatMap { _ -> Future<EmptyResponse> in
                        profile.save(on: req).transform(to: EmptyResponse())
                    }
                }
            }
        }
    }
}
