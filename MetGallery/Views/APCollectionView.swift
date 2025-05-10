//
//  APCollectionView.swift
//  MetGallery
//
//  Created by yaxin on 2025-05-03.
//

import SwiftUI
import SwiftData

struct PulsatingCirclesView: View {
    var body: some View {
        TimelineView(.animation) { viewContext in
            Canvas { ctx, size in
                let t = viewContext.date.timeIntervalSinceReferenceDate
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                
                for i in 0..<100 {
                    let angle = Double(i) / 100 * .pi * 2
                    let radius = CGFloat(50 + 30 * sin(t + Double(i)))
                    let p = CGPoint(
                        x: center.x + cos(angle) * radius,
                        y: center.y + sin(angle) * radius
                    )
                    let circle = Path(ellipseIn: CGRect(origin: p, size: .init(width: 5, height: 5)))
                    ctx.fill(circle, with: .color(.white))
                }
            }
        }
    }
}

struct APCollectionView: View {
    @Query private var collections: [APCollection]
    @State private var presentCreationSheet = false
    @State private var navigationPath: NavigationPath = .init()
    @State private var searchText: String = ""

    private var filteredCollctions: [APCollection] {
        if !searchText.isEmpty {
            return collections.filter {$0.name.lowercased().contains(searchText.lowercased())}
        }
        return collections
    }
    
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
                                ForEach(Array(filteredCollctions.sorted {$0.name < $1.name}.enumerated()), id: \.1.name) { index, collection in
                                    NavigationLink(value: collection) {
                                        VStack {
                                            if let firstAp = collection.apList.sorted(by: { $0.title < $1.title }).first, let firstImageData = firstAp.cachedThumbnail, let firstImage = UIImage(data: firstImageData) {
                                                Image(uiImage: firstImage)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .overlay {
                                                        Rectangle()
                                                            .stroke(LinearGradient(colors:
                                                                                    [Color("FrameColor1"),
                                                                                     Color("FrameColor2"),
                                                                                     Color("FrameColor1"),
                                                                                     Color("FrameColor2")], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 5)
                                                            .shadow(radius: 5)
                                                    }
                                            } else {
                                                Image(systemName: "photo")
                                                    .resizable()
                                                    .scaledToFit()
                                            }
                                            Text("\(collection.name)").lineLimit(1).truncationMode(.tail)
                                        }
                                        .padding(.vertical, isPad ? 10 : 5)
                                        .frame(width: geometry.size.width / CGFloat(columnCount + 1))
                                        .frame(maxHeight: 200)
                                    }
                                }
                            }
                        }
                    } else {
                        ZStack {
                            VStack {
                                PulsatingCirclesView()
                                    .frame(width: 180, height: 180)
                                Text("You do not have any collection yet.")
                                    .font(.title)
                                    .padding(20)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .background(
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color(red: 46/255, green: 59/255, blue: 78/255), location: 0.0),
                            .init(color: Color(red: 20/255, green: 30/255, blue: 45/255), location: 0.6),
                            .init(color: Color(red: 28/255, green: 28/255, blue: 30/255), location: 1.0)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                )
                .navigationTitle(Text("Collections"))
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: APCollection.self, destination: { collection in
                    CollectionGalleryView(collection: collection)
                })
                .searchable(text: $searchText, placement: .navigationBarDrawer)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            presentCreationSheet.toggle()
                        }, label: {
                            Image(systemName: "plus")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
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
