//
//  AudioPreviewHelper.swift
//  H2Only
//
//  Created by Trangptt on 16/1/26.
//


import AVFoundation

class AudioPreviewHelper {
    static let shared = AudioPreviewHelper()
    var player: AVAudioPlayer?
    
    func playSound(named fileName: String) {
        // Nếu chọn Mặc định (chuỗi rỗng) thì không phát gì
        if fileName.isEmpty { return }
        
        let name = fileName.replacingOccurrences(of: ".wav", with: "")
        
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else {
            print("Không tìm thấy file âm thanh: \(fileName)")
            return
        }
        
        do {
            // Cho phép phát nhạc kể cả khi gạt rung
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print("Lỗi phát nhạc: \(error.localizedDescription)")
        }
    }
}
