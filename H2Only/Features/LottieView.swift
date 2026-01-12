//
//  LottieView.swift
//  H2Only
//
//  Created by Trangptt on 7/1/26.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    var filename: String
    var loopMode: LottieLoopMode = .playOnce
    var contentMode: UIView.ContentMode = .scaleAspectFit
    
    var toProgress: CGFloat? = nil
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        
        let animationView = LottieAnimationView(name: filename)
        animationView.contentMode = contentMode
        animationView.loopMode = loopMode
        animationView.backgroundBehavior = .pauseAndRestore
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        // Chạy lần đầu tiên
        if let toProgress = toProgress {
             // Chạy ngay đến điểm cần đến
            animationView.play(toProgress: toProgress, loopMode: loopMode)
        } else {
            animationView.play()
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let animationView = uiView.subviews.first(where: { $0 is LottieAnimationView }) as? LottieAnimationView else { return }
        
        // Kiểm tra xem có lệnh thay đổi mức nước không
        if let targetProgress = toProgress {
            // Chạy từ vị trí hiện tại đến targetProgress
            animationView.play(toProgress: targetProgress, loopMode: loopMode)
        }
    }
}

