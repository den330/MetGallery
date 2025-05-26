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

struct SoundBarChartView: View {
    let barCount = 20
    let spacing: CGFloat = 4
    let baseSpeed = 2.0

    @State private var phaseOffsets: [Double] = (0..<20).map { _ in Double.random(in: 0..<2 * .pi) }
    @State private var speedMultipliers: [Double] = (0..<20).map { _ in Double.random(in: 0.5...1.5) }
    
    var body: some View {
        TimelineView(.animation) { ctx in
            Canvas { canvas, size in
                let t = ctx.date.timeIntervalSinceReferenceDate
                let barWidth = (size.width - spacing * CGFloat(barCount - 1)) / CGFloat(barCount)
                let maxHeight = size.height * 0.8
                
                var path = Path()
                for i in 0..<barCount {
                    let phase = t * baseSpeed * speedMultipliers[i] + phaseOffsets[i]
                    let amp = abs(sin(phase))
                    let h = maxHeight * amp
                    
                    let x = CGFloat(i) * (barWidth + spacing)
                    let y = size.height - h
                    
                    path.addRect(CGRect(x: x, y: y,
                                        width: barWidth,
                                        height: h))
                }
                canvas.fill(path, with: .color(.white))
            }
        }
    }
}

struct SoundWave: View {
    var body: some View {
        TimelineView(.animation) { context in
            Canvas { ctx, size in
                let t = context.date.timeIntervalSinceReferenceDate
                let midY = size.height / 2
                let amplitude: CGFloat = 50
                let frequency = 2 * .pi / size.width
                let phase = CGFloat(t) * 2
                
                var path = Path()
                for xPixel in stride(from: 0, through: size.width, by: 1) {
                    let x = xPixel
                    let y = midY + amplitude * sin(frequency * x + phase)
                    if xPixel == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                ctx.stroke(path, with: .color(.white), lineWidth: 2)
            }
        }
    }
}

