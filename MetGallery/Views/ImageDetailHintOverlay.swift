//
//  ImageDetailHintOverlay.swift
//  MetGallery
//
//  Created by yaxin on 2025-04-22.
//

import SwiftUI

struct ImageDetailHintOverlay: View {
    @Binding var showHint: Bool
    var dismiss: () -> Void
    var body: some View {
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        ZStack(alignment: .center) {
            Color.black.opacity(0.6)
            VStack {
                Image(systemName: "arrow.left.arrow.right")
                    .resizable()
                    .scaledToFit()
                    .frame(width: isPad ? 70 : 50, height: isPad ? 70 : 50)
                    .padding()
                Text("Swipe left or right to see the next or previous image")
                    .font(isPad ? .largeTitle : .title2)
                    .padding()
                Button(action: {
                    dismiss()
                    showHint = false
                }, label: {
                    Text("Got it.")
                        .bold()
                        .padding(.horizontal, 15)
                        .padding(.vertical, 8)
                        .background(.blue)
                        .clipShape(Capsule())
                        .overlay {
                            Capsule().stroke(.white, lineWidth: 3)
                        }
                })
                .padding()
            }
            .foregroundStyle(.white)
        }
    }
}
