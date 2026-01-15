//
//  Graph.swift
//  H2Only
//
//  Created by Trangptt on 13/1/26.
//

import SwiftUI
import Charts
import RealmSwift

struct Graph: View {
    @ObservedObject var viewModel: HistoryViewModel
    var waterLogs: Results<WaterLog>
    var dailyGoal: Double
    
    // Helper để xác định các ngày cần hiện grid
    private let showLabelDays = [1, 7, 14, 21, 28]
    private let showLabelMonths = [1, 3, 6, 9, 12]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            
            let data = viewModel.generateChartData(from: waterLogs, goal: dailyGoal)
            let unit: Calendar.Component = viewModel.selectedTab == 0 ? .day : .month
            
            Chart {
                ForEach(data) { item in
                    BarMark(
                        x: .value("Time", item.date, unit: unit),
                        y: .value("Percent", min(item.percent, 1.0) * 100)
                    )
                    .foregroundStyle(Color.cyan)
                    .annotation(position: .top, spacing: 5) {
                        if item.percent >= 1.0 {
                            Image("ic_day_completed")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 10, height: 10)
                        }
                    }
                }
            }
            .chartYScale(domain: 0...115)
            .overlay(alignment: .topLeading) {
                Text("(%)")
                    .font(.caption)
                    .foregroundColor(.black)
                    .offset(y: -10)
            }
            // Trục Y
            .chartYAxis {
                AxisMarks(position: .leading, values: [0, 20, 40, 60, 80, 100]) { value in
                    
                    if let intValue = value.as(Int.self), intValue == 0 {
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 1))
                            .foregroundStyle(Color.black.opacity(0.5))
                    } else {
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [5]))
                            .foregroundStyle(Color.black.opacity(0.5))
                    }
                    AxisValueLabel()
                        .font(.caption2)
                        .foregroundStyle(Color.black)
                }
            }
            // Trục X
            .chartXAxis {
                if viewModel.selectedTab == 0 {
                    // Biểu đồ tháng
                    AxisMarks(position: .bottom, values: .stride(by: .day, count: 1)) { value in
                        // Vẽ tick
//                        AxisValueLabel(collisionResolution: .greedy) {
//                            Rectangle()
//                                .fill(Color.gray)
//                                .frame(width: 1, height: 10)
//                                .offset(y: -14) 
//                        }
                        
                        AxisTick(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(Color.gray)
                            .offset(y: -18.5)
                        
                        
                        
                        // Nhãn và GridLine
                        if let date = value.as(Date.self) {
                            let day = Calendar.current.component(.day, from: date)
                            
                            if showLabelDays.contains(day) {
                                AxisGridLine(stroke: StrokeStyle(lineWidth: 1))
                                    .foregroundStyle(Color.black.opacity(0.5))
                                
                                AxisValueLabel {
                                    Text("\(day)")
                                        .font(.caption2)
                                        .foregroundStyle(Color.black)
                                        .offset(x: -7)
                                    
                                }
                            }
                        }
                    }
                } else {
                    // Biểu đồ năm
                    AxisMarks(values: .stride(by: .month, count: 1)) { value in
//                        AxisValueLabel(collisionResolution: .greedy) {
//                            Rectangle()
//                                .fill(Color.gray)
//                                .frame(width: 1, height: 10)
//                                .offset(y: -14)
//                      }
                        AxisTick(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(Color.gray)
                            .offset(y: -18.5)
                        
                        if let date = value.as(Date.self) {
                            let month = Calendar.current.component(.month, from: date)
                            
                            if showLabelMonths.contains(month) {
                                AxisGridLine(stroke: StrokeStyle(lineWidth: 1))
                                    .foregroundStyle(Color.black.opacity(0.5))
                            }
                            AxisValueLabel {
                                Text("\(month)")
                                    .font(.caption2)
                                    .foregroundStyle(Color.black)
                                    .offset(x: -7)
                            }
                        }
                    }
                }
            }
            .frame(height: 220)
            .padding(.horizontal, 10)
        }
        .background(Color.white)
    }
}

// Chuyển ngày
struct DateControlView: View {
    @ObservedObject var viewModel: HistoryViewModel
    
    var body: some View {
        HStack (spacing: 20){
            Spacer()
            Button(action: { viewModel.previousTime() }) {
                Image("ic_backward_normal")
                    .resizable().frame(width: 20, height: 20)
                    .foregroundColor(.gray)
            }
            .frame(width: 40, height: 40)
            
            
            Text(viewModel.timeTitle)
                .font(.headline)
                .frame(minWidth: 150)
                .fontWeight(.bold)
            
            
            Button(action: { viewModel.nextTime() }) {
                Image("ic_forward_normal")
                    .resizable().frame(width: 20, height: 20)
                    .foregroundColor(.gray)
            }
            .frame(width: 40, height: 40)
            Spacer()
        }
        
        .padding(.vertical, 5)
        .background(Color.white)
    }
}
