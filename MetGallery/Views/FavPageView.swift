//
//  FavPageView.swift
//  MetGallery
//
//

import SwiftUI
import SwiftData
import InterfaceOrientation

struct FavPageView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
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
                PageTabViewStyle(indexDisplayMode: .never)
            )
            if showInfo && currentIndex < aps.count {
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
                        Text("Title: \(currentAp.title)").listRowBackground(Color.gray)
                        Text("Department: \(currentAp.department)").listRowBackground(Color.gray)
                        Text("Artist: \(currentAp.artist)").listRowBackground(Color.gray)
                        Text("Year: \(currentAp.year)").listRowBackground(Color.gray)
                        if let linkResource = currentAp.linkResource, let url = URL(string: linkResource), !linkResource.isEmpty {
                            HStack {
                                Text("To know more:")
                                Link(destination: url, label: {
                                    Text("Check this artpiece on the official site")
                                        .font(.subheadline)
                                        .bold()
                                        .underline()
                                })
                            }.listRowBackground(Color.gray)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
                .transition(.asymmetric(
                    insertion: .scale,
                    removal: .slide
                ))
            }
        }
        .onDisappear {
            dismiss()
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

