//
//  ImagePageView.swift
//  MetGallery
//
//  Created by yaxin on 2025-04-19.
//

import SwiftUI

struct ImagePageView: View {
    @Binding var currentIndex: Int?
    @State private var showHint = false
    @AppStorage("hasSeenImageDetailHint") private var hasSeenImageDetailHint: Bool = false
    var DTOList: [ArtpieceDTO]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @State private var showShareSheet: Bool = false

    var body: some View {
        ZStack {
            VStack {
                Spacer(minLength: 40)
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .padding()
                    }
                }
                .padding(.trailing, 10)
                TabView(selection: $currentIndex) {
                    ForEach(Array(DTOList.enumerated()), id: \.1.objectID) { index, dto in
                        ImageDetailView(DTO: dto, apService: ArtpieceService(context: context), openShareSheet: $showShareSheet)
                            .tag(index)
                    }
                }.tabViewStyle(
                    PageTabViewStyle(indexDisplayMode: .automatic)
                )
                .onAppear {
                    showHint = !hasSeenImageDetailHint
                }
                .disabled(showHint)
                Spacer()
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
        .sheet(isPresented: $showShareSheet) {
            if let currentIndex = currentIndex, let image = CacheManager.shared.image(for: DTOList[currentIndex].objectID){
                ShareSheet(items: [image])
            }
        }
        .ignoresSafeArea()
    }
}
