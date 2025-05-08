import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async throws in
        try await req.view.render("index", ["title": "Hello Vapor!"])
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    // Initialize the signer with certificate details from configuration
    let certificatePath = Configuration.certificate.path
    let certificatePassword = Configuration.certificate.password
    print("Routes: Initializing MobileConfigSigner with:")
    print("  Certificate path: \(certificatePath)")
    print("  Certificate password: \(certificatePassword)")
    
    let signer = MobileConfigSigner(
        certificatePath: certificatePath,
        certificatePassword: certificatePassword
    )
    
    // Register the MobileConfigController with the signer
    try app.register(collection: MobileConfigController(signer: signer))

    try app.register(collection: TodoController())
}
