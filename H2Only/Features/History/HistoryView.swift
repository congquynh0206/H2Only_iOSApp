//
//  HistoryView.swift
//  H2Only
//
//  Created by Trangptt on 13/1/26.
//

import SwiftUI
import Charts
import RealmSwift

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    
    // Realm Data
    @ObservedResults(WaterLog.self) var waterLogs
    @ObservedResults(UserProfile.self) var userProfiles
    
    var dailyGoal: Double {
        return Double(userProfiles.first?.dailyGoal ?? 2000)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Title
            Text("Lịch sử")
                .font(.headline)
                .padding(.vertical, 10)
            
            
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // Header Control
                    DateControlView(viewModel: viewModel)
                    
                    Graph(viewModel: viewModel, waterLogs: waterLogs, dailyGoal: dailyGoal)
                    
                    // Picker Tab
                    Picker("View Mode", selection: $viewModel.selectedTab) {
                        Text("Tháng").tag(0)
                        Text("Năm").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 170)
                    .background(Color.blue.opacity(0.5))
                    .cornerRadius(10)
                    .padding(2)
                    
                    // UI ở dưới
                    VStack(spacing: 10) {
                        WeekFinish(viewModel: viewModel, logs: waterLogs, goal: dailyGoal)
                        DrinkWaterReport(viewModel: viewModel, logs: waterLogs, goal: dailyGoal)
                            .padding(.horizontal,10)
                        Character().padding(.horizontal,20)
                    }
                }
            }
        }
    }
}

// SubView

//Hoàn thành hàng tuần
struct WeekFinish: View {
    @ObservedObject var viewModel: HistoryViewModel
    var logs: Results<WaterLog>
    var goal: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Hoàn thành hàng tuần")
                    .font(.headline)
                
                Spacer()
                
                // Chỉ hiện mũi tên nếu đang ở Tab Tháng
                if viewModel.selectedTab == 0 {
                    HStack(spacing: 15) {
                        Button(action: { viewModel.changeWeek(by: -1) }) {
                            Image(systemName: "chevron.left")
                                .font(.caption)
                                .foregroundColor(.black)
                        }
                        
                        // Title
                        Text(viewModel.weekRangeTitle)
                            .font(.caption)
                            .frame(minWidth: 80) 
                        
                        Button(action: { viewModel.changeWeek(by: 1) }) {
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.3))
                    .cornerRadius(8)
                } else {
                    Text("Tuần này")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 5)
            
            // 7 ICON
            let weeklyStatus = viewModel.getWeeklyStatus(logs: logs, goal: goal)
            
            HStack(spacing: 0) {
                ForEach(weeklyStatus, id: \.date) { item in
                    IconWeekFinish(status: item.status, date: item.date)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(15)
        .background(Color(.systemGray5))
    }
}

// Báo cáo nước uống
struct DrinkWaterReport: View {
    @ObservedObject var viewModel : HistoryViewModel
    let logs : Results<WaterLog>
    let goal : Double
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Báo cáo nước uống")
                .font(.headline)
                .padding(.leading, 10)
            
            
            VStack(spacing: 0) {
                let report = viewModel.calculateReport(logs: logs, goal: goal)
                ReportRow(color: .green, content: "Trung bình hàng tuần", result: "\(report.weeklyAvg) ml/ tuần")
                ReportRow(color: .blue, content: "Trung bình hàng tháng", result: "\(report.monthlyAvg) ml/ tháng")
                ReportRow(color: .orange, content: "Hoàn thành trung bình", result: "\(report.completionAvg) %")
                ReportRow(color: .red, content: "Tần suất uống", result: "\(report.completionAvg) lần / ngày")
            }
            .padding(.horizontal, 20)
        }
        .background(Color.white)
    }
}


// Con xanh xanh ở dưới
struct Character : View {
    var body: some View {
        HStack{
            Image("character")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
            
            Image("ic_triangle")
                .resizable()
                .scaledToFit()
                .frame(width: 15, height: 15)
                .offset(x: 10.5, y: -15)
            
            HStack(){
                // Nội dung
                Text("Một tâm trí và cơ thể khoẻ mạnh bao giờ cũng phải đầy đủ nước. Bạn hãy thử xem!")
                    .font(.caption)
                    .padding()
            }
            .foregroundStyle(.black)
            .background(Color.blue.opacity(0.15))
            .cornerRadius(12)
        }
        .padding(.bottom, 20)
    }
}


// Reusable item
struct IconWeekFinish: View {
    let status : DailyStatus
    let date: Date
    
    var dayLabel: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "vi_VN")
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                switch status {
                case .empty:
                    Circle()
                        .fill(Color.blue.opacity(0.6))
                        .frame(width: 36, height: 36)
                    
                case .inProgress:
                    Image("ic_completed_day")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                        .foregroundColor(.cyan)
                    
                case .completed:
                    ZStack {
                        Image("ic_completed_day")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 36, height: 36)
                            .foregroundColor(.cyan)
                        
                        Image("ic_tick") // Dấu tick
                            .resizable()
                            .frame(width: 14, height: 14)
                            .offset(x: 12, y: -12)
                    }
                    
                case .failed:
                    Image("ic_incompleted_day")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                        .foregroundColor(.gray)
                }
            }
            
            Text(dayLabel)
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }
}

// Reusable item
struct ReportRow: View {
    let color: Color
    let content: String
    let result: String
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 15) {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                
                Text(content)
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                
                Spacer()
                
                Text(result)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.textHighlighted)
            }
            .padding(.vertical, 20)
            
            Divider()
        }
    }
}



