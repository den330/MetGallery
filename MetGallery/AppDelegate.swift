//
//  AppDelegate.swift
//  MetGallery
//
//  Created by yaxin on 2025-05-06.
//
import UIKit
import InterfaceOrientation

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?)
    -> UIInterfaceOrientationMask {
        InterfaceOrientationCoordinator.shared.supportedOrientations
    }
}
