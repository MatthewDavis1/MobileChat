//
//  ContentView.swift
//  MobileChat
//
//  Created by Matt Davis on 12/30/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var settings = Settings()
    @State private var bot: ChatBot? = nil
    @State private var messages: [Message] = []
    @State private var inputText = ""
    @State private var progress: CGFloat = 0
    @State private var isLoading = false
    @State private var showingSettings = false
    
    func updateProgress(_ progress: Double) {
        self.progress = CGFloat(progress)
    }
    
    func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let userMessage = Message(content: inputText, isUser: true)
        messages.append(userMessage)
        let userInput = inputText
        inputText = ""
        isLoading = true
        
        Task {
            await bot?.respond(to: userInput)
            if let response = bot?.output {
                await MainActor.run {
                    messages.append(Message(content: response, isUser: false))
                    isLoading = false
                }
            }
        }
    }
    
    func loadModel() async {
        bot = await ChatBot(modelType: settings.selectedModel, updateProgress)
    }
    
    var body: some View {
        Group {
            if bot != nil {
                NavigationView {
                    VStack {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(messages) { message in
                                    MessageBubble(message: message)
                                }
                                if isLoading {
                                    ProgressView()
                                        .padding()
                                }
                            }
                            .padding()
                        }
                        
                        HStack {
                            TextField("Type a message...", text: $inputText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .disabled(isLoading)
                            
                            Button(action: sendMessage) {
                                Image(systemName: "paperplane.fill")
                            }
                            .disabled(isLoading || inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                        .padding()
                    }
                    .navigationTitle("MobileChat")
                    .toolbar {
                        Button(action: { showingSettings = true }) {
                            Image(systemName: "gear")
                        }
                    }
                    .sheet(isPresented: $showingSettings) {
                        SettingsView(settings: settings) {
                            // Reset chat when model changes
                            messages = []
                            bot = nil
                            Task {
                                await loadModel()
                            }
                        }
                    }
                }
            } else {
                VStack {
                    Text("Loading AI Model...")
                    Text(settings.selectedModel.rawValue)
                        .font(.caption)
                        .foregroundColor(.gray)
                    ProgressView(value: progress) {
                        Text(String(format: "%.1f%%", progress * 100))
                    }
                    .padding()
                }
                .onAppear {
                    Task {
                        await loadModel()
                    }
                }
            }
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var settings: Settings
    let onModelChange: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Model Selection")) {
                    Picker("Model", selection: $settings.selectedModel) {
                        ForEach(ModelType.allCases, id: \.self) { model in
                            Text(model.rawValue).tag(model)
                        }
                    }
                    .onChange(of: settings.selectedModel) { _ in
                        dismiss()
                        onModelChange()
                    }
                }
                
                Section(header: Text("About")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Smollm (135M)")
                            .font(.headline)
                        Text("Smaller, faster model suitable for most tasks")
                            .font(.caption)
                        
                        Text("TinyLlama (1.1B)")
                            .font(.headline)
                        Text("Larger model with better comprehension but slower responses")
                            .font(.caption)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}

struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            
            Text(message.content)
                .padding()
                .background(message.isUser ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(message.isUser ? .white : .primary)
                .cornerRadius(16)
            
            if !message.isUser { Spacer() }
        }
    }
}

#Preview {
    ContentView()
}


