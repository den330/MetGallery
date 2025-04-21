//
//  ChartView.swift
//  MetGallery
//
//  Created by yaxin on 2025-04-20.
//

import SwiftUI
import Charts
import SwiftData


struct ChartView: View {
    @Query private var aps: [Artpiece]
    @State var departmentCounts: [String:Int] = [:]
    var stateTuples: [(String, Int)] {
        departmentCounts.map {($0.key, $0.value)}
    }
    
    var adjustedStateTuples: [(String, Int)] {
        if stateTuples.count <= 4 {
            return stateTuples
        }
        let sortedTuples = self.stateTuples.sorted {$0.1 > $1.1}
        let topTuples = sortedTuples.prefix(3)
        let restTuples = sortedTuples.dropFirst(3)
        let sumRest = restTuples.map {$0.1}.reduce(0,+)
        let restTuple = ("Other", sumRest)
        var resultTuples = Array(topTuples)
        resultTuples.append(restTuple)
        return resultTuples
    }
    var body: some View {
        Chart(adjustedStateTuples, id:\.0) { entry in
            SectorMark(
                angle: .value("Count", entry.1),
                angularInset: 1
            )
            .foregroundStyle(by: .value("Department", entry.0))
            .annotation(position: .overlay) {
                if entry.1 > 0 {
                    Text("\(entry.1) times")
                        .font(.caption2.bold())
                }
            }
        }
        .chartLegend(position: .trailing)
        .frame(height: 300)
        .padding()
        .onAppear {
            for ap in aps {
                departmentCounts[ap.department, default: 0] += 1
            }
        }
    }
}

#Preview {
    ChartView()
}
