import Vapor
import Foundation

enum SigningError: Error {
    case certificateNotFound
    case signingFailed
    case invalidData
}

struct MobileConfigSigner {
    private let certificatePath: String
    private let certificatePassword: String
    
    init(certificatePath: String, certificatePassword: String) {
        self.certificatePath = certificatePath
        self.certificatePassword = certificatePassword
    }
    
    func sign(_ data: Data) async throws -> Data {
        // Create a temporary file for the unsigned config
        let tempDir = FileManager.default.temporaryDirectory
        let unsignedPath = tempDir.appendingPathComponent("unsigned.mobileconfig")
        let signedPath = tempDir.appendingPathComponent("signed.mobileconfig")
        
        // Write the unsigned data to a temporary file
        try data.write(to: unsignedPath)
        
        // Construct the signing command
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/openssl")
        process.arguments = [
            "smime",
            "-sign",
            "-in", unsignedPath.path,
            "-out", signedPath.path,
            "-signer", certificatePath,
            "-inkey", certificatePath,
            "-passin", "pass:\(certificatePassword)",
            "-outform", "der"
        ]
        
        // Run the signing process
        try process.run()
        process.waitUntilExit()
        
        // Check if signing was successful
        guard process.terminationStatus == 0 else {
            throw SigningError.signingFailed
        }
        
        // Read the signed data
        let signedData = try Data(contentsOf: signedPath)
        
        // Clean up temporary files
        try? FileManager.default.removeItem(at: unsignedPath)
        try? FileManager.default.removeItem(at: signedPath)
        
        return signedData
    }
} 