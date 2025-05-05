//
//  CollectionCreationView.swift
//  MetGallery
//
//

import SwiftUI
import SwiftData

struct CollectionCreationView: View {
    @Environment(\.modelContext) private var context
    @State private var inputText: String = ""
    @State private var errorMessage: String? = nil
    @Binding var isPresented: Bool
    @FocusState private var focused
    var body: some View {
        NavigationStack {
            Form {
                Text("Collection Name:")
                TextField("", text: $inputText)
                    .onChange(of: inputText) { _, newValue in
                        validateInput(text: newValue)
                    }
                    .focused($focused)
                    .lineLimit(1)
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        inputText = ""
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        defer {
                            isPresented = false
                            inputText = ""
                        }
                        do {
                            let collectionName = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
                            try createNewCollection(name: collectionName)
                        } catch {
                            print(error.localizedDescription)
                        }
                    }.disabled(errorMessage != nil)
                }
            }
            .padding()
        }
        .onAppear {
            focused = true
            validateInput(text: inputText)
        }
    }
    
    private func createNewCollection(name: String) throws {
        let collection = APCollection(name: name)
        context.insert(collection)
        try context.save()
    }
    
    private func validateInput(text: String) {
        errorMessage = text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Collection name cannot be empty" : nil
    }
}
