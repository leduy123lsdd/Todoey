//
//  Category.swift
//  Todoey
//
//  Created by Lê Duy on 7/2/19.
//  Copyright © 2019 Lê Duy. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    let items = List<Item>()
}
