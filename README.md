# MobileChat

A simple iOS chat application that runs a local LLM (Large Language Model) directly on your device. Built with SwiftUI and [LLM.swift](https://github.com/eastriverlee/LLM.swift).

## Features

- 🤖 Uses smollm-135M, a lightweight language model optimized for mobile devices
- 💾 Downloads the model once and caches it for future use
- 📱 Runs completely locally on your device - no internet needed after initial model download
- 💬 Clean, modern chat interface
- ⚡️ Fast responses thanks to the optimized model size

## Requirements

- iOS 16.0 or later
- Xcode 15.0 or later
- ~300MB of storage space for the model

## Getting Started

1. Clone the repository
2. Open the project in Xcode
3. Build and run on your iOS device or simulator
4. The app will automatically download the model on first launch

## Technical Details

- Built using SwiftUI for the UI
- Uses LLM.swift library for local model inference
- Model: smollm-135M-instruct-v0.2 (Q8_0 quantized version)
- Implements ChatML template for consistent chat formatting

## Privacy

All chat interactions happen locally on your device. The only network connection is made during the initial model download from HuggingFace. 