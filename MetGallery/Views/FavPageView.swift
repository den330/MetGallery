//
//  FavPageView.swift
//  MetGallery
//
//  Created by yaxin on 2025-04-26.
//

import SwiftUI
import SwiftData

struct FavPageView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\Artpiece.department, order: SortOrder.forward)]) private var aps: [Artpiece]
    @State var currentIndex: Int
    @State private var showShare = false
    var ap: Artpiece
    
    init(ap: Artpiece, currentIndex: Int) {
        self.ap = ap
        self._currentIndex = State(initialValue: currentIndex)
    }
    
    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(aps.enumerated()), id: \.1.id) { index, ap in
                FavDetailView(ap: ap, apService: ArtpieceService(context: context), openShareSheet: $showShare)
                    .tag(index)
            }
        }
        .tabViewStyle(
            PageTabViewStyle(indexDisplayMode: .automatic)
        )
        .sheet(isPresented: $showShare) {
            if let image = CacheManager.shared.image(for: aps[currentIndex].id) {
                ShareSheet(items: [image])
            } else {
                ShareSheet(items: [UIImage(data: aps[currentIndex].cachedThumbnail!)!])
            }
        }
    }
}

