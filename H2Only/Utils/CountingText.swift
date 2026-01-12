//
//  CountingText.swift
//  H2Only
//
//  Created by Trangptt on 12/1/26.
//
import SwiftUI

struct CountingText: View, Animatable {
    var value: Double
    var color: Color = .blue
    var size: CGFloat = 20
    var weight: Font.Weight = .medium
    
    var animatableData: Double {
        get { value }
        set { value = newValue }
    }
    
    var body: some View {
        // Chuyển Double thành Int để hiển thị không có số lẻ
        Text("\(Int(value))")
            .font(.system(size: size, weight: weight))
            .foregroundColor(color)
            .monospacedDigit()
    }
}
