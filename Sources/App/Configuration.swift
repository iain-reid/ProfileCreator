import Vapor

struct Configuration {
    struct Certificate {
        let path: String
        let password: String
        
        static var `default`: Certificate {
            Certificate(
                path: Environment.get("CERTIFICATE_PATH") ?? "Certificates/profile_creator.p12",
                password: Environment.get("CERTIFICATE_PASSWORD") ?? "development"
            )
        }
    }
    
    static let certificate = Certificate.default
} 