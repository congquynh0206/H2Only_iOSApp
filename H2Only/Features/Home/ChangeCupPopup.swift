//
//  ChangeCupPopup.swift
//  H2Only
//
//  Created by Trangptt on 9/1/26.
//

import SwiftUI

struct ChangeCupPopup: View {
    @ObservedObject var viewModel: DashboardViewModel
    @Binding var isPresented: Bool
    
    // State quản lý các Alert con
    @State private var showCustomizeAlert = false
    @State private var showInvalidAlert = false
    @State private var customAmountString = ""
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            // Tiêu đề
            HStack {
                Text("Đổi cốc")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            // Lưới cốc
            LazyVGrid(columns: columns, spacing: 25) {
                // Hiển thị list cốc từ Realm
                if let user = viewModel.userProfile {
                    ForEach(user.cups, id: \.id) { cup in
                        CupItemView(cup: cup,
                                    isSelected: user.selectedCupSize == cup.amount)
                        .onTapGesture {
                            viewModel.selectCup(cup.amount)
                        }
                        .contextMenu{
                            Button ("Xoá cốc" ){
                                viewModel.deleteCup(cup)
                            }
                        }
                    }
                }
                
                // Nút Customize
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
            .padding(.horizontal)
            
            Spacer().frame(height: 10)
            
            //  Nút Hủy bỏ / Đồng ý  - Popup chính
            HStack(spacing: 90) {
                Button(action: {
                    isPresented = false
                }) {
                    Text("HỦY BỎ")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                Button(action: {
                    isPresented = false
                }) {
                    Text("ĐỒNG Ý")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.blue)
                }
            }
            .padding(.bottom, 20)
        }
        .frame(width: 320)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 20)
        .overlay(
            Group {
                // Alert nhập số
                if showCustomizeAlert {
                    CustomAmountAlert(
                        isPresented: $showCustomizeAlert,
                        isShowInvalid: $showInvalidAlert, // Truyền binding để mở alert lỗi
                        onConfirm: { amount in
                            viewModel.addCustomCup(amount: amount)
                        }
                    )
                }
                
                // Alert báo lỗi
                if showInvalidAlert {
                    InValidCustomAlert(isPresented: $showInvalidAlert)
                }
            }
        )
    }
}

// Subview: Một ô Cốc
struct CupItemView: View {
    let cup: Cup
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Image(getIconName())
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
            
            Text("\(cup.amount) ml")
                .font(.caption)
                .foregroundColor(isSelected ? .blue : .black)
        }
    }
    
    func getIconName() -> String {
        let base = cup.iconName
            .replacingOccurrences(of: "_normal", with: "")
            .replacingOccurrences(of: "_selected", with: "")
            .replacingOccurrences(of: "_add", with: "")
        
        return isSelected ? "\(base)_selected" : "\(base)_normal"
    }
}

// Custom alert: Nhập số ml
struct CustomAmountAlert: View {
    @Binding var isPresented: Bool
    @Binding var isShowInvalid: Bool
    var onConfirm: (Int) -> Void
    @State private var text: String = ""
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
                .onTapGesture { isPresented = false }
            
            VStack(spacing: 20) {
                Text("Tùy chỉnh cốc uống nước của bạn")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)
                
                HStack(alignment: .bottom) {
                    Image("ic_cup_customize_selected")
                        .resizable()
                        .frame(width: 30, height: 30)
                    
                    VStack(spacing: 0) {
                        TextField("", text: $text)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .frame(width: 100)
                        
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray)
                            .frame(width: 120)
                    }
                    
                    Text("ml")
                        .font(.body)
                }
                .padding(.vertical, 10)
                
                HStack(spacing: 80) {
                    Button("HỦY BỎ") {
                        isPresented = false
                    }
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
                    
                    Button("ĐỒNG Ý") {
                        // Logic kiểm tra số hợp lệ
                        if let amount = Int(text) {
                            if amount < 30 || amount > 3000 {
                                // Nếu sai thì đóng alert nhập -> Mở alert lỗi
                                isPresented = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    isShowInvalid = true
                                }
                            } else {
                                // Nếu đúng: Gọi hàm confirm
                                onConfirm(amount)
                                isPresented = false
                            }
                        }
                    }
                    .foregroundColor(.blue)
                    .font(.system(size: 14, weight: .bold))
                }
                .padding(.bottom, 20)
            }
            .frame(width: 300)
            .background(Color.white)
            .cornerRadius(16)
        }
        .zIndex(3)
    }
}

// Custom alert: Báo lỗi
struct InValidCustomAlert: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
                .onTapGesture { isPresented = false }
            
            VStack(spacing: 20) {
                Text("Tuỳ chỉnh cốc không hợp lệ")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)
                
                Text("Vui lòng nhập cốc trong khoảng\n 30 đến 3000 ml")
                    .foregroundColor(.textHighlighted)
                    .multilineTextAlignment(.center)
                    .font(.body)
                    .padding(.horizontal)
                
                
                Button("Đã hiểu") {
                    isPresented = false
                }
                .padding(.bottom, 20)
                .foregroundColor(.blue)
                .font(.system(size: 15, weight: .bold))
            }
            .frame(width: 300)
            .background(Color.white)
            .cornerRadius(16)
        }
        .zIndex(4)
    }
}
