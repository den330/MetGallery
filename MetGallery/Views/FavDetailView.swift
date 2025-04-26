//
//  FavDetailView.swift
//  MetGallery
//
//  Created by yaxin on 2025-04-19.
//

import SwiftUI
import UIKit

struct FavDetailView: View {
    var ap: Artpiece
    var apService: ArtpieceService
    @State private var fetchTask: Task<Void, Never>?
    @State var showInstructionLayer: Bool = false
    @State private var fetchedHighResImage: UIImage?
    var body: some View {
        Group {
            ZStack(alignment: .bottom) {
                if let highResImage = fetchedHighResImage {
                    Image(uiImage: highResImage)
                        .resizable()
                        .scaledToFit()
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
                if showInstructionLayer {
                    Text("Department: \(ap.department)").frame(maxWidth: .infinity).background(.black).foregroundStyle(.white)
                }
            }
        }
        .padding(30)
        .onAppear {
            Task {
                fetchTask?.cancel()
                fetchTask = Task {
                    try? await Task.sleep(nanoseconds: 800_000_000)
                    guard !Task.isCancelled else { return }
                    do {
                        guard let urlStr = ap.imageUrl?.absoluteString else {
                            return
                        }
                        fetchedHighResImage = try await apService.fetchHighResImage(for: ap.id, urlStr: urlStr)
                    } catch {
                        print("Failed to load image for \(ap.id): \(error)")
                    }
                }
            }
        }
        .onTapGesture {
            showInstructionLayer.toggle()
        }
    }
}

//#Preview {
//    FavDetailView()
//}
