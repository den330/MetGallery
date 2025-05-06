//
//  MetGalleryApp.swift
//  MetGallery
//
//  Created by yaxin on 2025-04-18.
//

import SwiftUI

@main
struct MetGalleryApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var isLoading = true
    
    var body: some Scene {
        WindowGroup {
            Group {
                if isLoading {
                    SplashView()
                } else {
                    ContentView()
                        .modelContainer(for: [Artpiece.self, APCollection.self])
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                    isLoading = false
                }
            }
        }
    }
}
