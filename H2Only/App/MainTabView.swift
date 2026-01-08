//
//  MainTabView.swift
//  H2Only
//
//  Created by Trangptt on 8/1/26.
//
import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Image(systemName: "drop.fill")
                    Text("Trang chủ")
                }
            
            Text("Màn hình Lịch sử (Đang làm)")
                .tabItem {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("Lịch sử")
                }
            
            Text("Màn hình Cài đặt (Đang làm)")
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Cài đặt")
                }
        }
        .accentColor(.blue) // Màu active của tab
    }
}
