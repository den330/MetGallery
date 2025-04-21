//
//  ImagePageView.swift
//  MetGallery
//
//  Created by yaxin on 2025-04-19.
//

import SwiftUI

struct ImagePageView: View {
    @Binding var currentIndex: Int?
    var DTOList: [ArtpieceDTO]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(DTOList.enumerated()), id: \.1.objectID) { index, dto in
                ImageDetailView(DTO: dto, apService: ArtpieceService(context: context))
                    .tag(index)
                    .padding(.top, 30)
            }
        }.tabViewStyle(
            PageTabViewStyle(indexDisplayMode: .automatic)
        ).overlay(alignment: .topTrailing) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20) // Adjust size as needed
            }
            .padding(.trailing, 10)
            .padding(.top, 10)
        }
        
    }
}

//#Preview {
//    ImagePageView()
//}
