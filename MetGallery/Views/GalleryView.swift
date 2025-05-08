//
//  GalleryView.swift
//  MetGallery
//
//  Created by yaxin on 2025-04-18.
//

import SwiftUI
import SwiftData
import Foundation

struct GalleryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query private var artPieces: [Artpiece]
    @State var keyword: String?
    @State var inputText: String = ""
    @State var imageTapped: Int?
    @State var selectedIndex: Int?
    @State var appearedOnce = false
    @State var dotCount = 0
    @StateObject var viewModel: GalleryViewModel
    
    private var promptText: String {
        let baseText = "I am feeling"
        let dots = String(repeating: ".", count: dotCount)
        return baseText.appending(dots)
    }
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            let isPad = UIDevice.current.userInterfaceIdiom == .pad
            let columnCount = (isPad && isLandscape) ? 4 : 3
            let columns = Array(repeating: GridItem(.flexible()), count: columnCount)
            VStack(alignment: .center) {
                TextField("", text: $inputText, prompt: Text(promptText)
                    .foregroundColor(.gray) )
                    .foregroundColor(.blue)
                    .font(.system(size: 16, weight: .bold))
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .onSubmit {
                        keyword = inputText
                    }
                ScrollView {
                    LazyVGrid(columns: columns) {
                        ForEach(Array(viewModel.artpieceDTOList.enumerated()), id: \.1.objectID) { dtx, artpieceDTO in
                            Group {
                                if let url = URL(string: artpieceDTO.primaryImageSmall) {
                                    ZStack(alignment: .topTrailing){
                                        AsyncImage(url: url) { phase in
                                            switch phase {
                                            case .empty:
                                                Color.gray.opacity(0.1)
                                                    .aspectRatio(1, contentMode: .fit)
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .scaledToFit()
                                            case .failure:
                                                Image(systemName: "photo")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .foregroundColor(.secondary)
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                        Image(systemName: artPieces.map {$0.id}.contains(artpieceDTO.objectID) ? "heart.fill" : "heart")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20, height: 20)
                                            .padding()
                                            .foregroundStyle(.red)
                                    }
                                    .overlay {
                                        Rectangle()
                                            .stroke(LinearGradient(colors:
                                                                    [Color("FrameColor1"),
                                                                     Color("FrameColor2"),
                                                                     Color("FrameColor1"),
                                                                     Color("FrameColor2")], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 5)
                                            .shadow(radius: 5)
                                    }
                                    .onAppear {
                                        if artpieceDTO.objectID == viewModel.artpieceDTOList.last?.objectID {
                                            Task {
                                                await viewModel.fetchNextBatch()
                                            }
                                        }
                                    }
                                    .onTapGesture {
                                        selectedIndex = dtx
                                    }
                                } else {
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.secondary)
                                        .aspectRatio(1, contentMode: .fit)
                                }
                            }
                            .frame(width: geometry.size.width / CGFloat(columnCount + 1), height: 200)
                        }
                    }
                }
                .overlay {
                    switch viewModel.searchStatus {
                    case .searchNotStarted:
                        Text("Waiting for search input")
                    case .searching:
                        Text("Search in progress")
                    case .searchFoundResult:
                        EmptyView()
                    case .searchFoundNothing:
                        Text("Did not find anything")
                    }
                }
                .alert("Error Occurs", isPresented: Binding(get: {viewModel.error != nil}, set: { _, _ in viewModel.error = nil })) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                } message: {
                    if let error = viewModel.error {
                        Text("Error: \(error.localizedDescription)")
                            .foregroundStyle(.black)
                    }
                }
                .onChange(of: keyword) {
                    Task {
                        print("keyword changes")
                        if let keyword = keyword {
                            await viewModel.generateInitialBatch(with: keyword)
                        }
                    }
                }
                .onAppear {
                    if !appearedOnce {
                        keyword = RandomWordGenerator.generateRandomWord()
                        appearedOnce = true
                    }
                }
                .onReceive(timer) { _ in
                    dotCount = (dotCount + 1) % 4
                }
                .fullScreenCover(isPresented: Binding(
                    get: {selectedIndex != nil},
                    set: {if !$0 { selectedIndex = nil } }
                )) {
                    ImagePageView(currentIndex: $selectedIndex, DTOList: $viewModel.artpieceDTOList, apService: ArtpieceService(context: context))
                    }
            }
            .padding()
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
            .foregroundStyle(.white)
        }
    }
}
