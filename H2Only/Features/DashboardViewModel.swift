//
//  DashboardViewModel.swift
//  H2Only
//
//  Created by Trangptt on 7/1/26.
//

import SwiftUI
import RealmSwift

class DashboardViewModel: ObservableObject {
    // Xóa dòng @ObservedResults cũ đi
    // Xóa biến currentIntake cũ đi
    
    // Hàm thêm nước (Giữ nguyên)
    func addWater(amount: Int) {
        let newLog = WaterLog()
        newLog.amount = amount
        newLog.date = Date()
        
        RealmManager.shared.add(newLog)
    }
}
