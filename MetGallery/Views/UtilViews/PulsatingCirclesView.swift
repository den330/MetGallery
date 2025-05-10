//
//  PulsatingCirclesView.swift
//  MetGallery
//
//  Created by yaxin on 2025-05-10.
//

import SwiftUI

struct PulsatingCirclesView: View {
    var body: some View {
        TimelineView(.animation) { viewContext in
            Canvas { ctx, size in
                let t = viewContext.date.timeIntervalSinceReferenceDate
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                
                for i in 0..<200 {
                    let angle = Double(i) / 200 * .pi * 2
                    let radius = CGFloat(50 + 30 * sin(t + Double(i)))
                    let p = CGPoint(
                        x: center.x + cos(angle) * radius,
                        y: center.y + sin(angle) * radius
                    )
                    let circle = Path(ellipseIn: CGRect(origin: p, size: .init(width: 2, height: 2)))
                    ctx.fill(circle, with: .color(.white))
                }
            }
        }
    }
}
