//
//  ImageDetailView.swift
//  MetGallery
//
//  Created by yaxin on 2025-04-18.
//

import SwiftUI
import Foundation
import UIKit
import SwiftData

@MainActor
struct ImageDetailView: View {
    var DTO: ArtpieceDTO
    var apService: ArtpieceServiceProtocol
    @Query private var aps: [Artpiece]
    @State private var fetchTask: Task<Void, Never>?
    @State var highResImage: UIImage?
    @Binding var infoOn: Bool
    @Environment(\.modelContext) private var context
    
    var body: some View {
        Group {
            if let image = highResImage {
                ZoomableImageView(image: Image(uiImage: image), infoOn: $infoOn)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.secondary)
                    .aspectRatio(1, contentMode: .fit)
            }
        }
        .onAppear {
            fetchTask?.cancel()
            fetchTask = Task {
                try? await Task.sleep(nanoseconds: 800_000_000)
                guard !Task.isCancelled else { return }
                do {
                    highResImage = try await apService.fetchHighResImage(for: DTO.objectID, urlStr: DTO.primaryImage)
                } catch {
                    print("Failed to load image for \(DTO.objectID): \(error)")
                }
            }
        }
        .onDisappear {
            fetchTask?.cancel()
        }
    }
}
