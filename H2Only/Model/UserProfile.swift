//
//  UserProfile.swift
//  H2Only
//
//  Created by Trangptt on 8/1/26.
//

import Foundation
import RealmSwift

class UserProfile: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId

    @Persisted var isOnboardingCompleted: Bool = false // Đã qua màn giới thiệu chưa
    
    // Dữ liệu cá nhân
    @Persisted var gender: Gender = .male
    @Persisted var weight: Double = 60.0
    @Persisted var wakeUpTime: Date?
    @Persisted var bedTime: Date?
    
    // Cài đặt Mục tiêu & Đơn vị
    @Persisted var dailyGoal: Int = 2000        // Mục tiêu mặc định (ml)
    @Persisted var selectedCupSize: Int = 100   // Cái cốc đang chọn 
    
    @Persisted var volumeUnit: VolumeUnit = .ml
    @Persisted var weightUnit: WeightUnit = .kg
    
    // Cài đặt Nhắc nhở
    @Persisted var isReminderEnabled: Bool = true
    @Persisted var reminderInterval: Int = 60   // Nhắc mỗi bao nhiêu phút
    
    @Persisted var cups = List<Cup>()
    
    @Persisted var reminderSchedule = List<ReminderItem>()
    
    @Persisted var notificationSoundName: String = ""
}

class ReminderItem: EmbeddedObject, Identifiable {
    @Persisted var id: ObjectId = ObjectId.generate()
    @Persisted var time: Date
    @Persisted var isEnabled: Bool = true
}
