import SwiftUI
import LLM

enum ModelType: String, CaseIterable {
    case smollm = "Smollm (135M)"
    case tinyLlama = "TinyLlama (1.1B)"
    
    var modelName: String {
        switch self {
        case .smollm:
            return "HuggingFaceTB/smollm-135M-instruct-v0.2-Q8_0-GGUF"
        case .tinyLlama:
            return "TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF"
        }
    }
    
    var quantization: Quantization {
        switch self {
        case .smollm:
            return .Q8_0
        case .tinyLlama:
            return .Q2_K
        }
    }
    
    var fileName: String {
        switch self {
        case .smollm:
            return "smollm-135M-instruct-v0.2-Q8_0"
        case .tinyLlama:
            return "tinyllama-1.1b-chat-v1.0.Q2_K"
        }
    }
}

class ChatBot: LLM {
    static let systemPrompt = "You are a helpful and friendly AI assistant. Keep your responses concise and engaging."
    
    convenience init?(modelType: ModelType, _ update: @escaping (Double) -> Void) async {
        let model = HuggingFaceModel(modelType.modelName, modelType.quantization, template: .chatML(Self.systemPrompt))
        try? await self.init(from: model) { progress in update(progress) }
    }
}

// Message model for chat history
struct Message: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
}

// Settings model
class Settings: ObservableObject {
    @Published var selectedModel: ModelType {
        didSet {
            UserDefaults.standard.set(selectedModel.rawValue, forKey: "selectedModel")
        }
    }
    
    init() {
        let savedModel = UserDefaults.standard.string(forKey: "selectedModel")
        self.selectedModel = ModelType(rawValue: savedModel ?? "") ?? .smollm
    }
} 