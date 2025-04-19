//
//  GalleryView.swift
//  MetGallery
//
//  Created by yaxin on 2025-04-18.
//

import SwiftUI
import SwiftData
import Foundation

struct GalleryView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var keyword: String?
    @StateObject var viewModel: GalleryViewModel
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(viewModel.artpieceDTOList, id: \.objectID) { artpieceDTO in
                    if let url = URL(string: artpieceDTO.primaryImageSmall) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                Color.gray.opacity(0.1)
                                    .aspectRatio(1, contentMode: .fit)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .clipped()
                                    .aspectRatio(1, contentMode: .fit)
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.secondary)
                                    .aspectRatio(1, contentMode: .fit)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .onAppear {
                            if artpieceDTO.objectID == viewModel.artpieceDTOList.last?.objectID {
                                Task {
                                    await viewModel.fetchNextBatch()
                                }
                            }
                        }
                    }
                }
            }
        }
        .overlay {
            switch viewModel.searchStatus {
            case .searchNotStarted:
                Text("Waiting for search input")
            case .searching:
                Text("Search in progress")
            case .searchFoundResult:
                EmptyView()
            case .searchFoundNothing:
                Text("Did not find anything")
            }
        }
        .alert("Error", isPresented: Binding(get: {viewModel.error != nil}, set: { _, _ in viewModel.error = nil })) {
            Button("Cancel", role: .cancel) {
                dismiss()
            }
        }
        .onChange(of: keyword) {
            Task {
                if let keyword = keyword {
                    await viewModel.generateInitialBatch(with: keyword)
                }
            }
        }
    }
}

//#Preview {
//    GalleryView()
//}
