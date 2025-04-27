import SwiftUI

struct ZoomableImageView: View {
    var image: Image
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @Binding var isFav: Bool?
    @Binding var openShare: Bool
    private let minScale: CGFloat = 1.0
    private let maxScale: CGFloat = 3.0
    let isPad = UIDevice.current.userInterfaceIdiom == .pad
    
    init(image: Image, isFav: Binding<Bool?>? = nil, openShare: Binding<Bool>) {
        self.image = image
        self._isFav = isFav ?? .constant(nil)
        self._openShare = openShare
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
                        magnificationGesture(geometry: geometry)
                            .simultaneously(with: scale > minScale ? dragGesture(geometry: geometry) : nil)
                    )
                    .onTapGesture(count: 2) {
                        withAnimation(.easeInOut(duration: 1)) {
                            scale = 1
                            offset = .zero
                        }
                    }
                    .overlay(alignment: .topTrailing) {
                        if isFav == nil {
                            EmptyView()
                        } else {
                            Image(systemName: isFav! ? "heart.fill" : "heart")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                                .padding(15)
                                .foregroundStyle(.red)
                                .onTapGesture {
                                    isFav!.toggle()
                                }
                                .opacity(scale == 1 ? 1 : 0)
                                .disabled(scale == 1 ? false : true)
                        }
                    }
                    .overlay(alignment: .bottomLeading) {
                        Button {
                            openShare.toggle()
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .resizable()
                                .scaledToFit()
                                .frame(width: isPad ? 30 : 15, height: isPad ? 30 : 15)
                                .padding(5)
                                .foregroundStyle(.white)
                                .background(.black.opacity(0.5))
                                .opacity(scale == 1 ? 1 : 0)
                                .disabled(scale == 1 ? false : true)
                        }
                    }
            }
            .clipped()
        }
    }
    
    private func magnificationGesture(geometry: GeometryProxy) -> some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let delta = value / lastScale
                lastScale = value
                let newScale = scale * delta
                scale = min(max(newScale, minScale), maxScale)
            }
            .onEnded { _ in
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
