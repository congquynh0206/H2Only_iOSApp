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
            Text("(%)")
                .font(.caption)
                .foregroundColor(.black)
                .padding(.leading, 5)
            
            let data = viewModel.generateChartData(from: waterLogs, goal: dailyGoal)
            
            Chart {
                ForEach(data) { item in
                    BarMark(
                        x: .value("Time", item.date),
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
            // Trục Y
            .chartYAxis {
                AxisMarks(position: .leading, values: [0, 20, 40, 60, 80, 100]) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 1))
                        .foregroundStyle(Color.black.opacity(0.5))
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
                        AxisValueLabel(collisionResolution: .greedy) {
                            Rectangle()
                                .fill(Color.gray)
                                .frame(width: 1, height: 10)
                                .offset(y: -14) 
                        }
                        
                        // Nhãn và GridLine
                        if let date = value.as(Date.self) {
                            let day = Calendar.current.component(.day, from: date)
                            
                            if showLabelDays.contains(day) {
                                AxisGridLine(stroke: StrokeStyle(lineWidth: 1))
                                    .foregroundStyle(Color.black.opacity(0.5))
                                
                                AxisValueLabel {
                                    if day == 1 {
                                        Text("thg \(Calendar.current.component(.month, from: date))")
                                            .font(.caption2)
                                            .foregroundStyle(Color.black)
                                    } else {
                                        Text("\(day)")
                                            .font(.caption2)
                                            .foregroundStyle(Color.black)
                                    }
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
//                        }
                        
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
                            }
                        }
                    }
                }
            }
            .frame(height: 250)
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
