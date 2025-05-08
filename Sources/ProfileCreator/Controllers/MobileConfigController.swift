import Vapor

struct MobileConfigController: RouteCollection {
    private let signer: MobileConfigSigner
    
    init(signer: MobileConfigSigner) {
        self.signer = signer
    }
    
    func boot(routes: any RoutesBuilder) throws {
        let mobileConfig = routes.grouped("api", "mobileconfig")
        mobileConfig.post("upload", use: upload)
    }
    
    func upload(req: Request) async throws -> Response {
        do {
            // Get the uploaded file from the multipart form data
            let file = try req.content.get(File.self, at: "file")
            
            // Validate file extension
            guard file.filename.hasSuffix(".mobileconfig") else {
                throw Abort(.badRequest, reason: "File must have .mobileconfig extension")
            }
            
            // Create uploads directory if it doesn't exist
            let uploadsDir = URL(fileURLWithPath: req.application.directory.workingDirectory)
                .appendingPathComponent("Public")
                .appendingPathComponent("uploads")
            
            try? FileManager.default.createDirectory(at: uploadsDir, withIntermediateDirectories: true)
            
            // Generate unique filename
            let uniqueFilename = "\(UUID().uuidString).mobileconfig"
            let fileURL = uploadsDir.appendingPathComponent(uniqueFilename)
            
            // Convert ByteBuffer to Data
            let fileData = Data(buffer: file.data)
            
            // Sign the mobile config file
            let signedData = try signer.sign(fileData)
            
            // Write signed file to disk
            try signedData.write(to: fileURL)
            
            // Create download URL
            let downloadURL = "/uploads/\(uniqueFilename)"
            
            // Return response with download URL
            return Response(
                status: .ok,
                headers: ["Content-Type": "application/json"],
                body: .init(string: """
                    {
                        "status": "success",
                        "download_url": "\(downloadURL)"
                    }
                    """)
            )
        } catch let error as SigningError {
            switch error {
            case .certificateNotFound:
                throw Abort(.internalServerError, reason: "Certificate not found")
            case .signingFailed(let reason):
                throw Abort(.internalServerError, reason: "Signing failed: \(reason)")
            case .invalidData:
                throw Abort(.badRequest, reason: "Invalid mobile config data")
            case .certificateConversionFailed(let reason):
                throw Abort(.internalServerError, reason: "Certificate conversion failed: \(reason)")
            }
        }
    }
} 