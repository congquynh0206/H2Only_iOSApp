//
//  DateFormat.swift
//  H2Only
//
//  Created by Trangptt on 12/1/26.
//

import SwiftUI

struct DateFormat {
    static func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
