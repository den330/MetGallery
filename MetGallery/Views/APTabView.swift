//
//  APTabView.swift
//  MetGallery
//
//  Created by yaxin on 2025-04-19.
//

import SwiftUI

struct APTabView: View {
    @Environment(\.modelContext) private var context
    enum Tab { case gallery, favorites, collection }
    @State private var selectedTab: Tab = .gallery

    var body: some View {
        TabView(selection: $selectedTab) {
            GalleryView(viewModel: GalleryViewModel(apService: ArtpieceService(context: context)))
                .tabItem {
                    Image(systemName: "photo")
                }
                .tag(Tab.gallery)
            FavListView()
                .tabItem {
                    Image(systemName: "heart.fill")
                }
                .tag(Tab.favorites)
            APCollectionView()
                .tabItem {
                    Image(systemName: "folder.fill")
                }
                .tag(Tab.collection)
        }
        .tint(.white)
    }
}
