//
//  ChartDataPoint.swift
//  H2Only
//
//  Created by Trangptt on 13/1/26.
//

import SwiftUI

struct ChartDataPoint : Identifiable {
    let id = UUID()
    let date: Date
    let amount: Double
    let goal: Double
    let label: String
    
    var percent: Double {
        return goal > 0 ? amount / goal : 0
    }
}
