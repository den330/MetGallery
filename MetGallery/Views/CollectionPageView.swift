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
    @State private var showInfo = false
    let collection: APCollection
    var sortedApList: [Artpiece] {
        collection.apList.sorted {$0.title < $1.title}
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                TabView(selection: $currentIndex) {
                    ForEach(Array(sortedApList.enumerated()), id: \.1.id) { index, ap in
                        CollectionDetailView(ap: ap, apService: ArtpieceService(context: context), openShare: $openShare)
                            .tag(index)
                    }
                }
                .padding(.vertical, 20)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                if let currentIndex = currentIndex, showInfo == true {
                    let ap = sortedApList[currentIndex]
                    List {
                        Text("Title: \(ap.title)")
                        Text("Department: \(ap.department)")
                        Text("Artist: \(ap.artist)")
                        Text("Year: \(ap.year)")
                    }
                    .lineLimit(2)
                    .transition(.asymmetric(
                        insertion: .scale,
                        removal: .slide
                    ))
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        currentIndex = nil
                    }, label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height:20)
                    })
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showInfo.toggle()
                        }
                    }, label: {
                        Image(systemName: "exclamationmark.circle")
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
                                collection.apList.removeAll { $0.id == ap.id }
                                try context.save()
                            } catch {
                                print("delete error \(error.localizedDescription)")
                            }
                        }
                    }, label: {
                        Image(systemName: "trash")
                            .tint(.red)
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
