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
    @State private var filterClicked: Bool = false
    @State private var currentlySelectedDepartment: String?
    
    struct SectionData: Identifiable {
        let id = UUID()
        let key: String
        let values: [Artpiece]
    }
    
    private var depList: [String] {
        Array(Set(aps.map {$0.department}))
    }
    
    private var sectionList: [SectionData] {
        var dict = [String:[Artpiece]]()
        var sectionList = [SectionData]()
        for ap in aps {
            if let currentlySelectedDepartment = currentlySelectedDepartment, ap.department != currentlySelectedDepartment {
                continue
            }
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
                                                    .scaledToFit()
                                                    .frame(width: 100, height: 100)
                                                    .foregroundColor(.secondary)
                                            } else {
                                                Image(systemName: "photo")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 100, height: 100)
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
                                    deleteFav(from: sectionItem, at: offsets)
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
                        ToolbarItem(placement: .topBarLeading) {
                                Button {
                                    showChartView.toggle()
                                } label: {
                                    Image(systemName: "chart.pie")
                                        .foregroundStyle(.white)
                                }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                filterClicked.toggle()
                            } label: {
                                FilterMenuView(departments: depList, selectedDepartment: $currentlySelectedDepartment)
                                    .foregroundStyle(.white)
                                    .opacity(depList.count >= 2 ? 1.0 : 0.5)
                            }
                            .disabled(depList.count < 2)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showChartView) {
            ChartView()
                .presentationDetents([.height(330)])
                .presentationDragIndicator(.visible)
        }
        .tint(.white)
    }
}

struct FilterMenuView: View {
    var departments: [String]
    @Binding var selectedDepartment: String?
    var body: some View {
        Menu {
            ForEach(departments.sorted {$0 < $1}, id: \.self) { department in
                Button {
                    selectedDepartment = selectedDepartment == department ? nil : department
                } label: {
                    FilterPopOverItemView(text: department, currentlySelectedDepartment: $selectedDepartment)
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
        }
    }
}



struct FilterPopOverItemView: View {
    var text: String
    @Binding var currentlySelectedDepartment: String?
    var body: some View {
        HStack(alignment: .center) {
            Text(text)
            if let currentlySelectedDepartment = currentlySelectedDepartment, currentlySelectedDepartment == text {
                Image(systemName: "checkmark")
            }
        }
    }
}
