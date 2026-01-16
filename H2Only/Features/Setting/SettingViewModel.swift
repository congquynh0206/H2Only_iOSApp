//
//  SettingViewModel.swift
//  H2Only
//
//  Created by Trangptt on 15/1/26.
//

import SwiftUI
import RealmSwift

enum ProfileTimeType {
    case wakeUpTime
    case bedTime
}

class SettingViewModel: ObservableObject {
    // Popup
    @Published var showEditPopup: Bool = false      // Popup Giờ
    @Published var showGenderPopup: Bool = false    // Popup Giới tính
    @Published var showWeightPopup: Bool = false    // Popup Cân nặng
    @Published var showGoalPopup: Bool = false      // Popup Mục tiêu
    
    // Dữ liệu temp khi chỉnh sửa
    @Published var selectedTimeForEdit: Date = Date()
    @Published var tempGender: Gender = .male
    @Published var tempWeight: Double = 60.0
    @Published var tempGoal: Double = 2000.0

    @Published var editingItem: ReminderItem? = nil
    @Published var showRescheduleAlert: Bool = false
    var currentEditingType: ProfileTimeType = .wakeUpTime
    
    var userProfile: UserProfile? {
        let realm = try? Realm()
        return realm?.objects(UserProfile.self).first
    }
    
    var recommendedGoal: Double {
        guard let user = userProfile else { return 2000 }
        return Double(WaterCalculator.calculateDailyGoal(weightKg: user.weight, gender: user.gender))
    }
    
    // MARK: Gender
    func openGenderPopup() {
        if let user = userProfile {
            self.tempGender = user.gender
            self.showGenderPopup = true
        }
    }
    
    func saveGender() {
        guard let realm = try? Realm(), let user = userProfile, let liveUser = user.thaw() else { return }
        try? realm.write {
            liveUser.gender = tempGender
            // Đổi giới tính , thì cập nhật lại goal
            liveUser.dailyGoal = WaterCalculator.calculateDailyGoal(weightKg: liveUser.weight, gender: tempGender)
        }
        showGenderPopup = false
    }
    
    
    //MARK:  Cân nặng
    func openWeightPopup() {
        if let user = userProfile {
            self.tempWeight = user.weight
            self.showWeightPopup = true
        }
    }
    
    // Lưu Cân nặng
    func saveWeight() {
        guard let realm = try? Realm(), let user = userProfile, let liveUser = user.thaw() else { return }
        try? realm.write {
            liveUser.weight = tempWeight
            // Đổi cân nặg thì cập nhật lại goal
            liveUser.dailyGoal = WaterCalculator.calculateDailyGoal(weightKg: tempWeight, gender: liveUser.gender)
        }
        showWeightPopup = false
    }
    
    
    //MARK:  Mục tiêu uống nước
    func openGoalPopup() {
        if let user = userProfile {
            self.tempGoal = Double(user.dailyGoal)
            self.showGoalPopup = true
        }
    }
    
    // Lưu Goal
    func saveGoal() {
        guard let realm = try? Realm(), let user = userProfile, let liveUser = user.thaw() else { return }
        try? realm.write {
            liveUser.dailyGoal = Int(tempGoal)
        }
        showGoalPopup = false
    }
    
    
    // MARK: Cài đặt thời gian
    //  Cbi thêm
    func prepareAdd() {
        editingItem = nil
        selectedTimeForEdit = Date() // Reset về giờ hiện tại
        showEditPopup = true
    }
    
    // Cbi sửa
    func prepareEdit(item: ReminderItem) {
        editingItem = item
        selectedTimeForEdit = item.time
        showEditPopup = true
    }
    
    //  Hàm lưu , xử lý cả Thêm và Sửa
    func saveItem() {
        guard let realm = try? Realm(),
              let profile = userProfile else { return }
        
        try? realm.write {
            if let itemToUpdate = editingItem {
                // sửa
                if let liveItem = itemToUpdate.thaw() {
                    liveItem.time = selectedTimeForEdit
                }
            } else {
                // Thêm mới
                let newItem = ReminderItem()
                newItem.time = selectedTimeForEdit
                newItem.isEnabled = true
                
                // Thaw profile
                if let liveProfile = profile.thaw() {
                    // Tìm item đầu tiên lớn hơn newItem, chèn vào trước
                    let insertionIndex = liveProfile.reminderSchedule.firstIndex(where: { $0.time > newItem.time }) ?? liveProfile.reminderSchedule.count
                    
                    // Insert
                    liveProfile.reminderSchedule.insert(newItem, at: insertionIndex)
                }
            }
        }
    }
    
    // Hàm xoá
    func deleteItem(at offsets: IndexSet) {
        guard let realm = try? Realm(),
              let profile = userProfile,
              let liveProfile = profile.thaw() else { return }
        
        try? realm.write {
            liveProfile.reminderSchedule.remove(atOffsets: offsets)
        }
    }
    
    // Hàm toggle
    func toggleItem(_ item: ReminderItem, isEnabled: Bool) {
        guard let realm = try? Realm(),
              let liveItem = item.thaw() else { return }
        
        try? realm.write {
            liveItem.isEnabled = isEnabled
        }
    }
    
    // Tạo lịch tự động
    func createNewSchedule() {
        guard let realm = try? Realm(),
              let user = userProfile,
              let wakeUp = user.wakeUpTime,
              let bedTime = user.bedTime else { return }
    
        let result = SchedulerHelper.generateReminderSchedule(wakeUpTime: wakeUp, bedTime: bedTime)
        
        switch result {
        case .success(let dates):
            try? realm.write {
                user.reminderSchedule.removeAll()
                for date in dates {
                    let newItem = ReminderItem()
                    newItem.time = date
                    newItem.isEnabled = true
                    user.reminderSchedule.append(newItem)
                }
            }
        case .failure(let errorMessage):
            print("Lỗi: \(errorMessage)")
        }
    }
    
    
    // MARK: Giờ dậy, giờ ngủ
    func openProfileTimePicker(type: ProfileTimeType, currentTime: Date?) {
        self.currentEditingType = type
        self.selectedTimeForEdit = currentTime ?? Date()
        self.showEditPopup = true
    }
    
    // Hàm lưu Profile
    func saveProfileTime() {
        guard let realm = try? Realm(),
              let user = userProfile,
              let liveUser = user.thaw() else { return }
        
        try? realm.write {
            switch currentEditingType {
            case .wakeUpTime:
                liveUser.wakeUpTime = selectedTimeForEdit
            case .bedTime:
                liveUser.bedTime = selectedTimeForEdit
            }
        }
        // đảm bảo pop up tắt mới bật alert
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showRescheduleAlert = true
        }
    }
}
