//
//  AppEnums.swift
//  H2Only
//
//  Created by Trangptt on 8/1/26.
//
import Foundation
import RealmSwift

// Giới tính
enum Gender: String, PersistableEnum {
    case male = "Nam"
    case female = "Nữ"
    case other = "Khác"
}

// Thể tích (ml/fl oz)
enum VolumeUnit: String, PersistableEnum {
    case ml
    case flOz
}

// Cân nặng (kg/lbs)
enum WeightUnit: String, PersistableEnum {
    case kg
    case lbs
}
