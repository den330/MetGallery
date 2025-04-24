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
    @State var isFav = false
    @Environment(\.modelContext) private var context
    
    var body: some View {
        Group {
            if let image = highResImage {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .padding()
                    Image(systemName: isFav ? "heart.fill" : "heart")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .padding(25)
                        .foregroundStyle(.red)
                        .onTapGesture {
                            isFav.toggle()
                        }
                }
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.secondary)
                    .aspectRatio(1, contentMode: .fit)
            }
        }
        .onAppear {
            isFav = aps.map{$0.id}.contains(DTO.objectID)
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
        .onChange(of: isFav) {
            do {
                if isFav {
                    let ap = Artpiece.fromDTO(DTO)
                    Task {
                        do {
                            ap.cachedThumbnail = try await apService.fetchLowResImageData(for: DTO.objectID, urlStr: DTO.primaryImageSmall)
                        } catch {
                            print("low res image save fails \(error)")
                        }
                        context.insert(ap)
                        try context.save()
                    }
                } else {
                    let objID = DTO.objectID
                    let fetchRequest = FetchDescriptor<Artpiece>(
                        predicate: #Predicate { $0.id == objID }
                    )
                    if let ap = try context.fetch(fetchRequest).first {
                        context.delete(ap)
                        try context.save()
                    }
                }
            } catch {
                print("\(error)")
            }
        }
        .onDisappear {
            fetchTask?.cancel()
        }
    }
}
