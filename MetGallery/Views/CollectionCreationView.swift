//
//  CollectionCreationView.swift
//  MetGallery
//
//  Created by yaxin on 2025-05-03.
//

import SwiftUI
import SwiftData

struct CollectionCreationView: View {
    @Environment(\.modelContext) private var context
    @State private var inputText: String = ""
    @Binding var isPresented: Bool
    var body: some View {
        NavigationStack {
            VStack {
                Text("Collection Name:")
                TextField("", text: $inputText)
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
                            try createNewCollection(name: inputText)
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
    
    private func createNewCollection(name: String) throws {
        let collection = APCollection(name: name)
        context.insert(collection)
        try context.save()
    }
}

//#Preview {
//    CollectionCreationView()
//}
