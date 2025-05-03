//
//  CollectionGalleryView.swift
//  MetGallery
//
//  Created by yaxin on 2025-05-03.
//

import SwiftUI
import SwiftData

struct CollectionGalleryView: View {
    
    @Query private var aps: [Artpiece]
    @State var collection: APCollection
    @State private var selectedIndex: Int?
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var showCollectionDeleteAlert = false
    @State private var redrawTrigger = false
    
    init(collection: APCollection) {
        _collection = State(initialValue: collection)
    }
    
    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            let isPad = UIDevice.current.userInterfaceIdiom == .pad
            let columnCount = (isPad && isLandscape) ? 4 : 3
            let columns = Array(repeating: GridItem(.flexible()), count: columnCount)
            Group {
                if !collection.apList.isEmpty{
                    ScrollView {
                        LazyVGrid(columns: columns) {
                            ForEach(Array(collection.apList.sorted {$0.title < $1.title}.enumerated()), id: \.1.id) { index, ap in
                                Group {
                                    if let data = ap.cachedThumbnail, let uiimage = UIImage(data: data) {
                                        Image(uiImage: uiimage)
                                            .resizable()
                                            .scaledToFit()
                                    } else {
                                        Image(systemName: "photo")
                                            .resizable()
                                            .scaledToFit()
                                    }
                                }
                                .onTapGesture {
                                    selectedIndex = index
                                }
                            }
                        }
                        .padding()
                    }
                } else {
                    ZStack(alignment: .center) {
                        Text("There is no image added to this collection.")
                            .font(.title)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button(action: {
                    showCollectionDeleteAlert.toggle()
                }, label: {
                    Image(systemName: "trash")
                        .tint(.red)
                })
            }
        }
        .fullScreenCover(isPresented: Binding(get: {
            selectedIndex != nil
        }, set: { newValue in
            if !newValue {
                selectedIndex = nil
            }
        }), content: {
            CollectionPageView(currentIndex: $selectedIndex, collection: collection)
        })
        .alert("Delete Collection", isPresented: $showCollectionDeleteAlert, actions: {
            Button("Delete", role: .destructive) {
                context.delete(collection)
                try? context.save()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }, message: {
            Text("Are you sure you want to delete this collection?")
        })
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(collection.name)
                    .font(.system(size: 40, weight: .bold))
            }
        }
        .onChange(of: aps) {
            for ap in aps {
                if ap.collections.contains(collection) {
                    return
                }
            }
            dismiss()
        }
    }
}
