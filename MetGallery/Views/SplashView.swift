//
//  SplashView.swift
//  MetGallery
//
//  Created by yaxin on 2025-04-20.
//

import SwiftUI

struct SplashView: View {
    @State private var fadesIn = false
    var body: some View {
        ZStack {
            Color(.black)
                .ignoresSafeArea()
                
            Image("MetBuilding")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                
            Image("flashIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .opacity(fadesIn ? 1 : 0)
                .onAppear {
                    withAnimation(.easeIn(duration: 1)) {
                        fadesIn = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation(.easeOut(duration: 1)) {
                            fadesIn = false
                        }
                    }
                }
        }
    }
}

