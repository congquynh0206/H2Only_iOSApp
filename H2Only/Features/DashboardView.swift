//
//  DashboardView.swift
//  H2Only
//
//  Created by Trangptt on 7/1/26.
//

import SwiftUI
import RealmSwift // Nhớ import cái này

struct DashboardView: View {
    // 1. KHAI BÁO BIẾN NÀY TẠI ĐÂY (Đây là chìa khoá để UI tự update)
    @ObservedResults(WaterLog.self) var waterLogs
    
    @StateObject var viewModel = DashboardViewModel()
    
    // 2. Tính tổng nước trực tiếp từ biến waterLogs của View
    var currentIntake: Int {
        waterLogs.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Mục tiêu hôm nay")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                LottieView(filename: "cup400", loopMode: .playOnce)
                    .frame(width: 250, height: 250)
                
                // 3. Dùng biến currentIntake đã tính ở trên
                Text("\(currentIntake) ml")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.blue)
                
                Button(action: {
                    // Gọi hàm add bên ViewModel
                    viewModel.addWater(amount: 200)
                }) {
                    Text("Uống nước")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
            }
        }
    }
}
