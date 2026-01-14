//
//  WaterLog.swift
//  H2Only
//
//  Created by Trangptt on 7/1/26.
//
import Foundation
import RealmSwift

class WaterLog: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    
    @Persisted var amount: Int = 0
    @Persisted var date: Date = Date()
    @Persisted var iconName: String = "ic_cup_125ml_selected"
    @Persisted var cupSize: Int = 0
}

// Dùng cho báo cáo nc uống
struct WaterReport {
    var weeklyAvg: Int = 0      // Tb tuần
    var monthlyAvg: Int = 0     // Tb tháng
    var completionAvg: Int = 0  // Hoàn thành trung bình
    var frequency: Int = 0      // Tần suất uống
}
