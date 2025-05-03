//
//  CollectionMenuView.swift
//  MetGallery
//
//  Created by yaxin on 2025-05-03.
//

import SwiftUI
import SwiftData

struct CollectionMenuView: View {
    @Environment(\.modelContext) private var context
    @Query private var collections: [APCollection]
    @State private var selectedCollections: Set<String>
    let ap: Artpiece
    
    init(ap: Artpiece) {
        self.ap = ap
        selectedCollections = Set(ap.collections.map {$0.name})
    }
    
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
        .onDisappear {
            for collection in collections {
                if selectedCollections.contains(collection.name) {
                    collection.apList.append(ap)
                } else {
                    collection.apList = collection.apList.filter {$0.id != ap.id}
                }
            }
            try? context.save()
        }
    }
}
