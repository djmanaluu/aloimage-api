//
//  UserLoginFlowController.swift
//  
//
//  Created by David Jordan Manalu on 26/11/20.
//

import Authentication
import Crypto
import Fluent
import Vapor

final class UserLoginFlowController: RouteCollection {
    // MARK: - RouteCollection
    
    func boot(router: Router) throws {
        let userRoute: Router = router.grouped("api", "users")
        let basicAuthMiddleware: BasicAuthenticationMiddleware<User> = User.basicAuthMiddleware(using: BCryptDigest())
        let basicAuthGroup: Router = userRoute.grouped(basicAuthMiddleware)
        
        // Login
        basicAuthGroup.post("login", use: login(_:))
        
        // Register
        userRoute.post(User.self, at: "register", use: register(_:user:))
        
        // Logout
        userRoute.post("logout", User.parameter, use: logout(_:))
        
        // GET USERS
        userRoute.get(use: getUsers(_:))
    }
    
    // MARK: - Request
    
    private func register(_ req: Request, user: User) throws -> Future<EmptyResponse> {
        user.password = try BCrypt.hash(user.password)
        
        return user.save(on: req).map { _ -> EmptyResponse in
            return EmptyResponse()
        }
    }
    
    private func login(_ req: Request) throws -> Future<Token> {
        let user: User = try req.requireAuthenticated(User.self)
        
        return try user.authTokens.query(on: req).all().flatMap { tokens -> Future<Token> in
            var deleteUnusedTokenAction: [Future<Void>] = []
            
            // to avoid multiple tokens
            for token in tokens {
                deleteUnusedTokenAction.append(token.delete(on: req))
            }
            
            return deleteUnusedTokenAction.flatten(on: req).flatMap { _ -> Future<Token> in
                return try Token.generate(for: user).save(on: req)
            }
        }
    }
    
    private func logout(_ req: Request) throws -> Future<EmptyResponse> {
        return try req.parameters.next(User.self).flatMap { user -> Future<EmptyResponse> in
            return try user.tokens.query(on: req).all().flatMap { tokens -> Future<EmptyResponse> in
                var deleteTokens: [Future<Void>] = []
                
                for token in tokens {
                    deleteTokens.append(token.delete(on: req))
                }
                
                return deleteTokens.flatten(on: req).map { _ -> EmptyResponse in
                    return EmptyResponse()
                }
            }
        }
    }
    
    private func getUsers(_ req: Request) throws -> Future<[User]> {
        return User.query(on: req).all()
    }
}
