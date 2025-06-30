//
//  GalleryView.swift
//  MetGallery
//
//  Created by yaxin on 2025-04-18.
//

import SwiftUI
import SwiftData
import Foundation
import InterfaceOrientation

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
    @State var deadline: Date = Date()
    @StateObject var viewModel: GalleryViewModel
    @State private var adReady = false
    @State private var countdown: Int = 0
    
    private var promptText: String {
        let baseText = "I am feeling"
        let dots = String(repeating: ".", count: dotCount)
        return baseText.appending(dots)
    }
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            let countdownTotal = 60.0
            let isLandscape = geometry.size.width > geometry.size.height
            let isPad = UIDevice.current.userInterfaceIdiom == .pad
            let columnCount = (isPad && isLandscape) ? 4 : isPad ? 3 : 2
            let columns = Array(repeating: GridItem(.flexible()), count: columnCount)
            VStack(alignment: .center) {
                TextField("", text: $inputText, prompt: Text(promptText)
                    .foregroundColor(.gray))
                    .foregroundColor(.blue)
                    .font(.system(size: 16, weight: .bold))
                    .padding()
                    .overlay(
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                            if countdown > 0 {
                                Color.black.opacity(0.3)
                                    .cornerRadius(8)
                                HStack(spacing: 6) {
                                    Image(systemName: "clock.fill")
                                        .foregroundColor(.white)
                                    Text("Wait for \(countdown)s before making another search.")
                                        .foregroundColor(.white)
                                        .font(.footnote.weight(.semibold))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Capsule())
                            }
                        }
                    )
                    .disabled(countdown > 0)
                    .onSubmit {
                        deadline = Date.now.addingTimeInterval(countdownTotal)
                        keyword = inputText
                    }
                
                AdView(adUnitID: "ca-app-pub-9748412059994439/1871000733", adReady: $adReady, isPad: isPad)
                    .frame(width: isPad ? 800 : 320, height: isPad ? 60 : 50)
                    .padding(.bottom, adReady ? 15 : -50)
                ScrollView {
                    ZStack {
                        LazyVGrid(columns: columns) {
                            ForEach(Array(viewModel.artpieceDTOList.enumerated()), id: \.1.objectID) { dtx, artpieceDTO in
                                Group {
                                    if let url = URL(string: artpieceDTO.primaryImageSmall) {
                                        ZStack(alignment: .topTrailing){
                                            LowResImageView(
                                                id: artpieceDTO.objectID,
                                                urlStr: url.absoluteString,
                                                service: ArtpieceService(context: context)
                                            )
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
                                        .padding(.vertical, isPad ? 10 : 5)
                                        .onAppear {
                                            if artpieceDTO.objectID == viewModel.artpieceDTOList.last?.objectID {
                                                if countdown > 0 || viewModel.resultForThisKeywordComplete {
                                                    return
                                                }
                                                deadline = Date.now.addingTimeInterval(countdownTotal)
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
                                .frame(width: geometry.size.width / CGFloat(columnCount + 1))
                                .frame(maxHeight: 200)
                            }
                        }
                        VStack {
                            Spacer()
                            Group {
                                if !viewModel.resultForThisKeywordComplete {
                                    if countdown > 0 {
                                        Text("Swipe up for more results, available in \(countdown) seconds")
                                    } else {
                                        Text("Swipe up for more results")
                                    }
                                }
                            }
                            .font(.footnote.weight(.semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.black.opacity(0.7))
                            .clipShape(Capsule())
                        }
                    }
                }
                .overlay {
                    switch viewModel.searchStatus {
                    case .searchNotStarted, .searchFoundResult:
                        EmptyView()
                    case .searching:
                        Text("Search in progress")
                    case .searchFoundNothing:
                        Text("Did not find anything")
                    }
                }
                .alert("Error Occurs", isPresented: Binding(get: {viewModel.error != nil}, set: { _, _ in viewModel.error = nil })) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                } message: {
                    if let error = viewModel.error as? ArtpieceService.ArtpieceServiceError {
                        Text("Error: \(error.description)")
                            .foregroundStyle(.black)
                    } else {
                        if let error = viewModel.error {
                            Text("Error: \(error.localizedDescription)")
                                .foregroundStyle(.black)
                        }
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
                    countdown = max(0, Int(ceil(deadline.timeIntervalSinceNow)))
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

struct LowResImageView: View {
    let id: Int
    let urlStr: String
    let service: ArtpieceService
    
    @State private var uiImage: UIImage?
    
    var body: some View {
        Group {
            if let img = uiImage {
                Image(uiImage: img).resizable().scaledToFit()
            } else {
                Color.gray.opacity(0.1)
                    .aspectRatio(1, contentMode: .fit)
            }
        }
        .task(id: id) {
            do {
                if let data = try await service.fetchLowResImageData(
                    for: id,
                    urlStr: urlStr
                ),
                   let img = UIImage(data: data)
                {
                    uiImage = img
                }
            } catch {}
        }
    }
}

