import SwiftUI
import LLM

class ChatBot: LLM {
    static let modelName = "HuggingFaceTB/smollm-135M-instruct-v0.2-Q8_0-GGUF"
    static let systemPrompt = "You are a helpful and friendly AI assistant. Keep your responses concise and engaging."
    
    convenience init?(_ update: @escaping (Double) -> Void) async {
        // First check if we have a cached model
        if let cachedModelURL = Bundle.main.url(forResource: "smollm-135M-instruct-v0.2-Q8_0", withExtension: "gguf") {
            self.init(from: cachedModelURL, template: .chatML(Self.systemPrompt))
            return
        }
        
        // If no cached model, download from HuggingFace
        let model = HuggingFaceModel(Self.modelName, .Q8_0, template: .chatML(Self.systemPrompt))
        try? await self.init(from: model) { progress in update(progress) }
    }
}

// Message model for chat history
struct Message: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
} 