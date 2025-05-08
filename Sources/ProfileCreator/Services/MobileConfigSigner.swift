import Vapor
import Foundation

enum SigningError: Error {
    case certificateNotFound
    case signingFailed(String)
    case invalidData
    case certificateConversionFailed(String)
}

struct MobileConfigSigner {
    private let certificatePath: String
    private let certificatePassword: String
    private let pemPassword: String
    
    init(certificatePath: String, certificatePassword: String, pemPassword: String = "development") {
        self.certificatePath = certificatePath
        self.certificatePassword = certificatePassword
        self.pemPassword = pemPassword
        print("Initializing MobileConfigSigner with certificate path: \(certificatePath)")
        
        // Verify certificate exists
        if !FileManager.default.fileExists(atPath: certificatePath) {
            print("WARNING: Certificate file does not exist at path: \(certificatePath)")
        }
    }
    
    func sign(_ data: Data) throws -> Data {
        print("Starting signing process...")
        print("Certificate path: \(certificatePath)")
        
        // Create temporary files
        let tempDir = FileManager.default.temporaryDirectory
        let inputFile = tempDir.appendingPathComponent("input.mobileconfig")
        let outputFile = tempDir.appendingPathComponent("output.mobileconfig")
        let pemFile = tempDir.appendingPathComponent("cert.pem")
        
        // Write input data to temporary file
        try data.write(to: inputFile)
        print("Wrote input data to: \(inputFile.path)")
        
        // Convert PKCS12 to PEM
        let convertCommand = "openssl pkcs12 -in \(certificatePath) -out \(pemFile.path) -nodes -passin pass:\(certificatePassword) -legacy"
        print("Converting certificate with command: \(convertCommand)")
        
        let convertProcess = Process()
        convertProcess.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        convertProcess.arguments = ["sh", "-c", convertCommand]
        
        let convertPipe = Pipe()
        convertProcess.standardOutput = convertPipe
        convertProcess.standardError = convertPipe
        
        try convertProcess.run()
        convertProcess.waitUntilExit()
        
        if convertProcess.terminationStatus != 0 {
            let errorData = convertPipe.fileHandleForReading.readDataToEndOfFile()
            let errorString = String(data: errorData, encoding: .utf8) ?? "Unknown error"
            print("Certificate conversion failed: \(errorString)")
            throw SigningError.certificateConversionFailed(errorString)
        }
        
        // Sign using S/MIME
        let signCommand = "openssl smime -sign -in \(inputFile.path) -out \(outputFile.path) -signer \(pemFile.path) -inkey \(pemFile.path) -outform der -nodetach -binary"
        print("Signing with command: \(signCommand)")
        
        let signProcess = Process()
        signProcess.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        signProcess.arguments = ["sh", "-c", signCommand]
        
        let signPipe = Pipe()
        signProcess.standardOutput = signPipe
        signProcess.standardError = signPipe
        
        try signProcess.run()
        signProcess.waitUntilExit()
        
        if signProcess.terminationStatus != 0 {
            let errorData = signPipe.fileHandleForReading.readDataToEndOfFile()
            let errorString = String(data: errorData, encoding: .utf8) ?? "Unknown error"
            print("Signing failed: \(errorString)")
            throw SigningError.signingFailed(errorString)
        }
        
        // Read the signed data
        let signedData = try Data(contentsOf: outputFile)
        print("Successfully signed profile")
        
        // Clean up temporary files
        try? FileManager.default.removeItem(at: inputFile)
        try? FileManager.default.removeItem(at: outputFile)
        try? FileManager.default.removeItem(at: pemFile)
        
        return signedData
    }
} 