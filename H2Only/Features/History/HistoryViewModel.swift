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
            // Goal của tháng = Goal ngày * 30 (ước lượng trung bình để tính %)
            let monthlyGoal = goal * 30
            return ChartDataPoint(date: date, amount: amount, goal: monthlyGoal, label: "T\(month)")
        }
    }
}
