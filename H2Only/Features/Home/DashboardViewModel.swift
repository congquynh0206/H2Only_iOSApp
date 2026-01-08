//
//  DashboardViewModel.swift
//  H2Only
//
//  Created by Trangptt on 7/1/26.
//

import SwiftUI
import RealmSwift

class DashboardViewModel: ObservableObject {
    // Lấy UserProfile (để biết mục tiêu, loại cốc đang chọn)
    @ObservedResults(UserProfile.self) var userProfiles
    
    // Lấy danh sách uống nước (Tự động cập nhật khi DB thay đổi)
    @ObservedResults(WaterLog.self, sortDescriptor: SortDescriptor(keyPath: "date", ascending: false)) var allLogs
    
    var userProfile: UserProfile? {
        userProfiles.first
    }
    
    // Lọc lịch sử chỉ lấy ngày hôm nay
    var todayLogs: [WaterLog] {
        let calendar = Calendar.current
        return allLogs.filter { calendar.isDateInToday($0.date) }
    }
    
    // Tính tổng nước hôm nay
    var currentIntake: Int {
        todayLogs.reduce(0) { $0 + $1.amount }
    }
    
    var dailyGoal: Int {
        userProfile?.dailyGoal ?? 2000
    }
    
    // Hàm thêm nước
    func addWater() {
        guard let user = userProfile else { return }
        let amount = user.selectedCupSize // Lấy dung tích cốc hiện tại
        
        let newLog = WaterLog()
        newLog.amount = amount
        newLog.date = Date()
        
        RealmManager.shared.add(newLog)
    }
    
    // Hàm xoá (nếu cần cho nút 3 chấm)
    func deleteLog(_ log: WaterLog) {
        // Code xoá log trong RealmManager...
    }
}
