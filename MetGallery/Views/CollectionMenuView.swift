//
//  CollectionMenuView.swift
//  MetGallery
//
//  Created by yaxin on 2025-05-03.
//

import SwiftUI
import SwiftData

struct CollectionMenuView: View {
    @Query private var collections: [APCollection]
    @State private var selectedCollections: Set<String> = []
    let ap: Artpiece
    var body: some View {
        VStack() {
            Spacer()
            Text("Add to collections")
            Spacer()
            ScrollView {
                VStack {
                    ForEach(collections.sorted {$0.name < $1.name}, id: \.name) { collection in
                        Toggle("\(collection.name)", isOn: Binding(get: {
                            selectedCollections.contains(collection.name)
                        }, set: { value in
                            if value {
                                selectedCollections.insert(collection.name)
                            } else {
                                selectedCollections.remove(collection.name)
                            }
                        }))
                    }
                }
                .padding(.horizontal, 15)
            }
        }
        .frame(maxHeight: 150)
        .onDisappear {
            for collection in collections {
                if selectedCollections.contains(collection.name) {
                    collection.apList.append(ap)
                }
            }
        }
    }
}
