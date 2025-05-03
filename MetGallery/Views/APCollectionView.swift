//
//  APCollectionView.swift
//  MetGallery
//
//  Created by yaxin on 2025-05-03.
//

import SwiftUI
import SwiftData

struct APCollectionView: View {
    @Query private var collections: [APCollection]
    @State private var presentCreationSheet = false

    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            let isPad = UIDevice.current.userInterfaceIdiom == .pad
            let columnCount = (isPad && isLandscape) ? 4 : 3
            let columns = Array(repeating: GridItem(.flexible()), count: columnCount)
            NavigationStack{
                VStack{
                    Button(action: {
                        presentCreationSheet.toggle()
                    }, label: {
                        Text("Create a new collection")
                    })
                    ScrollView {
                        LazyVGrid(columns: columns) {
                            ForEach(Array(collections.enumerated()), id: \.1.name) { index, collection in
                                VStack {
                                    if let firstAp = collection.apList.first, let firstImageData = firstAp.cachedThumbnail, let firstImage = UIImage(data: firstImageData) {
                                        Image(uiImage: firstImage)
                                            .resizable()
                                            .scaledToFit()
                                    } else {
                                        Image(systemName: "photo")
                                            .resizable()
                                            .scaledToFit()
                                    }
                                    Text("\(collection.name)")
                                }
                                .padding()
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $presentCreationSheet) {
                CollectionCreationView(isPresented: $presentCreationSheet)
            }
        }
    }
}
