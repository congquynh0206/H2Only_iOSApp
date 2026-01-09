//
//  Cup.swift
//  H2Only
//
//  Created by Trangptt on 9/1/26.
//

import RealmSwift

class Cup : Object, Identifiable{
    @Persisted(primaryKey: true) var id : ObjectId
    @Persisted var amount : Int
    @Persisted var iconName : String
    @Persisted var isDefault : Bool = false
    
    convenience init(amount : Int, iconName: String, isDefault : Bool = false) {
        self.init()
        self.amount = amount
        self.iconName = iconName
        self.isDefault = isDefault
    }
}
