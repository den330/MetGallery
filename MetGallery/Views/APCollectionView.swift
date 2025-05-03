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
    @State private var navigationPath: NavigationPath = .init()


    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            let isPad = UIDevice.current.userInterfaceIdiom == .pad
            let columnCount = (isPad && isLandscape) ? 4 : 3
            let columns = Array(repeating: GridItem(.flexible()), count: columnCount)
            NavigationStack(path: $navigationPath){
                Group {
                    if !collections.isEmpty {
                        ScrollView {
                            LazyVGrid(columns: columns) {
                                ForEach(Array(collections.sorted {$0.name < $1.name}.enumerated()), id: \.1.name) { index, collection in
                                    NavigationLink(value: collection) {
                                        VStack {
                                            if let firstAp = collection.apList.sorted(by: { $0.title < $1.title }).first, let firstImageData = firstAp.cachedThumbnail, let firstImage = UIImage(data: firstImageData) {
                                                Image(uiImage: firstImage)
                                                    .resizable()
                                                    .scaledToFit()
                                            } else {
                                                Image(systemName: "photo")
                                                    .resizable()
                                                    .scaledToFit()
                                            }
                                            Text("\(collection.name)").lineLimit(1).truncationMode(.tail)
                                        }
                                        .padding()
                                    }
                                }
                            }
                        }
                    } else {
                        ZStack {
                            Text("You do not have any collection yet.")
                                .font(.title)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .navigationDestination(for: APCollection.self, destination: { collection in
                    CollectionGalleryView(collection: collection)
                })
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            presentCreationSheet.toggle()
                        }, label: {
                            Image(systemName: "plus")
                                .foregroundStyle(.white)
                        })
                    }
                }
            }
            .tint(.white)
            .sheet(isPresented: $presentCreationSheet) {
                CollectionCreationView(isPresented: $presentCreationSheet)
                    .presentationDetents([.medium])
            }
        }
    }
}
