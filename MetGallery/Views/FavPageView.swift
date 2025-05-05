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
    @State private var showInfo = false
    @State private var showCollectionMenu = false
    @State private var layerText: String?
    @State private var shouldShowLayer: Bool = false
    let isPad = UIDevice.current.userInterfaceIdiom == .pad
    var ap: Artpiece
    
    init(ap: Artpiece, currentIndex: Int) {
        self.ap = ap
        self._currentIndex = State(initialValue: currentIndex)
    }
    
    var body: some View {
        VStack {
            TabView(selection: $currentIndex) {
                ForEach(Array(aps.enumerated()), id: \.1.id) { index, ap in
                    FavDetailView(ap: ap, apService: ArtpieceService(context: context), infoOn: $showInfo)
                        .tag(index)
                }
            }
            .tabViewStyle(
                PageTabViewStyle(indexDisplayMode: .automatic)
            )
            if showInfo {
                let currentAp = aps[currentIndex]
                VStack {
                    HStack(alignment: .center) {
                        Button(action: {
                            showCollectionMenu.toggle()
                        }, label: {
                            Image(systemName: "plus")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(.white)
                        })
                        .padding()
                        .background(
                            Capsule()
                                .fill(Color.gray))
                        Button {
                            showShare.toggle()
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(.white)
                        }
                        .padding()
                        .background(
                            Capsule()
                                .fill(Color.gray))
                        Spacer()
                    }
                    .padding(.top, 15)
                    List {
                        Text("Title: \(currentAp.title)")
                        Text("Department: \(currentAp.department)")
                        Text("Artist: \(currentAp.artist)")
                        Text("Year: \(currentAp.year)")
                    }
                }
                .lineLimit(2)
                .transition(.asymmetric(
                    insertion: .scale,
                    removal: .slide
                ))
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    withAnimation(.easeInOut) {
                        showInfo.toggle()
                    }
                }, label: {
                    Image(systemName: "exclamationmark.circle")
                        .symbolEffect(.breathe)
                })
            }
        }
        .overlay(alignment: .center) {
            if let layerText = layerText, shouldShowLayer {
                Text(layerText)
                    .font(.largeTitle)
                    .padding(.horizontal)
                    .background(.gray)
                    .clipShape(.rect(cornerRadius: 25))
                    .transition(.asymmetric(
                        insertion: .scale,
                        removal: .opacity
                    ))
            }
        }
        .sheet(isPresented: $showCollectionMenu) {
            CollectionMenuView(ap: aps[currentIndex], layerText: $layerText)
                .presentationDetents([.height(isPad ? 350 : 200)])
        }
        .sheet(isPresented: $showShare) {
            if let image = CacheManager.shared.image(for: aps[currentIndex].id) {
                ShareSheet(items: [image])
            } else {
                ShareSheet(items: [UIImage(data: aps[currentIndex].cachedThumbnail!)!])
            }
        }
        .onChange(of: layerText) {
            if layerText != nil {
                withAnimation(.easeInOut(duration: 0.5)) {
                    shouldShowLayer = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        shouldShowLayer = false
                        layerText = nil
                    }
                })
            }
        }
    }
}

