//
//  SettingView.swift
//  H2Only
//
//  Created by Trangptt on 15/1/26.
//
import SwiftUI
import RealmSwift

struct SettingView : View {
    @StateObject var viewModel = SettingViewModel()
    @ObservedResults(UserProfile.self) var userProfiles
    var user: UserProfile? { userProfiles.first }
    
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
                        Button(action: {
                            viewModel.openGoalPopup()
                        }) {
                            Text("\(user?.dailyGoal ?? 2000) ml")
                                .foregroundStyle(.blue)
                                .fontWeight(.medium)
                        }
                    }
                }
                
                Section(header: Text("DỮ LIỆU CÁ NHÂN")) {
                    HStack {
                        Text("Giới tính")
                        Spacer()
                        Button(action: {
                            viewModel.openGenderPopup()
                        }) {
                            Text(user?.gender == .male ? "Nam" : "Nữ")
                                .foregroundStyle(.blue)
                                .fontWeight(.medium)
                        }
                    }
                    
                    HStack {
                        Text("Cân nặng")
                        Spacer()
                        Button(action: {
                            viewModel.openWeightPopup()
                        }) {
                            Text("\(Int(user?.weight ?? 60)) kg")
                                .foregroundStyle(.blue)
                                .fontWeight(.medium)
                        }
                    }
                    
                    // Giờ dậy
                    HStack {
                        Text("Giờ thức dậy")
                        Spacer()
                        Button(action: {
                            viewModel.openProfileTimePicker(type: .wakeUpTime, currentTime: user?.wakeUpTime)
                        }) {
                            Text(user?.wakeUpTime ?? Date(), formatter: timeFormatter)
                                .foregroundStyle(.blue)
                                .fontWeight(.medium)
                        }
                    }
                    
                    // Giờ ngủ
                    HStack {
                        Text("Giờ đi ngủ")
                        Spacer()
                        
                        Button(action: {
                            viewModel.openProfileTimePicker(type: .bedTime, currentTime: user?.bedTime)
                        }) {
                            Text(user?.bedTime ?? Date(), formatter: timeFormatter)
                                .foregroundStyle(.blue)
                                .fontWeight(.medium)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Cài đặt")
            .navigationBarTitleDisplayMode(.inline)
        }
        .overlay {
            // Giờ
            if viewModel.showEditPopup {
                TimePickerPopup(
                    isPresented: $viewModel.showEditPopup,
                    selection: $viewModel.selectedTimeForEdit, // Binding
                    onSave: {
                        viewModel.saveProfileTime()
                    }
                )
            }
            // Giới tính
            if viewModel.showGenderPopup {
                GenderPickerPopup(
                    isPresented: $viewModel.showGenderPopup,
                    currentGender: $viewModel.tempGender, // Binding vào biến tạm
                    onSave: { viewModel.saveGender() }
                )
            }
            
            // Cân nặng
            if viewModel.showWeightPopup {
                WeightPickerPopup(
                    isPresented: $viewModel.showWeightPopup,
                    selection: $viewModel.tempWeight,
                    onSave: { viewModel.saveWeight() }
                )
            }
            
            // Goal
            if viewModel.showGoalPopup {
                GoalPickerPopup(
                    isPresented: $viewModel.showGoalPopup,
                    goal: $viewModel.tempGoal,
                    recommendedGoal: viewModel.recommendedGoal,
                    onSave: { viewModel.saveGoal() }
                )
            }
            
        }
        
        .alert("Cập nhật lịch nhắc nhở", isPresented: $viewModel.showRescheduleAlert) {
            Button("Giữ lịch cũ", role: .cancel) { }
            
            Button("Tạo lại", role: .destructive) {
                viewModel.createNewSchedule()
            }
        } message: {
            Text("Bạn vừa thay đổi thời gian sinh hoạt. Bạn có muốn xoá lịch cũ và tạo lại lịch nhắc nhở mới phù hợp hơn không?")
        }
    }
}
private var timeFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter
}


#Preview {
    SettingView()
}
