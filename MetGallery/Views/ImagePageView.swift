//
//  ImagePageView.swift
//  MetGallery
//
//  Created by yaxin on 2025-04-19.
//

import SwiftUI
import SwiftData

struct ImagePageView: View {
    @Environment(\.modelContext) private var context
    @Query private var artPieces: [Artpiece]
    @Binding var currentIndex: Int?
    @State private var showHint = false
    @State private var showInfo = false
    @AppStorage("hasSeenImageDetailHint") private var hasSeenImageDetailHint: Bool = false
    @Binding var DTOList: [ArtpieceDTO]
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet: Bool = false
    var apService: ArtpieceServiceProtocol
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    TabView(selection: $currentIndex) {
                        ForEach(Array(DTOList.enumerated()), id: \.1.objectID) { index, dto in
                            ImageDetailView(DTO: dto, apService: ArtpieceService(context: context), infoOn: $showInfo)
                                .tag(index)
                        }
                    }.tabViewStyle(
                        PageTabViewStyle(indexDisplayMode: .automatic)
                    )
                    .onAppear {
                        showHint = !hasSeenImageDetailHint
                    }
                    .disabled(showHint)
                    if let currentIndex = currentIndex, showInfo {
                        var currentDTO = DTOList[currentIndex]
                        VStack {
                            HStack(alignment: .center) {
                                Image(systemName: artPieces.contains { $0.id == currentDTO.objectID } ? "heart.fill" : "heart")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .padding()
                                    .background (
                                        Capsule().fill(.gray)
                                    )
                                    .foregroundStyle(.red)
                                    .symbolEffect(.bounce)
                                    .onTapGesture {
                                        currentDTO.isFav = !(currentDTO.isFav ?? false)
                                        DTOList[currentIndex] = currentDTO
                                        do {
                                            if currentDTO.isFav ?? false {
                                                let ap = Artpiece.fromDTO(currentDTO)
                                                Task {
                                                    do {
                                                        ap.cachedThumbnail = try await apService.fetchLowResImageData(for: currentDTO.objectID, urlStr: currentDTO.primaryImageSmall)
                                                    } catch {
                                                        print("low res image save fails \(error)")
                                                    }
                                                    context.insert(ap)
                                                    try context.save()
                                                }
                                            } else {
                                                let objID = currentDTO.objectID
                                                let fetchRequest = FetchDescriptor<Artpiece>(
                                                    predicate: #Predicate { $0.id == objID }
                                                )
                                                if let ap = try context.fetch(fetchRequest).first {
                                                    context.delete(ap)
                                                    try context.save()
                                                }
                                            }
                                        } catch {
                                            print("\(error)")
                                        }
                                    }
                                Button {
                                    showShareSheet.toggle()
                                } label: {
                                    Image(systemName: "square.and.arrow.up")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                        .foregroundStyle(.white)
                                }
                                .padding()
                                .background (
                                    Capsule().fill(.gray)
                                )
                                Spacer()
                            }
                            .padding(.top, 15)
                            List {
                                Text("Title: \(currentDTO.title)")
                                Text("Department: \(currentDTO.department)")
                                Text("Artist: \(currentDTO.artistDisplayName)")
                                Text("Year: \(currentDTO.objectDate)")
                            }
                        }
                        .lineLimit(2)
                        .transition(.asymmetric(
                            insertion: .scale,
                            removal: .slide
                        ))
                    }
                }
                .zIndex(0)
                if showHint {
                    ImageDetailHintOverlay(showHint: $showHint) {
                        hasSeenImageDetailHint = true
                    }
                    .transition(.opacity)
                    .zIndex(1)
                }
            }
            .animation(.easeInOut(duration: 1), value: showHint)
            .animation(.easeInOut(duration: 0.5), value: showInfo)
            .sheet(isPresented: $showShareSheet) {
                if let currentIndex = currentIndex, let image = CacheManager.shared.image(for: DTOList[currentIndex].objectID){
                    ShareSheet(items: [image])
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height:20)
                    })
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showInfo.toggle()
                    }, label: {
                        Image(systemName: "exclamationmark.circle")
                            .symbolEffect(.breathe)
                            .scaledToFit()
                            .frame(width: 20, height:20)
                    })
                }
            }
        }
    }
}
