//
//  FavListView.swift
//  MetGallery
//
//  Created by yaxin on 2025-04-19.
//

import SwiftUI
import SwiftData
import UIKit

struct FavListView: View {
    @Environment(\.modelContext) private var context
    @Query private var aps: [Artpiece]
    @State private var showChartView: Bool = false
    @State private var searchText: String = ""
    
    struct SectionData: Identifiable {
        let id = UUID()
        let key: String
        let values: [Artpiece]
    }
    
    private var sectionList: [SectionData] {
        var dict = [String:[Artpiece]]()
        var sectionList = [SectionData]()
        for ap in aps {
            if ap.title.contains(searchText) || searchText.isEmpty {
                dict[ap.department, default:[]].append(ap)
            }
        }
        for (key, value) in dict {
            let newSection = SectionData(key: key, values: value)
            sectionList.append(newSection)
        }
        return sectionList.sorted {$0.key < $1.key}
    }
    
    private func deleteFav(from section: SectionData, at offsets: IndexSet) {
        for index in offsets {
            context.delete(section.values[index])
        }
        do {
            try context.save()
        } catch {
            print("Failed to delete ap: \(error)")
        }
    }
    
    var body: some View {
        Group {
            if aps.isEmpty {
                Text("You have not picked any favorite art pieces yet.")
            } else {
                NavigationStack {
                    List {
                        ForEach(sectionList) { sectionItem in
                            Section(header: Text(sectionItem.key)) {
                                ForEach(sectionItem.values, id: \.id) { ap in
                                    NavigationLink(value: ap) {
                                        HStack {
                                            if let data = ap.cachedThumbnail, let uiImage = UIImage(data: data) {
                                                Image(uiImage: uiImage)
                                                    .resizable()
                                                    .frame(width: 100, height: 100)
                                                    .scaledToFit()
                                                    .foregroundColor(.secondary)
                                            } else {
                                                Image(systemName: "photo")
                                                    .resizable()
                                                    .frame(width: 100, height: 100)
                                                    .scaledToFit()
                                                    .foregroundColor(.secondary)
                                            }
                                            VStack(alignment: .leading, spacing: 5) {
                                                HStack {
                                                    Text("Title: ")
                                                    Text("\(ap.title)")
                                                        .lineLimit(1)
                                                }
                                                HStack {
                                                    Text("Artist: ")
                                                    Text("\(ap.artist)")
                                                        .lineLimit(1)
                                                }
                                                HStack {
                                                    Text("Year: ")
                                                    Text("\(ap.year)")
                                                        .lineLimit(1)
                                                }
                                            }
                                            .font(.caption)
                                        }
                                    }
                                }
                                .onDelete { offsets in
                                    withAnimation {
                                        deleteFav(from: sectionItem, at: offsets)
                                    }
                                }
                            }
                        }
                        
                    }
                    .navigationTitle("Favorite List")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationDestination(for: Artpiece.self) { ap in
                        if let index = aps.sorted(by: { $0.department < $1.department }).firstIndex(of: ap) {
                            FavPageView(ap: ap, currentIndex: index)
                        }
                    }
                    .searchable(text: $searchText, placement: .navigationBarDrawer)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                showChartView.toggle()
                            } label: {
                                Image(systemName: "chart.pie")
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showChartView) {
            ChartView()
                .presentationDetents([.fraction(0.5)])
                .presentationDragIndicator(.visible)
        }
    }
}
