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
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)
        
        // Setup Animation View
        let animationView = LottieAnimationView(name: filename)
        animationView.contentMode = contentMode
        animationView.loopMode = loopMode
        animationView.backgroundBehavior = .pauseAndRestore // Giúp tiết kiệm pin khi app background
        
        // Play animation
        animationView.play()
        
        // Layout constraints
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        // Có thể xử lý logic update animation tại đây nếu cần (ví dụ đổi progress theo lượng nước)
    }
}
