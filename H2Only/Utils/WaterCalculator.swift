//
//  WaterCalculator.swift
//  H2Only
//
//  Created by Trangptt on 8/1/26.
//

import Foundation

struct WaterCalculator {
    static func calculateDailyGoal(weightKg: Double, gender: Gender) -> Int {
        
        let baseAmount : Double
        if gender == .male {
            baseAmount = weightKg * 35.0
        }else {
            baseAmount = weightKg * 30.0
        }
        return Int(baseAmount)
    }
}
