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
    @Environment(\.dismiss) private var dismiss
    @Query private var collections: [APCollection]
    @State private var selectedCollections: Set<String>
    @Binding var layerText: String?
    let ap: Artpiece
    
    init(ap: Artpiece, layerText: Binding<String?>) {
        self.ap = ap
        self._layerText = layerText
        selectedCollections = Set(ap.collections.map {$0.name})
    }
    
    var body: some View {
        VStack() {
            Spacer()
            Text("Add to collections")
            Spacer()
            Group {
                if collections.isEmpty {
                    ZStack {
                        Text("Please create a collection first")
                            .font(.title)
                            .padding()
                    }
                    Spacer()
                    Spacer()
                } else {
                    Group {
                        HStack {
                            Button {
                                layerText = "Cancelled"
                                dismiss()
                            } label: {
                                Image(systemName: "xmark.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25, height:25)
                                    .foregroundStyle(.red)
                            }
                            Spacer()
                            Button(action: {
                                defer {
                                    layerText = "Saved"
                                    dismiss()
                                }
                                for collection in collections {
                                    if selectedCollections.contains(collection.name) {
                                        if !collection.apList.contains(where: {$0.id == ap.id}){
                                            collection.apList.append(ap)
                                        }
                                    } else {
                                        collection.apList = collection.apList.filter {$0.id != ap.id}
                                    }
                                }
                                try? context.save()
                            }) {
                                Image(systemName: "checkmark.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25, height:25)
                                    .foregroundStyle(.green)
                            }
                        }
                        .padding()
                        ScrollView {
                            VStack {
                                ForEach(collections.sorted {$0.name < $1.name}, id: \.name) { collection in
                                    Toggle(isOn: Binding(get: {
                                        selectedCollections.contains(collection.name)
                                    }, set: { value in
                                        if value {
                                            selectedCollections.insert(collection.name)
                                        } else {
                                            selectedCollections.remove(collection.name)
                                        }
                                    })) {
                                        Text("\(collection.name)").lineLimit(1).truncationMode(.tail)
                                    }
                                    .tint(.green)
                                }
                            }
                            .padding(.horizontal, 15)
                        }
                    }
                    .interactiveDismissDisabled()
                }
            }
        }
    }
}
