import SwiftUI
import LLM

class ChatBot: LLM {
    static let modelName = "HuggingFaceTB/smollm-135M-instruct-v0.2-Q8_0-GGUF"
    static let systemPrompt = "You are a helpful and friendly AI assistant. Keep your responses concise and engaging."
    
    convenience init?(_ update: @escaping (Double) -> Void) async {
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