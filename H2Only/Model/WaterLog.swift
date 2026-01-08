//
//  WaterLog.swift
//  H2Only
//
//  Created by Trangptt on 7/1/26.
//
import Foundation
import RealmSwift

class WaterLog: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    
    @Persisted var amount: Int = 0
    @Persisted var date: Date = Date()
}
