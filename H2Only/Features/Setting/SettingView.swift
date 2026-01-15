//
//  SettingView.swift
//  H2Only
//
//  Created by Trangptt on 15/1/26.
//
import SwiftUI

struct SettingView : View {
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("CÀI ĐẶT NHẮC NHỞ")) {
                    NavigationLink("Lịch nhắc nhở") {
                         ReminderCalendar()
                    }
                    NavigationLink("Âm thanh nhắc nhở") {
                         ReminderSound()
                    }
                }
                Section(header: Text("CHUNG")) {
                    HStack {
                        Text("Đơn vị")
                        Spacer()
                        Text("kg, ml")
                            .foregroundStyle(.blue)
                            .fontWeight(.medium)
                    }
                    
                    // Item: Mục tiêu
                    HStack {
                        Text("Mục tiêu lượng nước uống")
                        Spacer()
                        Text("10810 ml")
                            .foregroundStyle(.blue)
                            .fontWeight(.medium)
                    }
                    
                }
                
                Section(header: Text("DỮ LIỆU CÁ NHÂN")) {
                    HStack {
                        Text("Giới tính")
                        Spacer()
                        Text("Nam")
                            .foregroundStyle(.blue)
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Text("Cân nặng")
                        Spacer()
                        Text("299 kg")
                            .foregroundStyle(.blue)
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Text("Giờ thức dậy")
                        Spacer()
                        Text("07:20")
                            .foregroundStyle(.blue)
                            .fontWeight(.medium)
                    }
                    
                    HStack {
                        Text("Giờ đi ngủ")
                        Spacer()
                        Text("00:30")
                            .foregroundStyle(.blue)
                            .fontWeight(.medium)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Cài đặt")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SettingView()
}
