//
//  BasePopup.swift
//  H2Only
//
//  Created by Trangptt on 15/1/26.
//


import SwiftUI

struct BasePopup<Content: View>: View {
    let title: String
    @Binding var isPresented: Bool
    
    // Hành động khi bấm nút
    var onCancel: () -> Void = {}
    var onConfirm: () -> Void
    
    // Nội dung ở giữa (linh hoạt)
    @ViewBuilder let content: Content
    
    var body: some View {
        ZStack {
            // Nền mờ phía sau
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                    isPresented = false
                }
                .transition(.opacity)
            
            // Nội dung Popup
            VStack(spacing: 20) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Nhúng nội dung vào
                content
                    .padding(.horizontal, 10)
                
                
                Spacer().frame(height: 10)
                
                // Hàng nút bấm (Footer)
                HStack(spacing: 90) {
                    Button(action: {
                        onCancel()
                        isPresented = false
                    }) {
                        Text("HỦY BỎ")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    
                    Button(action: {
                        onConfirm()
                         isPresented = false
                    }) {
                        Text("ĐỒNG Ý")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.blue)
                    }
                }
                .padding(.bottom, 20)
            }
            .frame(width: 320)
            .background(Color.white)
            .cornerRadius(16)
            .opacity(isPresented ? 1 : 0)
        }
        .zIndex(100)
    }
}
