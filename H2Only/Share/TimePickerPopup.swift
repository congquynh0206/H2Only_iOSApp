//
//  TimePickerPopup.swift
//  H2Only
//
//  Created by Trangptt on 15/1/26.
//

import SwiftUI

struct TimePickerPopup: View {
    @Binding var isPresented: Bool
    @Binding var selection: Date // Giờ đang chọn
    
    var onSave: () -> Void
    
    var body: some View {
        BasePopup(
            title: "Cài đặt thời gian",
            isPresented: $isPresented,
            onCancel: {
                
            },
            onConfirm: {
                onSave()
            }
        ) {
            // Nội dung
            DatePicker("", selection: $selection, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(height: 150) // Giới hạn chiều cao
                .clipped()
        }
    }
}
