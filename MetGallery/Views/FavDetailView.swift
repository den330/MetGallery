import SwiftUI
import UIKit

struct FavDetailView: View {
    var ap: Artpiece
    var apService: ArtpieceService
    @State private var fetchTask: Task<Void, Never>?
    @State private var fetchedHighResImage: UIImage?
    @Binding var infoOn: Bool
    var body: some View {
        Group {
            ZStack {
                if let highResImage = fetchedHighResImage {
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
        }
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
        .onDisappear {
            fetchTask?.cancel()
        }
    }
}
