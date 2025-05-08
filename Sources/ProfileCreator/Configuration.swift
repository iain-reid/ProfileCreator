import Vapor
import Foundation

struct Configuration {
    struct Certificate {
        let path: String
        let password: String
        
        static var `default`: Certificate {
            // For testing, use a hardcoded path
            let finalPath = "/Users/iainreid/Projects/ProfileCreator/ProfileCreator/Certificates/profile_creator.p12"
            print("Certificate path configuration:")
            print("  Using hardcoded path: \(finalPath)")
            
            return Certificate(
                path: finalPath,
                password: "development"
            )
        }
    }
    
    static let certificate = Certificate.default
} 