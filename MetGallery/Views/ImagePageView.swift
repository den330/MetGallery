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
                    }
                    .padding(10)
                }
                .padding(.trailing, 10)
                TabView(selection: $currentIndex) {
                    ForEach(Array(DTOList.enumerated()), id: \.1.objectID) { index, dto in
                        ImageDetailView(DTO: dto, apService: ArtpieceService(context: context))
                            .tag(index)
                            .padding(.top, 30)
                    }
                }.tabViewStyle(
                    PageTabViewStyle(indexDisplayMode: .automatic)
                )
                .onAppear {
                    withAnimation(.easeInOut(duration: 1)) {
                        showHint = !hasSeenImageDetailHint
                    }
                }
                .disabled(showHint)
                Spacer(minLength: 50)
            }
            if showHint {
                    ImageDetailHintOverlay {
                        showHint = false
                        hasSeenImageDetailHint = true
                    }
                    .transition(.opacity)
            }
        }
        .ignoresSafeArea()
    }
}
