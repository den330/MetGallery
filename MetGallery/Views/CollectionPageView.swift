//
//  CollectionPageView.swift
//  MetGallery
//
//  Created by yaxin on 2025-05-03.
//

import SwiftUI
import SwiftData
import InterfaceOrientation

struct CollectionPageView: View {
    let isPad = UIDevice.current.userInterfaceIdiom == .pad
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
                        CollectionDetailView(ap: ap, apService: ArtpieceService(context: context), infoOn: $showInfo)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                if let currentIndex = currentIndex, showInfo == true && currentIndex < sortedApList.count {
                    let ap = sortedApList[currentIndex]
                    VStack {
                        HStack(alignment: .center) {
                            Button {
                                openShare.toggle()
                            } label: {
                                Image(systemName: "square.and.arrow.up")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(.white)
                            }
                            .padding()
                            .background(Capsule().fill(.gray))
                            Spacer()
                        }
                        .padding(.top, 15)
                        List {
                            Text("Title: \(ap.title)").listRowBackground(Color.gray)
                            Text("Department: \(ap.department)").listRowBackground(Color.gray)
                            Text("Artist: \(ap.artist)").listRowBackground(Color.gray)
                            Text("Year: \(ap.year)").listRowBackground(Color.gray)
                        }
                        .scrollContentBackground(.hidden)
                        .lineLimit(3)
                        .transition(.asymmetric(
                            insertion: .scale,
                            removal: .slide
                        ))
                    }
                }
            }
            .background(
                showInfo ?
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color(red: 46/255, green: 59/255, blue: 78/255), location: 0.0),
                        .init(color: Color(red: 20/255, green: 30/255, blue: 45/255), location: 0.6),
                        .init(color: Color(red: 28/255, green: 28/255, blue: 30/255), location: 1.0)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea() : nil
            )
            .interfaceOrientations([showInfo && !isPad ? .portrait : .all])
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
                            .symbolEffect(.breathe)
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
