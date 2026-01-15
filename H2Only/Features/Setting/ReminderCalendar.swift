//
//  ReminderCalendar.swift
//  H2Only
//
//  Created by Trangptt on 15/1/26.
//

import SwiftUI
import RealmSwift

struct ReminderCalendar: View {
    @StateObject private var viewModel = SettingViewModel()
    
    @ObservedResults(UserProfile.self) var userProfiles
    
    var userProfile: UserProfile? {
        userProfiles.first
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // Subtitle
                Text("Chúng tôi sẽ tối ưu hoá thời gian nhắc nhở dựa trên lịch sử hồ sơ của bạn")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGroupedBackground))
                
                List {
                    if let profile = userProfile {
                        if profile.reminderSchedule.isEmpty {
                            Text("Không có lịch nhắc nhở nào")
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .listRowBackground(Color.clear)
                        } else {
                            ForEach(profile.reminderSchedule) { item in
                                HStack {
                                    // Edit
                                    Button(action: {
                                        viewModel.prepareEdit(item: item)
                                    }) {
                                        Text(item.time, formatter: timeFormatter)
                                            .font(.title3)
                                            .foregroundColor(.black)
                                    }
                                    .buttonStyle(.plain)
                                    
                                    Spacer()
                                    
                                    // Toggle
                                    Toggle("", isOn: Binding(get: {
                                        item.isEnabled
                                    }, set: { newValue in
                                        viewModel.toggleItem(item, isEnabled: newValue)
                                    }))
                                    .labelsHidden()
                                    .tint(.blue)
                                }
                                .padding(.vertical, 5)
                            }
                            // Delete
                            .onDelete(perform: viewModel.deleteItem)
                        }
                    }
                }
                .listStyle(.grouped)
                .scrollContentBackground(.hidden)
                .background(Color(.systemGroupedBackground))
            }
            
            // Button Thêm
            Button(action: {
                viewModel.prepareAdd()
            }) {
                Image("ic_add_reminder")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .shadow(radius: 4, y: 4)
            }
            .padding(.bottom, 20)
        }
        .navigationTitle("Lịch nhắc nhở")
        .navigationBarTitleDisplayMode(.inline)
        
        // Popup Sheet
        .sheet(isPresented: $viewModel.showEditPopup) {
            VStack(spacing: 20) {
                Text(viewModel.editingItem == nil ? "Thêm giờ nhắc" : "Sửa giờ nhắc")
                    .font(.headline)
                    .padding(.top)
                
                // DatePicker
                DatePicker("Chọn giờ", selection: $viewModel.selectedTimeForEdit, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                
                HStack(spacing: 60) {
                    Button("Hủy") {
                        viewModel.showEditPopup = false
                    }
                    .foregroundColor(.red)
                    
                    Button("Lưu") {
                        viewModel.saveItem()
                        viewModel.showEditPopup = false
                    }
                    .fontWeight(.bold)
                }
                .padding()
            }
            .presentationDetents([.height(300)])
        }
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
}
