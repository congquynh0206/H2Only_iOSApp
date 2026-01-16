//
//  ReminderSound.swift
//  H2Only
//
//  Created by Trangptt on 15/1/26.
//
import SwiftUI
import RealmSwift

// Cấu trúc dữ liệu cho 1 dòng chọn
struct SoundOption: Identifiable {
    let id = UUID()
    let name: String      // Tên hiển thị
    let fileName: String  // Tên file thật
}

struct ReminderSound: View {
    @ObservedResults(UserProfile.self) var userProfiles
    @Environment(\.dismiss) var dismiss
 
    // Danh sách âm thanh
    let sounds = [
        SoundOption(name: "Mặc định", fileName: ""),
        SoundOption(name: "Tiếng bong bóng", fileName: "bubble.wav"),
        SoundOption(name: "Tiếng nước chảy", fileName: "water.wav"),
        SoundOption(name: "Thông báo 1", fileName: "noti1.wav"),
        SoundOption(name: "Thông báo 2", fileName: "noti2.wav")
    ]
    
    var body: some View {
        List {
            ForEach(sounds) { sound in
                Button(action: {
                    selectSound(sound)
                }) {
                    HStack {
                        Text(sound.name)
                            .foregroundColor(.black)
                            .font(.system(size: 16))
                        
                        Spacer()
                        
                        // Nếu đang chọn thì hiện tick xanh
                        if let user = userProfiles.first,
                           user.notificationSoundName == sound.fileName {
                            Image("ic_checked")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Âm thanh nhắc nhở")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing){
                Button(action: {
                    dismiss()
                }){
                    Image("ic_close")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                }
            }
        }
    }
    
    // Logic khi bấm chọn
        func selectSound(_ sound: SoundOption) {
            // Lưu vào Realm
            if let user = userProfiles.first, let realm = try? Realm() {
                
                try? realm.write {
                    if let liveUser = user.thaw() {
                        liveUser.notificationSoundName = sound.fileName
                    }
                }
                
                // Cập nhật lại hệ thống thông báo
                SettingViewModel().updateSystemNotifications(for: user)
            }
            
            // Phát nghe thử
            AudioPreviewHelper.shared.playSound(named: sound.fileName)
        }
}
