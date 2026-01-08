//
//  RealmManager.swift
//  H2Only
//
//  Created by Trangptt on 7/1/26.
//
import Foundation
import RealmSwift

class RealmManager: ObservableObject {
    static let shared = RealmManager()
    var realm: Realm?

    init() {
        setupRealm()
    }

    func setupRealm() {
        do {
            // Cấu hình Realm (có thể migration sau này tại đây)
            let config = Realm.Configuration(schemaVersion: 1)
            Realm.Configuration.defaultConfiguration = config
            realm = try Realm()
            print("Realm path: \(realm?.configuration.fileURL?.absoluteString ?? "Unknown")")
        } catch {
            print("Error opening Realm: \(error)")
        }
    }

    // Ví dụ hàm thêm dữ liệu
    func add<T: Object>(_ object: T) {
        guard let realm = realm else { return }
        do {
            try realm.write {
                realm.add(object)
            }
        } catch {
            print("Error adding object: \(error)")
        }
    }
    
    // Hàm lấy UserProfile
    func getUserProfile() -> UserProfile {
        guard let realm = realm else { return UserProfile() }
        
        // Tìm xem có User nào chưa
        if let existingUser = realm.objects(UserProfile.self).first {
            return existingUser
        } else {
            // Chưa có thì tạo mới - Lần đầu mở app
            let newUser = UserProfile()
            try? realm.write {
                realm.add(newUser)
            }
            return newUser
        }
    }
    
    // Hàm update UserProfile an toàn
    func updateProfile(action: (UserProfile) -> Void) {
        guard let realm = realm else { return }
        let user = getUserProfile()
        
        do {
            try realm.write {
                action(user) // Thực hiện thay đổi bên trong block
            }
        } catch {
            print("Error updating profile: \(error)")
        }
    }
}
