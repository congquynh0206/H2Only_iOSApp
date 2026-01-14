//
//  HistoryViewModel.swift
//  H2Only
//
//  Created by Trangptt on 13/1/26.
//

import Foundation
import RealmSwift
import SwiftUI

class HistoryViewModel: ObservableObject {
    // 0: Tháng, 1: Năm
    @Published var selectedTab: Int = 0
    @Published var currentDate: Date = Date()
    
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
    
    // Nếu là tháng thì trừ month, năm thì trừ year
    func previousTime() {
        let component: Calendar.Component = selectedTab == 0 ? .month : .year
        currentDate = Calendar.current.date(byAdding: component, value: -1, to: currentDate) ?? currentDate
    }
    
    func nextTime() {
        let component: Calendar.Component = selectedTab == 0 ? .month : .year
        currentDate = Calendar.current.date(byAdding: component, value: 1, to: currentDate) ?? currentDate
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
    
    
    // Báo cái nước uống
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
}
