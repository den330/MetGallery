import SwiftUI
import GoogleMobileAds

struct AdView: UIViewRepresentable {
    let adUnitID: String
    @Binding var adReady: Bool
    var isPad: Bool
    class Coordinator: NSObject, BannerViewDelegate {
        var parent: AdView
        
        init(_ parent: AdView) {
            self.parent = parent
        }
        
        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            parent.adReady = true
        }
        
        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            parent.adReady = false
            print("Failed to load banner ad: \(error.localizedDescription)")
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> BannerView {
        
        let banner = BannerView(adSize: isPad ? AdSizeFullBanner : AdSizeBanner)
        banner.adUnitID = adUnitID
        
        if let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            banner.rootViewController = rootViewController
        } else {
            print("Warning: Root view controller not there")
        }
        
        banner.delegate = context.coordinator
        
        banner.load(Request())
        
        return banner
    }
    
    func updateUIView(_ uiView: BannerView, context: Context) {}
}
