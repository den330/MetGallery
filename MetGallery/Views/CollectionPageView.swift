//
//  CollectionPageView.swift
//  MetGallery
//
//  Created by yaxin on 2025-05-03.
//

import SwiftUI
import SwiftData

struct CollectionPageView: View {
    @Environment(\.modelContext) private var context
    @Binding var currentIndex: Int?
    @State private var openShare: Bool = false
    let collection: APCollection
    var sortedApList: [Artpiece] {
        collection.apList.sorted {$0.title < $1.title}
    }
    
    var body: some View {
        NavigationStack {
            TabView(selection: $currentIndex) {
                ForEach(Array(sortedApList.enumerated()), id: \.1.id) { index, ap in
                    CollectionDetailView(ap: ap, apService: ArtpieceService(context: context), openShare: $openShare)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        currentIndex = nil
                    }, label: {
                        Image(systemName: "xmark")
                    })
                }
                
                ToolbarItem(placement: .destructiveAction) {
                    Button(action: {
                        if let currentIndex = currentIndex {
                            let ap = sortedApList[currentIndex]
                            defer {
                                self.currentIndex = nil
                            }
                            do {
                                context.delete(ap)
                                try context.save()
                            } catch {
                                print("delete error \(error.localizedDescription)")
                            }
                        }
                    }, label: {
                        Image(systemName: "trash")
                    })
                }
            }
        }
        .sheet(isPresented: $openShare) {
            if let currentIndex = currentIndex, let image = CacheManager.shared.image(for: sortedApList[currentIndex].id){
                ShareSheet(items: [image])
            }
        }
    }
}
