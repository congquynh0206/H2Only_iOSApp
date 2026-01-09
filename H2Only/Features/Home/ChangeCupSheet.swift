//
//  ChangeCupSheet.swift
//  H2Only
//
//  Created by Trangptt on 9/1/26.
//
import SwiftUI

struct ChangeCupSheet: View {
    @ObservedObject var viewModel: DashboardViewModel
    @Environment(\.dismiss) var dismiss
    
    // Quản lý Alert nhập số
    @State private var showCustomizeAlert = false
    @State private var customAmountString = ""
    
    // Grid 3 cột
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    
                    // Danh sách cốc từ Realm
                    displayCupButton(viewModel: viewModel)
                    
                    // Nút Customize, luôn nằm cuối
                    Button(action: {
                        customAmountString = ""
                        showCustomizeAlert = true
                    }) {
                        VStack {
                            Image("ic_cup_customize_plus")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                            
                            Text("Tùy chỉnh")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        .padding()
                    }
                }
                .padding()
            }
            .navigationTitle("Đổi cốc")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Đóng") { dismiss() }
                }
            }
            // C. Alert nhập số ml
            .alert("Tuỳ chỉnh cốc uống nước của bạn", isPresented: $showCustomizeAlert) {
                TextField("Số ml ", text: $customAmountString)
                    .keyboardType(.numberPad)
                
                Button("Hủy", role: .cancel) { }
                
                Button("OK") {
                    if let amount = Int(customAmountString), amount > 0 {
                        viewModel.addCustomCup(amount: amount)
                    }
                }
            } message: {
                Text("Nhập lượng nước cho loại cốc mới của bạn.")
            }
        }
    }
}

struct displayCupButton : View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        if let user = viewModel.userProfile {
            ForEach(user.cups, id: \.id) { cup in
                let isSelected = (user.selectedCupSize == cup.amount)
                Button(action: {
                    viewModel.selectCup(cup.amount)
                    print("đã chọn cốc \(cup.amount)")
                }) {
                    VStack {
                        Image(getDisplayIconName(originalName: cup.iconName, isSelected: isSelected))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                        
                        Text("\(cup.amount) ml")
                            .font(.caption)
                            .foregroundColor(isSelected ? .blue : .black)
                            .fontWeight(isSelected ? .bold : .regular)
                    }
                    .padding()
                    
                }
            }
        }
    }
    // Xử lý tên icon
    func getDisplayIconName(originalName: String, isSelected: Bool) -> String {
        let baseName = originalName
                    .replacingOccurrences(of: "_normal", with: "")
                    .replacingOccurrences(of: "_selected", with: "")
                    .replacingOccurrences(of: "_add", with: "")
       
        if isSelected {
            return baseName + "_selected"
        } else {
            return baseName + "_normal"
        }
    }
}
