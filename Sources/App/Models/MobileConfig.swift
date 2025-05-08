import Vapor

struct MobileConfig: Content {
    let id: UUID
    let filename: String
    let downloadURL: String
    let createdAt: Date
    
    init(id: UUID = UUID(), filename: String, downloadURL: String) {
        self.id = id
        self.filename = filename
        self.downloadURL = downloadURL
        self.createdAt = Date()
    }
} 