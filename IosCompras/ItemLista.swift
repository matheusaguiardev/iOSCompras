//
//  ItemLista.swift
//  IosCompras
//
//  Created by André Lima on 23/05/17.
//  Copyright © 2017 Matheus Aguiar. All rights reserved.
//

import Foundation
import Firebase

struct ItemLista {
    var nome:String?
    var ref: FIRDatabaseReference?
    func toAnyObject() -> Any {
        return ["nome":nome!]
    }
}
