//
//  TimePickerPopup.swift
//  H2Only
//
//  Created by Trangptt on 15/1/26.
//

import SwiftUI

struct TimePickerPopup: View {
    @Binding var isPresented: Bool
    @Binding var selection: Date // Giờ đang chọn
    
    var onSave: () -> Void
    
    var body: some View {
        BasePopup(
            title: "Cài đặt thời gian",
            isPresented: $isPresented,
            onCancel: {
                
            },
            onConfirm: {
                onSave()
            }
        ) {
            // Nội dung
            DatePicker("", selection: $selection, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(height: 150) // Giới hạn chiều cao
                .clipped()
        }
    }
}

struct GenderPickerPopup : View {
    @Binding var isPresented: Bool
    @Binding var currentGender : Gender
    
    var onSave: () -> Void
    var body: some View {
        BasePopup(
            title: "Giới tính",
            isPresented: $isPresented,
            onCancel: {},
            onConfirm: {
                onSave()
            })
        {
            VStack(alignment: .leading, spacing: 10){
                // Nam
                GenderOption(
                    title: "Nam",
                    isSelected: currentGender == .male
                ) {
                    currentGender = .male
                }
                
                // Nữ
                GenderOption(
                    title: "Nữ",
                    isSelected: currentGender == .female
                ) {
                    currentGender = .female
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 50)
            .padding(.horizontal, 20)
        }
    }
}

// Sub-gender
struct GenderOption: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                // Dấu tick tròn
                Image(isSelected ? "ic_selected" : "ic_unselect")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(isSelected ? .blue : .gray)
                
            }
        }
    }
}

// Cân nặng
struct WeightPickerPopup: View {
    @Binding var isPresented: Bool
    @Binding var selection: Double
    var onSave: () -> Void
    
    var body: some View {
        BasePopup(
            title: "Cân nặng",
            isPresented: $isPresented,
            onConfirm: onSave
        ) {
            HStack {
                Picker("Cân nặng", selection: Binding(get: {
                    Int(selection)
                }, set: { newVal in
                    selection = Double(newVal)
                })) {
                    ForEach(30...150, id: \.self) { i in
                        Text("\(i)").tag(i)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
                .clipped()
                
                Text("kg")
                    .font(.title3)
                    .fontWeight(.medium)
            }
        }
    }
}

// Mục tiêu nc uống
struct GoalPickerPopup: View {
    @Binding var isPresented: Bool
    @Binding var goal: Double         // Giá trị đang kéo
    var recommendedGoal: Double       // Giá trị đề xuất
    var onSave: () -> Void
    
    // Cấu hình Slider
    let minVal: Double = 0
    let maxVal: Double = 15000
    
    var body: some View {
        BasePopup(
            title: "Điều chỉnh mục tiêu",
            isPresented: $isPresented,
            onConfirm: onSave
        ) {
            VStack(spacing: 15) {
                
                // Hiển thị ml,  nút Reset
                HStack {
                    Text("\(Int(goal))")
                        .font(.system(size: 24, weight: .regular))
                    Text("ml")
                        .font(.body)
                        .padding(.top, 8)
                    
                    // Nút Reset về đề xuất
                    Button(action: {
                        withAnimation {
                            goal = recommendedGoal
                        }
                    }) {
                        Image("ic_reset")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    }
                    .padding(.leading, 25)
                }
                
                //  Slider Custom
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        // Thanh Slider mặc định
                        Slider(value: $goal, in: minVal...maxVal)
                            .accentColor(.blue)
                            .zIndex(1)
                        
                        // Tính vị trí tương đối
                        let percent = CGFloat((recommendedGoal - minVal) / (maxVal - minVal))
                        let xPos = percent * geo.size.width
                        
                        VStack() {
                            // Vạch kẻ
                            Rectangle()
                                .fill(Color.black)
                                .frame(width: 1, height: 20)
                                .zIndex(0)
                            
                            // Chữ "Đề xuất"
                            Text("Đề xuất")
                                .font(.caption2)
                                .foregroundColor(.black)
                                .fixedSize()
                        }
                        .position(x: xPos, y: 35)
                    }
                }
                .frame(height: 50)
                .padding(.horizontal, 10)
            }
            .padding(.vertical, 10)
        }
    }
}

