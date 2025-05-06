import SwiftUI

struct ZoomableImageView: View {
    var image: Image
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @Binding var infoOn: Bool
    private let minScale: CGFloat = 1.0
    private let maxScale: CGFloat = 3.0
    let isPad = UIDevice.current.userInterfaceIdiom == .pad
    
    init(image: Image, infoOn: Binding<Bool>) {
        self.image = image
        self._infoOn = infoOn
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                Color.clear
                image
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(scale)
                    .offset(offset)
                    .gesture(
                        infoOn ? nil : magnificationGesture(geometry: geometry)
                            .simultaneously(with: scale > minScale ? dragGesture(geometry: geometry) : nil)
                    )
                    .onTapGesture(count: 2) {
                        withAnimation(.easeInOut(duration: 1)) {
                            scale = 1
                            offset = .zero
                        }
                    }
            }
            .clipped()
        }
        .onChange(of: infoOn) {
            withAnimation(.easeInOut(duration: 0.5)) {
                scale = 1
                offset = .zero
            }
        }
    }
    
    private func magnificationGesture(geometry: GeometryProxy) -> some Gesture {
        MagnificationGesture()
            .onChanged { value in
                print("value is \(value)")
                let delta = value / lastScale
                lastScale = value
                let newScale = scale * delta
                scale = min(max(newScale, minScale), maxScale)
            }
            .onEnded { value in
                print("change ended with \(value)")
                lastScale = 1.0
                adjustOffsetForBounds(geometry: geometry)
            }
    }
    
    private func dragGesture(geometry: GeometryProxy) -> some Gesture {
        DragGesture()
            .onChanged { value in
                let deltaX = value.translation.width
                let deltaY = value.translation.height
                let newOffset = CGSize(
                    width: lastOffset.width + deltaX,
                    height: lastOffset.height + deltaY
                )
                offset = constrainOffset(newOffset, geometry: geometry)
            }
            .onEnded { _ in
                lastOffset = offset
                adjustOffsetForBounds(geometry: geometry)
            }
    }
    
    private func constrainOffset(_ offset: CGSize, geometry: GeometryProxy) -> CGSize {
        guard scale > 1.0 else { return .zero }
        
        let imageSize = geometry.size
        let scaledWidth = imageSize.width * scale
        let scaledHeight = imageSize.height * scale
        let maxOffsetX = (scaledWidth - imageSize.width) / 2
        let maxOffsetY = (scaledHeight - imageSize.height) / 2
        
        return CGSize(
            width: min(max(offset.width, -maxOffsetX), maxOffsetX),
            height: min(max(offset.height, -maxOffsetY), maxOffsetY)
        )
    }
    
    private func adjustOffsetForBounds(geometry: GeometryProxy) {
        offset = constrainOffset(offset, geometry: geometry)
        lastOffset = offset
    }
}
