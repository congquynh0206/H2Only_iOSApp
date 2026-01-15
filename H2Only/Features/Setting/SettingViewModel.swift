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
    @Published var showEditPopup: Bool = false
    @Published var selectedTimeForEdit: Date = Date()
    @Published var editingItem: ReminderItem? = nil // Nếu nil = Thêm mới, Có giá trị = Sửa
    
    // alert hỏi có tạo lại lịch k
    @Published var showRescheduleAlert: Bool = false
    
    // loại tgian đang sửa: dậy, ngủ
    var currentEditingType: ProfileTimeType = .wakeUpTime
    
    private var userProfile: UserProfile? {
        let realm = try? Realm()
        return realm?.objects(UserProfile.self).first
    }
    
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
    
    
    // Hàm mở popup cho setting
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
