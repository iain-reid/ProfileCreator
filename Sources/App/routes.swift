import Vapor

func routes(_ app: Application) throws {
    // Initialize the signer with certificate details from configuration
    let signer = MobileConfigSigner(
        certificatePath: Configuration.certificate.path,
        certificatePassword: Configuration.certificate.password
    )
    
    // Register the MobileConfigController with the signer
    try app.register(collection: MobileConfigController(signer: signer))
    
    // ... existing code ...
} 