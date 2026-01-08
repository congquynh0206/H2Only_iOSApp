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
    
    var body: some Scene {
        WindowGroup {
//            if let user = userProfiles.first, user.isOnboardingCompleted {
//                MainTabView()
//            } else {
                OnboardingView()
                    .onAppear {
                        // Gọi hàm này để đảm bảo Realm tạo sẵn 1 user mặc định nếu chưa có
                        _ = RealmManager.shared.getUserProfile()
                    }
//            }
        }
    }
}
