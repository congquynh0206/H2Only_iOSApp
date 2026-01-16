//
//  NotificationManager.swift
//  H2Only
//
//  Created by Trangptt on 16/1/26.
//


import UserNotifications
import UIKit

class NotificationManager {
    static let shared = NotificationManager()
    
    // Xin quyền thông báo
    func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { success, error in
            if let error = error {
                print("Lỗi xin quyền: \(error.localizedDescription)")
            } else {
                print("Đã cấp quyền thông báo: \(success)")
            }
        }
    }
    
    // Hàm lên lịch lại toàn bộ
    func scheduleNotifications(for reminders: [ReminderItem]) {
        // Xóa hết cái cũ
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Duyệt qua list giờ
        for item in reminders {
            // Chỉ lên lịch cho cái nào đang isEnabled
            if item.isEnabled {
                scheduleSingleNotification(at: item.time)
            }
        }
    }
    
    // Lên lịch cho 1 khung giờ
    private func scheduleSingleNotification(at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Đến giờ uống nước rồi!"
        content.body = "Sau khi uống, chạm vào cốc để xác nhận"
        content.sound = .default
        
        // Lấy giờ và phút từ Date
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        
        // Trigger: Lặp lại hàng ngày
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        // Tạo ID 
        let identifier = "WaterReminder_\(components.hour!)_\(components.minute!)"
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // Gửi yêu cầu lên hệ thống
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Lỗi lên lịch: \(error.localizedDescription)")
            }
        }
    }
 
}
