//
//  ContentView.swift
//  MetGallery
//
//  Created by yaxin on 2025-04-18.
//

import SwiftUI

struct ContentView: View {
    @State private var inputText = ""
    @State private var keywordToSubmit: String?
    @Environment(\.modelContext) private var context

    var body: some View {
        VStack {
            TextField("I am feeling...", text: $inputText)
                .onSubmit {
                    keywordToSubmit = inputText
                }
            GalleryView(keyword: $keywordToSubmit, viewModel: GalleryViewModel(apService: ArtpieceService(context: context)))
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
