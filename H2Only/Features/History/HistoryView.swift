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
        NavigationView {
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
                            WeekFinish()
                            DrinkWaterReport().padding(.horizontal,20)
                            Character().padding(.horizontal,20)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// SubView

//Hoàn thành hàng tuần
struct WeekFinish: View {
    let days = ["CN", "Th 2", "Th 3", "Th 4", "Th 5", "Th 6", "Th 7"]
    let status = [true, true, false, true, false, true, false]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Hoàn thành hàng tuần")
                .font(.headline)
                .padding(.leading, 5)
            
            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { index in
                    IconWeekFinish(isFinish: status[index], date: days[index])
                        .frame(maxWidth: .infinity) // Chia đều chiều ngang
                }
            }
        }
        .padding(15)
        .background(Color(.systemGray5))
    }
}

// Báo cáo nước uống
struct DrinkWaterReport: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Báo cáo nước uống")
                .font(.headline)
                .padding(15)
           
            
            VStack(spacing: 0) {
                ReportRow(color: .green, content: "Trung bình hàng tuần", result: "9525 ml/ ngày")
                ReportRow(color: .blue, content: "Trung bình hàng tháng", result: "4469 ml/ ngày")
                ReportRow(color: .orange, content: "Hoàn thành trung bình", result: "59 %")
                ReportRow(color: .red, content: "Tần suất uống", result: "7 lần / ngày")
            }
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
                .offset(x: 12, y: -15)
            
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
    }
}


// Reusable item
struct IconWeekFinish: View {
    let isFinish: Bool
    let date: String
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                if isFinish {
                    Image("ic_completed_day") // Thay ảnh thật
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.green) // Fallback color
                    
                    Image("ic_tick") // Thay ảnh thật
                        .resizable()
                        .frame(width: 15, height: 15)
                        .offset(x: 10, y: -10)
                        .foregroundColor(.green)
                } else {
                    Image("ic_incompleted_day") // Thay ảnh thật
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.gray.opacity(0.3))
                }
            }
            
            Text(date)
                .font(.caption)
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



