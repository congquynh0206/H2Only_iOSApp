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
                    Image("ic_home").renderingMode(.template)
                    Text("Trang chủ")
                }
            
            HistoryView()
                .tabItem {
                    Image("ic_history").renderingMode(.template)
                    Text("Lịch sử")
                }
            
            SettingView()
                .tabItem {
                    Image("ic_setting").renderingMode(.template)
                    Text("Cài đặt")
                }
        }
        .accentColor(.blue) // Màu active của tab
    }
}
