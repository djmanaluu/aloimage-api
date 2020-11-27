import Authentication
import FluentPostgreSQL
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    try services.register(FluentPostgreSQLProvider())

    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    var middlewares = MiddlewareConfig()
    
    middlewares.use(ErrorMiddleware.self)
    services.register(middlewares)
    
    let databaseConfig: PostgreSQLDatabaseConfig
    
    if let url = Environment.get("DATABASE_URL") {
      databaseConfig = PostgreSQLDatabaseConfig(url: url)!
    }
    else {
        databaseConfig = PostgreSQLDatabaseConfig(
            hostname: Environment.get("DATABASE_HOSTNAME") ?? "localhost",
            username: "vapor_username",
            database: "vapor_database",
            password: "vapor_password")
        
    }
    
    let database = PostgreSQLDatabase(config: databaseConfig)
    
    var databases = DatabasesConfig()
    databases.add(database: database, as: .psql)
    services.register(databases)

    var migrations = MigrationConfig()
    
    migrations.add(model: User.self, database: .psql)
    migrations.add(model: Token.self, database: .psql)
    migrations.add(model: Profile.self, database: .psql)
    
    services.register(migrations)
    try services.register(AuthenticationProvider())
}
