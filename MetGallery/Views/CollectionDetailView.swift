//
//  CollectionDetailView.swift
//  MetGallery
//
//  Created by yaxin on 2025-05-03.
//

import SwiftUI

struct CollectionDetailView: View {
    let ap: Artpiece
    var apService: ArtpieceServiceProtocol
    @State private var fetchTask: Task<Void, Never>?
    @State private var highResImage: UIImage?
    @Binding var infoOn: Bool
    @Environment(\.modelContext) private var context

    var body: some View {
        ZStack {
            if let highResImage = highResImage {
                ZoomableImageView(image: Image(uiImage: highResImage), infoOn: infoOn)
            } else {
                if let data = ap.cachedThumbnail, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.secondary)
                }
            }
        }
        .onAppear {
            fetchTask?.cancel()
            fetchTask = Task {
                try? await Task.sleep(nanoseconds: 800_000_000)
                guard !Task.isCancelled else { return }
                if let imageUrl = ap.imageUrl {
                    do {
                       highResImage = try await apService.fetchHighResImage(for: ap.id, urlStr: imageUrl.absoluteString)
                    } catch {
                        print("Failed to fetch high res image: \(error)")
                    }
                }
            }
        }
        .onDisappear {
            fetchTask?.cancel()
        }
    }
}
