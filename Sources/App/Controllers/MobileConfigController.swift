import Vapor

struct MobileConfigController: RouteCollection {
    private let signer: MobileConfigSigner
    
    init(signer: MobileConfigSigner) {
        self.signer = signer
    }
    
    func boot(routes: RoutesBuilder) throws {
        let mobileConfig = routes.grouped("api", "mobileconfig")
        mobileConfig.post("upload", use: upload)
    }
    
    func upload(req: Request) async throws -> Response {
        // Check if file exists in request
        guard let file = req.body.data else {
            throw Abort(.badRequest, reason: "No file uploaded")
        }
        
        // Validate file extension
        guard let filename = req.headers.first(name: .contentDisposition)?.split(separator: ";")
            .first(where: { $0.contains("filename=") })?
            .split(separator: "=")
            .last?
            .trimmingCharacters(in: .whitespaces)
            .trimmingCharacters(in: CharacterSet(charactersIn: "\"")) else {
            throw Abort(.badRequest, reason: "Invalid filename")
        }
        
        guard filename.hasSuffix(".mobileconfig") else {
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
        
        // Sign the mobile config file
        let signedData = try await signer.sign(Data(file.readableBytesView))
        
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
    }
} 