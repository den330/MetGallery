import SwiftUI
import UIKit

struct ShareSheet: UIViewControllerRepresentable {
    
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityController = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        activityController.completionWithItemsHandler = { _, _, _, error in
            if let error = error {
                print("activity error \(error)")
            }
        }
        return activityController
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
    
}
