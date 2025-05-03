//
//  CollectionGalleryView.swift
//  MetGallery
//
//  Created by yaxin on 2025-05-03.
//

import SwiftUI
import SwiftData

struct CollectionGalleryView: View {
    
    @State private var collection: APCollection
    @State private var selectedIndex: Int?
    
    init(collection: APCollection) {
        self._collection = State(initialValue: collection)
    }
    
    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            let isPad = UIDevice.current.userInterfaceIdiom == .pad
            let columnCount = (isPad && isLandscape) ? 4 : 3
            let columns = Array(repeating: GridItem(.flexible()), count: columnCount)
            VStack(alignment: .center) {
                Text("\(collection.name)")
                    .font(.title)
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
    }
}
