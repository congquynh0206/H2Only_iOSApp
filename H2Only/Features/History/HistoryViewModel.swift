//
//  HistoryViewModel.swift
//  H2Only
//
//  Created by Trangptt on 13/1/26.
//

import Foundation
import RealmSwift
import SwiftUI


// Trạng thái Hoàn thành hàng tuần
enum DailyStatus {
    case empty       // Chưa đến hoặc chưa uống
    case inProgress  // Đang uống, chưa xong
    case completed   // Đã xong
    case failed      // Ngày quá khứ không đạt mục tiêu
}

// Để gửi text ngày với trạng thái cho View
struct DayStatus {
    let date: Date
    let status: DailyStatus
}


class HistoryViewModel: ObservableObject {
    // 0: Tháng, 1: Năm
    @Published var selectedTab: Int = 0
    @Published var selectedWeekIndex: Int = 0
    @Published var currentDate: Date = Date() {
        didSet {
            updateWeekIndex()
        }
    }
    init() {
        updateWeekIndex()
    }
    
    
    // MARK: ----Graph----
    
    // Tiêu đề thời gian
    var timeTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        if selectedTab == 0 {
            formatter.dateFormat = "MMMM yyyy" // Tháng 1 2026
        } else {
            formatter.dateFormat = "yyyy" // 2026
        }
        return formatter.string(from: currentDate)
    }
    
    // Tính toán graph
    func generateChartData(from logs: Results<WaterLog>, goal: Double) -> [ChartDataPoint] {
        if selectedTab == 0 {
            return calculateMonthStats(logs: logs, goal: goal)
        } else {
            return calculateYearStats(logs: logs, goal: goal)
        }
    }
    
    // Xử lý dữ liệu theo Tháng (View theo ngày)
    private func calculateMonthStats(logs: Results<WaterLog>, goal: Double) -> [ChartDataPoint] {
        let calendar = Calendar.current
        
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)),
              let range = calendar.range(of: .day, in: .month, for: startOfMonth) else { return [] }
        
        // Filter log trong tháng
        let logsInMonth = logs.filter { calendar.isDate($0.date, equalTo: startOfMonth, toGranularity: .month) }
        
        // Group by Day
        var dailyTotals: [Int: Double] = [:]
        for log in logsInMonth {
            let day = calendar.component(.day, from: log.date)
            dailyTotals[day, default: 0] += Double(log.amount)
        }
        
        // Map data
        return range.map { day in
            var components = calendar.dateComponents([.year, .month], from: startOfMonth)
            components.day = day
            let date = calendar.date(from: components) ?? Date()
            let amount = dailyTotals[day] ?? 0
            return ChartDataPoint(date: date, amount: amount, goal: goal, label: "\(day)")
        }
    }
    
    // Xử lý dữ liệu theo Năm (View theo tháng)
    private func calculateYearStats(logs: Results<WaterLog>, goal: Double) -> [ChartDataPoint] {
        let calendar = Calendar.current
        guard let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: currentDate)) else { return [] }
        
        // Filter log trong năm
        let logsInYear = logs.filter { calendar.isDate($0.date, equalTo: startOfYear, toGranularity: .year) }
        
        // Group by Month
        var monthlyTotals: [Int: Double] = [:]
        for log in logsInYear {
            let month = calendar.component(.month, from: log.date)
            monthlyTotals[month, default: 0] += Double(log.amount)
        }
        
        // Map data 12 tháng
        return (1...12).map { month in
            var components = calendar.dateComponents([.year], from: startOfYear)
            components.month = month
            components.day = 1
            let date = calendar.date(from: components) ?? Date()
            let amount = monthlyTotals[month] ?? 0
            
            let daysInMonth = calendar.range(of: .day, in: .month, for: date)?.count ?? 30
            let monthlyGoal = goal * Double(daysInMonth)
            
            return ChartDataPoint(date: date, amount: amount, goal: monthlyGoal, label: "T\(month)")
        }
    }
    
    
    //MARK: ----Hoàn thành hàng tuần----
    
    var currentWeekDays : [Date] {
        let calendar = Calendar.current
        
        // Tab năm
        if selectedTab == 1 {
            let today = Date()
            
            // Tìm ngày hôm nay là tuần số mấy, của năm nào
            guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) else { return [] }
            return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
        } else {
            // Tab tháng
            // Tim ngày m1 của tháng đang chọn
            guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)) else { return [] }
            
            // Tìm ngày đầu tuần chứa ngày mùng 1 của tháng đó
            guard let startOfFirstWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: startOfMonth)) else { return [] }
            
            // Cộng thêm số tuần người dùng đã next (selectedWeekIndex * 7 ngày)
            let startOfSelectedWeek = calendar.date(byAdding: .weekOfYear, value: selectedWeekIndex, to: startOfFirstWeek) ?? startOfFirstWeek
            
            // Tạo mảng 7 ngày
            return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfSelectedWeek) }
        }
    }
    
    // Title tuần
    var weekRangeTitle: String {
        let days = currentWeekDays
        guard let first = days.first, let last = days.last else { return "" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM"
        return "\(formatter.string(from: first)) - \(formatter.string(from: last))"
    }
    
    
    // Hàm chuyển tuần
    func changeWeek(by value: Int) {
        // Chỉ cho phép đổi tuần khi ở Tab Tháng
        if selectedTab == 0 {
            selectedWeekIndex += value
        }
    }
    
    // Tự động chọn tuần
    private func updateWeekIndex() {
        let calendar = Calendar.current
        let today = Date()
        
        //  Kiểm tra xem tháng đang xem có phải tháng này không
        let isSameMonth = calendar.isDate(currentDate, equalTo: today, toGranularity: .month)
        
        if isSameMonth {
            // Nếu là tháng hiện tại thì tính xem là tuần thứ mấy
            
            // Tìm ngày đầu tháng
            guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)) else { return }
            
            // Tìm ngày đầu tuần của mùng 1 - tuần đầu
            guard let startOfFirstWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: startOfMonth)) else { return }
            
            // Tìm ngày đầu tuần của hôm nay - tuần hiện tại
            guard let startOfCurrentWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) else { return }
            
            // Tuần hiện tại - Tuần đầu = Index cần tìm
            if let weeksDiff = calendar.dateComponents([.weekOfYear], from: startOfFirstWeek, to: startOfCurrentWeek).weekOfYear {
                selectedWeekIndex = weeksDiff
            }
        } else {
            // Nếu khác tháng thì luôn hiện tuần đầu
            selectedWeekIndex = 0
        }
    }
    
    
    // Tính toán trạng thái cho 7 ngày
    func getWeeklyStatus(logs: Results<WaterLog>, goal: Double) -> [DayStatus] {
        let days = currentWeekDays // Lấy 7 ngày ở trên
        let calendar = Calendar.current
        let today = Date()
        
        return days.map { date in
            // Tính tổng nước uống ngày hôm đó
            let logsInDay = logs.filter { calendar.isDate($0.date, equalTo: date, toGranularity: .day) }
            let totalAmount = logsInDay.reduce(0) { $0 + Double($1.amount) }
            
            
            let isToday = calendar.isDateInToday(date)
            let isFuture = date > today && !isToday // Ngày tương lai
            let isPast = date < today && !isToday   // Ngày quá khứ
            
            var status: DailyStatus = .empty
            
            if isFuture {
                // Chưa đến -> Circle xanh
                status = .empty
            } else if isToday {
                // Hôm nay
                if totalAmount == 0 {
                    status = .empty // Chưa uống gì -> Circle xanh
                } else if totalAmount >= goal {
                    status = .completed // Đủ -> Tick
                } else {
                    status = .inProgress // Uống dở -> Cốc
                }
            } else if isPast {
                // Quá khứ
                if totalAmount >= goal {
                    status = .completed // Đã hoàn thành trong quá khứ -> Tick
                } else {
                    status = .failed // Qua rồi mà ko xong -> Cốc xám
                }
            }
            
            return DayStatus(date: date, status: status)
        }
    }
    
    // Nếu là tháng thì trừ month, năm thì trừ year
    func previousTime() {
        let component: Calendar.Component = selectedTab == 0 ? .month : .year
        currentDate = Calendar.current.date(byAdding: component, value: -1, to: currentDate) ?? currentDate
    }
    
    func nextTime() {
        let component: Calendar.Component = selectedTab == 0 ? .month : .year
        currentDate = Calendar.current.date(byAdding: component, value: 1, to: currentDate) ?? currentDate
    }
    
    
    

    //MARK: ---- Báo cáo nước uống ----
    func calculateReport (logs: Results<WaterLog>, goal: Double) -> WaterReport{
        let calendar = Calendar.current
        var totalWater: Double = 0
        var daysCount: Int = 1
        var weeksCount: Double = 1
        var monthsCount: Double = 1
        
        // Nếu đang là tab tháng
        if selectedTab == 0 {
            // Lấy các bản ghi trong tháng, năm đc chọn
            guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)),
                  let range = calendar.range(of: .day, in: .month, for: startOfMonth) else {return  WaterReport()}
            
            // Tính tổng lượng nước uống của cả tháng
            let logsInMonth = logs.filter { calendar.isDate($0.date, equalTo: startOfMonth, toGranularity: .month) }    // Lọc
            totalWater = logsInMonth.reduce(0) { $0 + Double($1.amount) }       // Tính
            
            // Xác định số ngày để chia tbinh, tính đến thời điểm hiện tại (mới mùng 7 thì tính 7 ngày thoi)
            let isCurrentMonth = calendar.isDate(Date(), equalTo: startOfMonth, toGranularity: .month)
            daysCount = isCurrentMonth ? calendar.component(.day, from: Date()) : range.count
            
            // Quy đổi ra tuần và tháng
            weeksCount = Double(daysCount) / 7.0
            monthsCount = 1 // vì đang ở tab tháng
            
        } else {
            // Tab Năm
            
            // Lấy các bản ghi ở năm đc chọn
            guard let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: currentDate)) else { return WaterReport() }
            
            // Tính tổng nước trong năm
            let logsInYear = logs.filter { calendar.isDate($0.date, equalTo: startOfYear, toGranularity: .year) }   // lọc
            totalWater = logsInYear.reduce(0) { $0 + Double($1.amount) }    // tính tổng
            
            // Check xem phải năm nay ko
            let isCurrentYear = calendar.isDate(Date(), equalTo: startOfYear, toGranularity: .year)
            
            if isCurrentYear {
                // Nếu năm nay thì tính đến ngày hiện tại thôi
                daysCount = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 1
            } else {
                daysCount = 365
            }
            
            // Quy đổi
            weeksCount = Double(daysCount) / 7.0
            monthsCount = Double(daysCount) / 30.0
        }
        // Tbinh tuần = Tổng nước / Số tuần
        let weeklyAvg = weeksCount > 0 ? Int(totalWater / weeksCount) : 0
        
        // Tbinh tháng
        let monthlyAvg = monthsCount > 0 ? Int(totalWater / monthsCount) : 0
        
        // Tỉ lệ hoàn thành = (Tbinh uống mỗi ngày / Mục tiêu ngày) * 100
        let dailyAvg = daysCount > 0 ? (totalWater / Double(daysCount)) : 0
        let completionAvg = Int((dailyAvg / goal) * 100)
        
        // Tần suất uống
        let totalLogsCount = selectedTab == 0
        ? logs.filter { calendar.isDate($0.date, equalTo: self.currentDate, toGranularity: .month) }.count
        : logs.filter { calendar.isDate($0.date, equalTo: self.currentDate, toGranularity: .year) }.count
        
        let frequency = daysCount > 0 ? totalLogsCount / daysCount : 0
        
        return WaterReport(
            weeklyAvg: weeklyAvg,
            monthlyAvg: monthlyAvg,
            completionAvg: completionAvg,
            frequency: frequency
        )
    }
    
    //MARK: Test data
    
    // Hàm tạo dữ liệu giả
    func createMockData() {
        guard let realm = try? Realm() else { return }
        
        let calendar = Calendar.current
        let today = Date()
        
        try? realm.write {
            // Chạy vòng lặp tạo dữ liệu cho 60 ngày quá khứ
            for dayOffset in 1..<60 {
                // Tính ngày: Hôm nay lùi lại i ngày
                guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
                
                // Random số lần uống trong ngày đó (từ 0 đến 6 lần)
                let numberOfDrinks = Int.random(in: 0...6)
                
                if numberOfDrinks > 0 {
                    for _ in 0..<numberOfDrinks {
                        let log = WaterLog()
                        
                        // Random lượng nước: 200, 300 hoặc 500ml
                        log.amount = [200, 300, 500, 400].randomElement() ?? 200
                        
                        // Set thời gian ngẫu nhiên trong ngày đó
                        let randomHour = Int.random(in: 7...22) // Uống từ 7h sáng đến 10h tối
                        let randomDate = calendar.date(bySettingHour: randomHour, minute: Int.random(in: 0...59), second: 0, of: date) ?? date
                        
                        log.date = randomDate
                        
                        // Thêm vào Realm
                        realm.add(log)
                    }
                }
            }
        }
        
        // Gán lại currentDate bằng chính nó
        // Việc này kích hoạt @Published, làm View vẽ lại
        let tempDate = currentDate
        currentDate = tempDate
        
        print("Đã tạo xong dữ liệu giả")
    }
    
    // Hàm xóa sạch dữ liệu
    func deleteAllData() {
        guard let realm = try? Realm() else { return }
        
        try? realm.write {
            // Xóa tất cả object loại WaterLog
            let allLogs = realm.objects(WaterLog.self)
            realm.delete(allLogs)
        }
        
        // Refresh UI
        let tempDate = currentDate
        currentDate = tempDate
        
        print("Đã xóa sạch dữ liệu")
    }

}



