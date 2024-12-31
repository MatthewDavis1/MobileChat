//
//  ContentView.swift
//  MobileChat
//
//  Created by Matt Davis on 12/30/24.
//

import SwiftUI

struct ContentView: View {
    @State private var bot: ChatBot? = nil
    @State private var messages: [Message] = []
    @State private var inputText = ""
    @State private var progress: CGFloat = 0
    @State private var isLoading = false
    
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
    
    var body: some View {
        if let bot {
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
        } else {
            VStack {
                Text("Loading AI Model...")
                ProgressView(value: progress) {
                    Text(String(format: "%.1f%%", progress * 100))
                }
                .padding()
            }
            .onAppear {
                Task {
                    bot = await ChatBot(updateProgress)
                }
            }
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
