//
//  H2OnlyApp.swift
//  H2Only
//
//  Created by Trangptt on 7/1/26.
//

import SwiftUI
import RealmSwift

@main
struct H2OnlyApp: SwiftUI.App {
    // Lắng nghe thay đổi của UserProfile từ Realm
    @ObservedResults(UserProfile.self) var userProfiles
    @StateObject var viewModel = SettingViewModel()
    init() {
        _ = RealmManager.shared
        NotificationManager.shared.requestAuthorization()
    }
    
    var body: some Scene {
        WindowGroup {
            if let user = userProfiles.first, user.isOnboardingCompleted {
                MainTabView()
            } else {
                OnboardingView(settingVM: viewModel)
                    .onAppear {
                        _ = RealmManager.shared.getUserProfile() // không cần dùng kết quả trả về
                    }
            }
        }
    }
}
