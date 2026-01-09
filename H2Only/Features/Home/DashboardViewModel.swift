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
    
    // Cốc hiện tại
    var currentCup: Cup? {
        guard let user = userProfile else { return nil }
        // Tìm trong danh sách cốc xem có cốc nào khớp dung tích đang chọn không
        return user.cups.filter("amount == %@", user.selectedCupSize).first
    }
    
    init(){
        DispatchQueue.main.async {
            if let user = RealmManager.shared.realm?.objects(UserProfile.self).first {
                if user.cups.isEmpty {
                    self.createDefaultCups(for: user)
                    try? RealmManager.shared.realm?.write{
                        user.selectedCupSize = 125
                    }
                }
            }
        }
    }

    // Lấy iconName
    func getCurrentIconName(postFix : String) -> String {
        guard let amount = currentCup?.amount else{
            return getIconName(for: 100 , postFix: postFix)
        }
        
        return getIconName(for: amount, postFix: postFix)
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
        newLog.iconName = getIconName(for: user.selectedCupSize, postFix: "selected")
        
        RealmManager.shared.add(newLog)
    }
    func getIconName(for amount: Int, postFix : String) -> String {
        switch amount {
        case 100: return "ic_cup_100ml_\(postFix)"
        case 125: return "ic_cup_125ml_\(postFix)"
        case 150: return "ic_cup_150ml_\(postFix)"
        case 175: return "ic_cup_175ml_\(postFix)"
        case 200: return "ic_cup_200ml_\(postFix)"
        case 300: return "ic_cup_300ml_\(postFix)"
        case 400: return "ic_cup_400ml_\(postFix)"
        case 500: return "ic_cup_500ml_\(postFix)"
        case 1000: return "ic_cup_1000ml_\(postFix)"
        default: return "ic_cup_customize_\(postFix)"
        }
    }
    
    // Tạo các cốc default
    func createDefaultCups(for user: UserProfile) {
        let defaultCups = [// Bỏ _normal
            Cup(amount: 125, iconName: "ic_cup_125ml", isDefault: true),
            Cup(amount: 150, iconName: "ic_cup_150ml", isDefault: true),
            Cup(amount: 175, iconName: "ic_cup_175ml", isDefault: true),
            Cup(amount: 200, iconName: "ic_cup_200ml", isDefault: true),
            Cup(amount: 300, iconName: "ic_cup_300ml", isDefault: true),
            Cup(amount: 400, iconName: "ic_cup_400ml", isDefault: true),
            Cup(amount: 500, iconName: "ic_cup_500ml", isDefault: true),
            Cup(amount: 1000, iconName: "ic_cup_1000ml", isDefault: true)
        ]
        
        try? RealmManager.shared.realm?.write {
            user.cups.append(objectsIn: defaultCups)
        }
    }
    
    func addCustomCup(amount: Int) {
        guard let user = userProfile else { return }
        // Kiểm tra xem cốc có chưa
        if user.cups.contains(where: { $0.amount == amount }) {
            // Nếu có rồi thì chỉ cần select nó thôi
            selectCup(amount)
            return
        }
        
        // Tạo cốc mới
        let newCup = Cup()
        newCup.amount = amount
        newCup.iconName = "ic_cup_customize"
        newCup.isDefault = false
        
        // Lưu vào Realm và Set làm cốc đang chọn
        try? RealmManager.shared.realm?.write {
            user.cups.append(newCup)
            user.selectedCupSize = amount
        }
    }
    
    func selectCup(_ amount: Int) {
        guard let user = userProfile else { return }
        try? RealmManager.shared.realm?.write {
            user.selectedCupSize = amount
            print("thay đổi trong db: \(amount)")
        }
    }

    
    
    // Hàm xoá
    func deleteLog(_ log: WaterLog) {
       
    }
}
