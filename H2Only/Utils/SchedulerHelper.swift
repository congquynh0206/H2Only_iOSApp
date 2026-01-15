//
//  SchedulerHelper.swift
//  H2Only
//
//  Created by Trangptt on 15/1/26.
//


import Foundation

struct SchedulerHelper {
    
    enum ScheduleResult {
        case success([Date])
        case failure(String)
    }

    static func generateSmartSchedule(wakeUpTime: Date, bedTime: Date) -> ScheduleResult {
        let calendar = Calendar.current
        let today = Date()
        
        // Lấy giờ, phút của WakeUp
        let wakeComponents = calendar.dateComponents([.hour, .minute], from: wakeUpTime)
        // Lấy giờ, phút của BedTime
        let bedComponents = calendar.dateComponents([.hour, .minute], from: bedTime)
        
        // Tạo Date chuẩn cho hôm nay, ý nghĩa : lấy ngày của of nhưng tự tạo giờ phút
        guard let startWake = calendar.date(bySettingHour: wakeComponents.hour!, minute: wakeComponents.minute!, second: 0, of: today),
              var endBed = calendar.date(bySettingHour: bedComponents.hour!, minute: bedComponents.minute!, second: 0, of: today) else {
            return .failure("Lỗi định dạng thời gian")
        }

        
        // Nếu giờ ngủ nhỏ hơn giờ dậy (VD: Ngủ 01:00 < Dậy 07:00) -> Tức là ngủ vào ngày hôm sau
        if endBed <= startWake {
            endBed = calendar.date(byAdding: .day, value: 1, to: endBed)!
        }
        
        // Tính tổng thời gian thức (giây) - xem hợp lý k
        let awakeDuration = endBed.timeIntervalSince(startWake)
        let hoursAwake = awakeDuration / 3600.0
        
        // Nếu thời gian thức nhỏ hơn 4 tiếng thì báo lỗi
        if hoursAwake < 4 {
            return .failure("Thời gian thức quá ngắn (\(String(format: "%.1f", hoursAwake)) giờ). Hãy kiểm tra lại giờ đi ngủ.")
        }
        
        // Nếu thức quá 20 tiếng thì báo lỗi
        if hoursAwake > 20 {
            return .failure("Bạn thức hơn 20 tiếng một ngày? Hãy điều chỉnh lại thời gian hợp lý hơn.")
        }
        
        // Tạo mảng
        var reminders: [Date] = []
        var currentTime = startWake
        
        // Ngừng uống trước khi ngủ 2 tiếng
        guard let limitTime = calendar.date(byAdding: .hour, value: -2, to: endBed) else {
            return .failure("Lỗi tính toán giờ")
        }
        
        // Kiểm tra thêm điều kiện currentTime < endBed để tránh loop vô tận nếu logic sai
        while currentTime <= limitTime {
            reminders.append(currentTime)
            
            // Cộng 90 phút
            if let nextTime = calendar.date(byAdding: .minute, value: 90, to: currentTime) {
                currentTime = nextTime
            } else {
                break
            }
        }
        
        
        if reminders.isEmpty {
            return .failure("Khoảng thời gian uống nước quá ngắn.")
        }
        
        return .success(reminders)
    }
}
